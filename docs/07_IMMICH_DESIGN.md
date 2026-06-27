# 07. Immich

## 1. Роль в проекте / Role in the project

🇷🇺 Immich используется как фото- и видеоархив, близкий по пользовательскому сценарию к Google Photos.
🇬🇧 Immich serves as a photo and video archive, functionally similar to Google Photos.

## 2. Ограничение для Jetson Nano / Jetson Nano constraints

🇷🇺 Официальные требования Immich указывают минимум 6 GB RAM и рекомендацию 8 GB. Для систем с 4 GB RAM допускается работа с отключёнными ML-функциями. Поэтому на Jetson Nano 4 GB необходимо начинать с отключённого machine learning.
🇬🇧 Immich officially requires minimum 6 GB RAM, recommends 8 GB. On systems with 4 GB RAM, operation is supported with ML disabled. On Jetson Nano 4 GB, start with machine learning disabled.

## 3. Рекомендуемый режим / Recommended mode

```text
IMMICH_DISABLE_MACHINE_LEARNING=true
video transcoding: disabled or minimal / выключено или минимально
bulk import: do not run until load tests pass / не выполнять до нагрузочных тестов
```

## 4. Данные / Data paths

```text
/mnt/storage/immich/library
/mnt/storage/db/immich-postgres
```

## 5. Тест первого запуска / First-run checklist

🇷🇺
1. Создать пользователя.
2. Подключить Android Immich.
3. Загрузить 20–50 фото.
4. Загрузить 2–3 видео.
5. Проверить `docker stats`.
6. Проверить температуру Jetson.
7. Проверить размер thumbnails/transcoded data.

🇬🇧
1. Create a user account.
2. Connect the Android Immich app.
3. Upload 20–50 photos.
4. Upload 2–3 videos.
5. Check `docker stats`.
6. Check Jetson temperature.
7. Check size of thumbnails and transcoded data.

## 6. Риски / Risks

| Риск / Risk | Мера / Mitigation |
|---|---|
| Нехватка RAM / RAM shortage | Disable ML, increase swap, set mem_limit on containers |
| Нагрузка CPU / CPU load | Disable heavy background jobs |
| Рост storage / Storage growth | Account for +10–20% for thumbnails and derived files |
| БД на HDD / DB on HDD | Verify USB stability and SMART health |
