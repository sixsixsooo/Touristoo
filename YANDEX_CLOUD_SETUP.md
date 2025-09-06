# Настройка Яндекс Cloud

Этот документ описывает процесс настройки Яндекс Cloud для приложения Touristoo Runner.

## Создание проекта в Яндекс Cloud

### 1. Регистрация

- Зарегистрируйтесь на [Яндекс Cloud](https://cloud.yandex.ru/)
- Подтвердите номер телефона и email
- Создайте платежный аккаунт

### 2. Создание облака

- Создайте новое облако
- Настройте организацию
- Добавьте пользователей при необходимости

### 3. Создание каталога

- Создайте каталог "Touristoo Runner"
- Настройте права доступа
- Выберите зону доступности

## Настройка сервисов

### 1. Cloud Functions

```bash
# Установка Yandex CLI
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

# Инициализация
yc init

# Создание функции
yc serverless function create --name touristoo-api
```

### 2. Managed PostgreSQL

```bash
# Создание кластера БД
yc managed-postgresql cluster create \
  --name touristoo-db \
  --environment production \
  --network-name default
```

### 3. Object Storage

```bash
# Создание бакета
yc storage bucket create --name touristoo-assets
```

## Конфигурация приложения

### 1. Переменные окружения

```env
YANDEX_CLOUD_API_KEY=your_api_key
YANDEX_CLOUD_FUNCTION_URL=https://functions.yandexcloud.net/your-function-id
YANDEX_CLOUD_DB_HOST=your_db_host
YANDEX_CLOUD_DB_NAME=touristoo
YANDEX_CLOUD_DB_USER=your_user
YANDEX_CLOUD_DB_PASSWORD=your_password
```

### 2. Настройка в коде

```dart
class AppConfig {
  static const String yandexCloudApiKey = 'YOUR_YANDEX_CLOUD_API_KEY';
  static const String yandexCloudFunctionUrl = 'https://functions.yandexcloud.net/your-function-id';
}
```

## API Endpoints

### 1. Аутентификация

```javascript
// POST /auth
{
  "apiKey": "your_api_key"
}
```

### 2. Игроки

```javascript
// POST /players
{
  "id": "player_id",
  "name": "Player Name",
  "totalScore": 0,
  "level": 1,
  "coins": 0
}
```

## База данных

### 1. Схема таблиц

```sql
CREATE TABLE players (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    total_score INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    coins INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## Мониторинг

### 1. Yandex AppMetrica

```dart
await YandexAppmetrica.activateWithApiKey('YOUR_METRICA_API_KEY');
```

## Поддержка

- **Документация**: https://cloud.yandex.ru/docs/
- **Поддержка**: https://cloud.yandex.ru/support
