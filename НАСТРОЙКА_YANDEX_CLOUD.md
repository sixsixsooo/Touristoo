# Руководство по настройке Yandex Cloud для игры Touristoo Runner

Это руководство содержит подробные пошаговые инструкции по настройке сервисов Yandex Cloud для мобильной игры Touristoo Runner.

## Содержание

1. [Предварительные требования](#предварительные-требования)
2. [Настройка кластера PostgreSQL](#настройка-кластера-postgresql)
3. [Настройка Object Storage](#настройка-object-storage)
4. [Настройка Yandex Ads SDK](#настройка-yandex-ads-sdk)
5. [API Gateway и Cloud Functions](#api-gateway-и-cloud-functions)
6. [Конфигурация окружения](#конфигурация-окружения)
7. [Тестирование настройки](#тестирование-настройки)

## Предварительные требования

- Аккаунт Yandex Cloud с включенным биллингом
- Доменное имя (опционально, для продакшена)
- Bundle ID мобильного приложения (для настройки рекламы)

## 1. Настройка кластера PostgreSQL

### Шаг 1: Создание кластера PostgreSQL

1. **Вход в консоль управления Yandex Cloud**

   - Перейдите на [console.cloud.yandex.ru](https://console.cloud.yandex.ru)
   - Войдите в свой аккаунт Yandex

2. **Переход к сервису Managed Service for PostgreSQL**

   - В левом меню выберите "База данных" → "Managed Service for PostgreSQL"
   - Нажмите "Создать кластер"

3. **Настройка кластера:**

   ```
   Имя кластера: touristoo-db
   Описание: PostgreSQL кластер для игры Touristoo
   Окружение: Production (или Prestable для тестирования)
   Версия: PostgreSQL 15
   Класс хоста: s2.micro (1 vCPU, 4 GB RAM) для разработки
   Тип диска: SSD
   Размер диска: 20 GB (минимум)
   ```

4. **Сетевая конфигурация:**

   - Выберите вашу VPC сеть или создайте новую
   - Создайте группу безопасности с правилами:
     - Порт 6432 (PostgreSQL) с диапазона IP вашего приложения
     - Порт 22 (SSH) для управления при необходимости

5. **Конфигурация базы данных:**

   ```
   Имя базы данных: touristoo
   Имя пользователя: touristoo_user
   Пароль: [Сгенерируйте надежный пароль - сохраните безопасно!]
   ```

6. **Настройки резервного копирования:**

   - Включите автоматические резервные копии
   - Установите срок хранения резервных копий 7 дней
   - Выберите время резервного копирования (например, 02:00 UTC)

7. **Нажмите "Создать кластер"** и дождитесь завершения (5-10 минут)

### Шаг 2: Настройка доступа к базе данных

1. **Получение данных подключения:**

   - Запишите hostname кластера и порт
   - Сохраните учетные данные базы данных безопасно

2. **Тестирование подключения:**

   ```bash
   psql -h <hostname-кластера> -p 6432 -U touristoo_user -d touristoo
   ```

3. **Обновление переменных окружения:**
   ```env
   DB_HOST=<hostname-кластера>
   DB_PORT=6432
   DB_NAME=touristoo
   DB_USER=touristoo_user
   DB_PASSWORD=<ваш-пароль>
   ```

**Видеоурок:** [Настройка PostgreSQL в Yandex Cloud](https://youtu.be/example-postgresql-setup)

## 2. Настройка Object Storage

### Шаг 1: Создание бакета Object Storage

1. **Переход к Object Storage**

   - В левом меню выберите "Хранилище" → "Object Storage"
   - Нажмите "Создать бакет"

2. **Настройка бакета:**

   ```
   Имя бакета: touristoo-assets-[случайный-суффикс]
   Класс хранилища: Standard
   Доступ: Private
   Версионирование: Включено
   ```

3. **Настройка CORS (Cross-Origin Resource Sharing):**
   - Перейдите в настройки бакета → "CORS"
   - Добавьте правило:
   ```json
   {
     "AllowedOrigins": ["*"],
     "AllowedMethods": ["GET", "HEAD"],
     "AllowedHeaders": ["*"],
     "MaxAgeSeconds": 3600
   }
   ```

### Шаг 2: Создание структуры папок

Создайте следующие папки в вашем бакете:

```
models/
  ├── characters/
  ├── obstacles/
  └── environment/
textures/
  ├── characters/
  ├── obstacles/
  └── environment/
sounds/
  ├── music/
  ├── effects/
  └── voice/
animations/
  └── characters/
ui/
  ├── icons/
  └── backgrounds/
```

### Шаг 3: Настройка ключей доступа

1. **Создание сервисного аккаунта:**

   - Перейдите в "IAM" → "Сервисные аккаунты"
   - Создайте сервисный аккаунт: `touristoo-storage`
   - Назначьте роль: `storage.editor`

2. **Создание ключей доступа:**

   - Перейдите в "Ключи доступа" в сервисном аккаунте
   - Создайте новый ключ доступа
   - Сохраните `Access Key ID` и `Secret Access Key`

3. **Обновление переменных окружения:**
   ```env
   YC_ACCESS_KEY_ID=<access-key-id>
   YC_SECRET_ACCESS_KEY=<secret-access-key>
   YC_BUCKET_NAME=touristoo-assets-[случайный-суффикс]
   YC_REGION=ru-central1
   ```

**Видеоурок:** [Настройка Object Storage в Yandex Cloud](https://youtu.be/example-object-storage-setup)

## 3. Настройка Yandex Ads SDK

### Шаг 1: Создание аккаунта Yandex Advertising

1. **Переход к Yandex Advertising Network**

   - Перейдите на [yandex.ru/adv](https://yandex.ru/adv)
   - Войдите в свой аккаунт Yandex

2. **Создание новой кампании:**
   - Нажмите "Создать кампанию"
   - Выберите "Продвижение мобильного приложения"
   - Выберите "Yandex Advertising Network"

### Шаг 2: Настройка вашего приложения

1. **Информация о приложении:**

   ```
   Название приложения: Touristoo Runner
   Платформа: Android и iOS
   Категория: Игры → Аркады
   Описание: 3D бесконечный раннер
   ```

2. **Ссылки на магазины приложений:**
   - Добавьте ссылку на Google Play Store при публикации
   - Добавьте ссылку на App Store при публикации

### Шаг 3: Создание рекламных блоков

1. **Баннерная реклама:**

   - Создайте рекламный блок баннера (320x50, 320x100)
   - Запишите Ad Unit ID

2. **Межстраничная реклама:**

   - Создайте рекламный блок полноэкранной рекламы
   - Запишите Ad Unit ID

3. **Видеореклама с наградой:**
   - Создайте рекламный блок видеорекламы с наградой
   - Запишите Ad Unit ID

### Шаг 4: Настройка рекламных блоков в приложении

Обновите конфигурацию вашего приложения:

```env
YANDEX_ADS_BANNER_UNIT_ID=<banner-unit-id>
YANDEX_ADS_INTERSTITIAL_UNIT_ID=<interstitial-unit-id>
YANDEX_ADS_REWARDED_UNIT_ID=<rewarded-unit-id>
```

**Видеоурок:** [Настройка Yandex Ads SDK](https://youtu.be/example-yandex-ads-setup)

## 4. API Gateway и Cloud Functions

### Шаг 1: Создание API Gateway

1. **Переход к API Gateway**

   - Перейдите в "Serverless" → "API Gateway"
   - Нажмите "Создать API Gateway"

2. **Настройка API Gateway:**

   ```
   Имя: touristoo-api
   Описание: API Gateway для игры Touristoo
   ```

3. **Создание OpenAPI спецификации:**
   ```yaml
   openapi: 3.0.0
   info:
     title: Touristoo API
     version: 1.0.0
   paths:
     /health:
       get:
         x-yc-apigateway-integration:
           type: cloud_functions
           function_id: <function-id>
   ```

### Шаг 2: Создание Cloud Functions

1. **Создание функции для аутентификации:**

   ```
   Имя: touristoo-auth
   Runtime: nodejs18
   Точка входа: index.handler
   ```

2. **Создание функции для игровой логики:**

   ```
   Имя: touristoo-game
   Runtime: nodejs18
   Точка входа: index.handler
   ```

3. **Создание функции для таблицы лидеров:**
   ```
   Имя: touristoo-leaderboard
   Runtime: nodejs18
   Точка входа: index.handler
   ```

### Шаг 3: Настройка триггеров функций

1. **Настройка HTTP триггеров для каждой функции**
2. **Настройка переменных окружения для каждой функции**
3. **Настройка IAM ролей для доступа к базе данных**

**Видеоурок:** [Настройка Cloud Functions в Yandex Cloud](https://youtu.be/example-cloud-functions-setup)

## 5. Конфигурация окружения

### Переменные окружения бэкенда

Создайте файл `.env` в директории бэкенда:

```env
# Конфигурация базы данных
DB_HOST=<hostname-кластера-postgresql>
DB_PORT=6432
DB_NAME=touristoo
DB_USER=touristoo_user
DB_PASSWORD=<ваш-пароль-базы-данных>

# Конфигурация JWT
JWT_SECRET=<сгенерируйте-надежный-секрет>
JWT_REFRESH_SECRET=<сгенерируйте-надежный-секрет-обновления>
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Конфигурация Yandex Cloud
YC_ACCESS_KEY_ID=<ваш-access-key-id>
YC_SECRET_ACCESS_KEY=<ваш-secret-access-key>
YC_BUCKET_NAME=touristoo-assets-[случайный-суффикс]
YC_REGION=ru-central1

# Конфигурация Yandex Ads
YANDEX_ADS_BANNER_UNIT_ID=<banner-unit-id>
YANDEX_ADS_INTERSTITIAL_UNIT_ID=<interstitial-unit-id>
YANDEX_ADS_REWARDED_UNIT_ID=<rewarded-unit-id>

# Конфигурация сервера
PORT=3000
NODE_ENV=production
ALLOWED_ORIGINS=https://yourdomain.com,https://yourdomain.ru
```

### Переменные окружения клиента

Создайте файл `.env` в директории клиента:

```env
# Конфигурация API
API_BASE_URL=https://your-api-gateway-url
API_TIMEOUT=10000

# Конфигурация Yandex Ads
YANDEX_ADS_BANNER_UNIT_ID=<banner-unit-id>
YANDEX_ADS_INTERSTITIAL_UNIT_ID=<interstitial-unit-id>
YANDEX_ADS_REWARDED_UNIT_ID=<rewarded-unit-id>

# Конфигурация приложения
APP_NAME=Touristoo Runner
APP_VERSION=1.0.0
```

## 6. Тестирование настройки

### Тестирование подключения к базе данных

```bash
# Тестирование подключения к PostgreSQL
psql -h <hostname-кластера> -p 6432 -U touristoo_user -d touristoo

# Запуск инициализации базы данных
cd backend
npm run db:init
```

### Тестирование Object Storage

```bash
# Тестирование доступа к бакету
aws s3 ls s3://touristoo-assets-[случайный-суффикс] --endpoint-url=https://storage.yandexcloud.net
```

### Тестирование API эндпоинтов

```bash
# Тестирование health эндпоинта
curl https://your-api-gateway-url/health

# Тестирование аутентификации
curl -X POST https://your-api-gateway-url/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"testpass123"}'
```

## 7. Рекомендации по безопасности

### Безопасность базы данных

- Используйте надежные пароли
- Включите SSL соединения
- Ограничьте доступ по IP
- Регулярно обновляйте систему безопасности

### Безопасность Object Storage

- Используйте приватные бакеты
- Реализуйте правильные политики CORS
- Используйте подписанные URL для конфиденциального контента
- Регулярно ротируйте ключи доступа

### Безопасность API

- Используйте HTTPS везде
- Реализуйте ограничение скорости запросов
- Валидируйте все входные данные
- Используйте правильную аутентификацию

## 8. Мониторинг и обслуживание

### Настройка мониторинга

1. **Cloud Monitoring** для базы данных и хранилища
2. **Логирование** для API Gateway и Functions
3. **Уведомления** о критических проблемах

### Регулярное обслуживание

1. **Резервные копии базы данных** (автоматические)
2. **Обновления безопасности** (ежемесячно)
3. **Мониторинг производительности** (непрерывно)
4. **Оптимизация затрат** (ежемесячный обзор)

## Устранение неполадок

### Частые проблемы

1. **Ошибка подключения к базе данных**

   - Проверьте правила групп безопасности
   - Проверьте учетные данные
   - Проверьте сетевое подключение

2. **Ошибка доступа к Object Storage**

   - Проверьте ключи доступа
   - Проверьте разрешения бакета
   - Проверьте конфигурацию CORS

3. **Ошибки API Gateway**
   - Проверьте логи функций
   - Проверьте переменные окружения
   - Проверьте IAM разрешения

### Ресурсы поддержки

- [Документация Yandex Cloud](https://cloud.yandex.ru/docs)
- [Документация Yandex Ads](https://yandex.ru/dev/ads/)
- [Форум сообщества](https://cloud.yandex.ru/community)

## Оптимизация затрат

### Примерные ежемесячные затраты (Разработка)

- Кластер PostgreSQL (s2.micro): ~$15-20
- Object Storage (20GB): ~$1-2
- API Gateway: ~$5-10
- Cloud Functions: ~$5-15
- **Итого: ~$25-50/месяц**

### Масштабирование для продакшена

- Обновите до более крупного экземпляра PostgreSQL
- Реализуйте CDN для ассетов
- Используйте зарезервированную емкость для экономии
- Мониторьте использование и оптимизируйте

---

**Примечание:** Замените значения-заглушки на ваши реальные конфигурационные значения. Храните все учетные данные в безопасности и никогда не коммитьте их в систему контроля версий.
