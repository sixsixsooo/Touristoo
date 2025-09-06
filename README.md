# Touristoo Runner

Мобильная игра-раннер с 3D графикой, созданная с использованием React Native (Expo) и three.js.

## 🎮 Особенности

- **3D графика** - Использование three.js для создания красивой 3D сцены
- **Кроссплатформенность** - Работает на iOS и Android
- **Офлайн режим** - Локальное сохранение прогресса с синхронизацией
- **Рейтинговая система** - Глобальные таблицы лидеров
- **Магазин** - Покупка скинов и бустеров
- **Монетизация** - Интеграция с Yandex Ads SDK
- **Гостевой режим** - Возможность играть без регистрации

## 🛠 Технологический стек

### Клиент (React Native)

- **React Native (Expo)** - Основной фреймворк
- **TypeScript** - Типизация
- **three.js + expo-three** - 3D графика
- **React Navigation** - Навигация
- **Redux Toolkit** - Управление состоянием
- **SQLite** - Локальное хранилище
- **Axios** - HTTP запросы
- **Yandex Ads SDK** - Монетизация

### Бэкенд (Node.js)

- **Express.js** - Web сервер
- **PostgreSQL** - База данных
- **JWT** - Аутентификация
- **Yandex Cloud** - Облачная инфраструктура
- **Object Storage** - Хранение ассетов

## 📁 Структура проекта

```
Touristoo/
├── src/                          # Исходный код приложения
│   ├── components/               # React компоненты
│   │   └── GameRenderer.tsx     # 3D игровой движок
│   ├── screens/                  # Экраны приложения
│   │   ├── HomeScreen.tsx       # Главный экран
│   │   ├── GameScreen.tsx       # Игровой экран
│   │   ├── ShopScreen.tsx       # Магазин
│   │   ├── LeaderboardScreen.tsx # Рейтинг
│   │   ├── SettingsScreen.tsx   # Настройки
│   │   └── ProfileScreen.tsx    # Профиль
│   ├── navigation/               # Навигация
│   │   └── AppNavigator.tsx     # Главный навигатор
│   ├── store/                    # Redux store
│   │   ├── index.ts             # Конфигурация store
│   │   └── slices/              # Redux слайсы
│   ├── services/                 # Сервисы
│   │   ├── api.ts               # API клиент
│   │   ├── storage.ts           # Локальное хранилище
│   │   └── adsService.ts        # Реклама
│   └── types/                    # TypeScript типы
├── backend/                      # Бэкенд API
│   ├── src/
│   │   ├── routes/              # API маршруты
│   │   ├── config/              # Конфигурация
│   │   └── index.js             # Точка входа
│   └── package.json
├── assets/                       # Статические ресурсы
├── App.tsx                       # Главный компонент
├── package.json                  # Зависимости клиента
└── README.md                     # Документация
```

## 🚀 Быстрый старт

### Установка зависимостей

```bash
# Установка зависимостей клиента
npm install

# Установка зависимостей бэкенда
cd backend
npm install
```

### Настройка окружения

1. Скопируйте `backend/env.example` в `backend/.env`
2. Настройте переменные окружения для подключения к Yandex Cloud
3. Создайте базу данных PostgreSQL в Yandex Cloud

### Запуск приложения

```bash
# Запуск клиента
npm start

# Запуск бэкенда (в отдельном терминале)
cd backend
npm run dev
```

## 🔧 Настройка Yandex Cloud

### 1. Managed PostgreSQL

- Создайте кластер PostgreSQL в Yandex Cloud
- Настройте пользователя и пароль
- Обновите переменные окружения в `backend/.env`

### 2. Object Storage

- Создайте бакет для хранения 3D моделей и текстур
- Настройте CORS для доступа с мобильного приложения
- Обновите конфигурацию в `backend/env.example`

### 3. Cloud Functions

- Создайте функцию для обработки API запросов
- Настройте триггеры и маршруты
- Деплойте код бэкенда

### 4. Yandex Ads SDK

- Зарегистрируйтесь в Yandex Advertising
- Получите Ad Unit ID для баннеров и видеорекламы
- Обновите конфигурацию в `src/services/adsService.ts`

## 📱 Сборка для продакшена

### Android

```bash
# Создание APK
eas build --platform android

# Создание AAB для Google Play
eas build --platform android --profile production
```

### iOS

```bash
# Создание IPA для App Store
eas build --platform ios --profile production
```

## 🎯 Игровая механика

### Основной геймплей

- Бесконечный бег с препятствиями
- Сбор монет для покупки скинов
- Система здоровья и жизней
- Прогрессивное увеличение сложности

### Система прогресса

- Локальное сохранение в SQLite
- Синхронизация с облаком при наличии интернета
- Гостевой режим без регистрации
- Поддержка аккаунтов через Yandex ID

### Монетизация

- Баннерная реклама в меню
- Межстраничная реклама между играми
- Реклама за награду (монеты)
- Подготовка к системе покупок

## 🔮 Планы развития

### Ближайшие обновления

- [ ] Интеграция с Yandex ID
- [ ] Система достижений
- [ ] Мультиплеер режимы
- [ ] Новые уровни и препятствия

### Долгосрочные цели

- [ ] Веб-версия на Next.js
- [ ] Система покупок через Yandex Pay
- [ ] Социальные функции
- [ ] Турниры и события

## 🤝 Вклад в проект

1. Форкните репозиторий
2. Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте в ветку (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 📞 Поддержка

Если у вас есть вопросы или предложения, создайте [Issue](https://github.com/your-username/touristoo-runner/issues) в репозитории.

---

**Touristoo Runner** - создано с ❤️ для мобильных геймеров
