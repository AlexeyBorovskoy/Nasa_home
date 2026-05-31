import os
import re
from typing import Literal, Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

try:
    from openai import OpenAI
except Exception:  # pragma: no cover
    OpenAI = None

app = FastAPI(title="Home Cloud LLM Gateway", version="0.1.0")

EMAIL_RE = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
PHONE_RE = re.compile(r"(?<!\d)(?:\+?\d[\d\s().-]{7,}\d)(?!\d)")
TOKEN_RE = re.compile(r"(?i)(api[_-]?key|token|secret|password|bearer)\s*[:=]\s*[^\s]+")
PRIVATE_KEY_RE = re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----.*?-----END [A-Z ]*PRIVATE KEY-----", re.S)


def redact(text: str) -> str:
    text = PRIVATE_KEY_RE.sub("[REDACTED_PRIVATE_KEY]", text)
    text = TOKEN_RE.sub(r"\1=[REDACTED]", text)
    text = EMAIL_RE.sub("[REDACTED_EMAIL]", text)
    text = PHONE_RE.sub("[REDACTED_PHONE]", text)
    return text


class ChatRequest(BaseModel):
    task: str = Field(default="general")
    prompt: str
    context: Optional[str] = None
    mode: Literal["safe", "raw"] = "safe"
    reasoning: bool = False


class ChatResponse(BaseModel):
    provider: str
    model: str
    redacted: bool
    content: str


@app.get("/health")
def health():
    return {
        "status": "ok",
        "provider": os.getenv("LLM_PROVIDER", "deepseek"),
        "redaction": os.getenv("LLM_REDACT_PERSONAL_DATA", "true"),
    }


@app.post("/v1/redact")
def redact_endpoint(payload: ChatRequest):
    src = "\n".join([payload.prompt, payload.context or ""])
    return {"redacted_text": redact(src)}


@app.post("/v1/chat", response_model=ChatResponse)
def chat(payload: ChatRequest):
    provider = os.getenv("LLM_PROVIDER", "deepseek")
    base_url = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com")
    api_key = os.getenv("DEEPSEEK_API_KEY", "")
    model = os.getenv("DEEPSEEK_REASONER_MODEL" if payload.reasoning else "DEEPSEEK_MODEL", "deepseek-chat")

    if payload.mode != "safe":
        raise HTTPException(status_code=400, detail="raw mode is disabled in Stage 1")

    if not api_key or api_key == "replace_me":
        return ChatResponse(
            provider=provider,
            model="mock",
            redacted=True,
            content="LLM Gateway mock response: DEEPSEEK_API_KEY is not configured.",
        )

    if OpenAI is None:
        raise HTTPException(status_code=500, detail="openai SDK is not installed")

    prompt = payload.prompt
    context = payload.context or ""
    full = f"Task: {payload.task}\n\nContext:\n{context}\n\nPrompt:\n{prompt}"
    safe_full = redact(full)

    client = OpenAI(api_key=api_key, base_url=base_url)
    try:
        response = client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": "You are an infrastructure assistant. Do not request or expose secrets or personal data."},
                {"role": "user", "content": safe_full},
            ],
            stream=False,
        )
        content = response.choices[0].message.content or ""
    except Exception as exc:  # pragma: no cover
        raise HTTPException(status_code=502, detail=f"LLM provider error: {exc}") from exc

    return ChatResponse(provider=provider, model=model, redacted=True, content=content)


@app.post("/v1/diagnostics/explain", response_model=ChatResponse)
def explain_diagnostics(payload: ChatRequest):
    payload.task = "explain_anonymized_diagnostics"
    return chat(payload)
