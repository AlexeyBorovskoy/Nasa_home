// nextcloud-smoke.js -- k6 smoke test for Nextcloud
// Usage: NEXTCLOUD_URL=http://192.168.0.50:8080 k6 run tests/load/nextcloud-smoke.js
//
// Prerequisites: k6 installed (https://k6.io/docs/get-started/installation/)
// Do NOT auto-run. Manual execution only.
//
// Constraints for Jetson Nano:
//   - Max 5 VU (RAM limited, shared CPU/GPU)
//   - Duration: 2 minutes (smoke test, not stress)
//   - Monitor RAM during test: watch free -h

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const statusPhpTrend = new Trend('status_php_duration');

// Test configuration
export const options = {
    vus: 5,          // max for Jetson Nano 4GB
    duration: '2m',  // smoke test only
    thresholds: {
        http_req_failed: ['rate<0.01'],        // < 1% errors
        http_req_duration: ['p(95)<2000'],     // p95 < 2s
        errors: ['rate<0.01'],
    },
};

// Get Nextcloud URL from env or default to LAN address
const NEXTCLOUD_URL = __ENV.NEXTCLOUD_URL || 'http://192.168.0.50:8080';

export default function () {
    // 1. Check /status.php (lightweight, no auth)
    const statusRes = http.get(`${NEXTCLOUD_URL}/status.php`, {
        timeout: '15s',
        tags: { name: 'status.php' },
    });

    const statusOk = check(statusRes, {
        'status.php HTTP 200': (r) => r.status === 200,
        'status.php installed=true': (r) => r.body.includes('"installed":true'),
        'status.php response < 2s': (r) => r.timings.duration < 2000,
    });

    statusPhpTrend.add(statusRes.timings.duration);
    errorRate.add(!statusOk);

    // Small pause between requests (respect Jetson Nano limits)
    sleep(1);
}

export function handleSummary(data) {
    const pass = data.metrics.http_req_failed.values.rate < 0.01
        && data.metrics.http_req_duration.values['p(95)'] < 2000;

    return {
        stdout: `
=== Nextcloud Smoke Test Summary ===
Target: ${NEXTCLOUD_URL}
VUs: ${options.vus}  Duration: ${options.duration}

Results:
  Total requests:     ${data.metrics.http_reqs.values.count}
  Error rate:         ${(data.metrics.http_req_failed.values.rate * 100).toFixed(2)}%  (threshold: < 1%)
  p50 response:       ${data.metrics.http_req_duration.values['p(50)'].toFixed(0)}ms
  p95 response:       ${data.metrics.http_req_duration.values['p(95)'].toFixed(0)}ms  (threshold: < 2000ms)
  p99 response:       ${data.metrics.http_req_duration.values['p(99)'].toFixed(0)}ms

Result: ${pass ? 'PASS' : 'FAIL'}

Note: This is a smoke test for Jetson Nano. Not a stress test.
Monitor RAM: watch free -h  (stop if available RAM < 200MB)
`,
    };
}
