@echo off
REM Скрипт настройки игры Touristoo Runner для Windows
REM Этот скрипт настраивает среду разработки для мобильной игры Touristoo Runner

echo 🎮 Настройка среды разработки игры Touristoo Runner...

REM Проверка установки Node.js
echo [ИНФО] Проверка установки Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Node.js не установлен. Пожалуйста, установите Node.js 18+ с https://nodejs.org/
    pause
    exit /b 1
)
echo [УСПЕХ] Node.js установлен

REM Проверка установки npm
echo [ИНФО] Проверка установки npm...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] npm не установлен. Пожалуйста, установите npm.
    pause
    exit /b 1
)
echo [УСПЕХ] npm установлен

REM Проверка установки Expo CLI
echo [ИНФО] Проверка установки Expo CLI...
expo --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ПРЕДУПРЕЖДЕНИЕ] Expo CLI не установлен. Устанавливаем глобально...
    npm install -g @expo/cli
    if %errorlevel% neq 0 (
        echo [ОШИБКА] Не удалось установить Expo CLI
        pause
        exit /b 1
    )
    echo [УСПЕХ] Expo CLI установлен успешно
)

REM Настройка зависимостей клиента
echo [ИНФО] Настройка зависимостей клиента...
cd client
if %errorlevel% neq 0 (
    echo [ОШИБКА] Директория клиента не найдена
    pause
    exit /b 1
)

echo [ИНФО] Установка зависимостей React Native...
npm install
if %errorlevel% neq 0 (
    echo [ОШИБКА] Не удалось установить зависимости клиента
    pause
    exit /b 1
)

echo [ИНФО] Установка зависимостей для 3D рендеринга...
npm install expo-gl expo-three three @types/three
if %errorlevel% neq 0 (
    echo [ПРЕДУПРЕЖДЕНИЕ] Некоторые 3D зависимости могли не установиться корректно
)

echo [ИНФО] Установка зависимостей навигации и управления состоянием...
npm install @react-navigation/native @react-navigation/stack @react-navigation/bottom-tabs
npm install react-native-screens react-native-safe-area-context
npm install @reduxjs/toolkit react-redux
npm install axios
npm install expo-sqlite @react-native-async-storage/async-storage
if %errorlevel% neq 0 (
    echo [ПРЕДУПРЕЖДЕНИЕ] Некоторые зависимости навигации могли не установиться корректно
)

echo [ИНФО] Установка зависимостей разработки...
npm install --save-dev @types/react @types/react-native typescript
if %errorlevel% neq 0 (
    echo [ПРЕДУПРЕЖДЕНИЕ] Некоторые dev зависимости могли не установиться корректно
)

echo [УСПЕХ] Зависимости клиента установлены успешно
cd ..

REM Настройка зависимостей бэкенда
echo [ИНФО] Настройка зависимостей бэкенда...
cd backend
if %errorlevel% neq 0 (
    echo [ОШИБКА] Директория бэкенда не найдена
    pause
    exit /b 1
)

echo [ИНФО] Установка зависимостей Node.js...
npm install
if %errorlevel% neq 0 (
    echo [ОШИБКА] Не удалось установить зависимости бэкенда
    pause
    exit /b 1
)

echo [УСПЕХ] Зависимости бэкенда установлены успешно
cd ..

REM Создание файлов окружения
echo [ИНФО] Создание файлов окружения...

REM Окружение клиента
if not exist "client\.env" (
    echo # Конфигурация API > client\.env
    echo API_BASE_URL=http://localhost:3000 >> client\.env
    echo API_TIMEOUT=10000 >> client\.env
    echo. >> client\.env
    echo # Конфигурация Yandex Ads (замените на ваши реальные Ad Unit ID) >> client\.env
    echo YANDEX_ADS_BANNER_UNIT_ID=your_banner_unit_id >> client\.env
    echo YANDEX_ADS_INTERSTITIAL_UNIT_ID=your_interstitial_unit_id >> client\.env
    echo YANDEX_ADS_REWARDED_UNIT_ID=your_rewarded_unit_id >> client\.env
    echo. >> client\.env
    echo # Конфигурация приложения >> client\.env
    echo APP_NAME=Touristoo Runner >> client\.env
    echo APP_VERSION=1.0.0 >> client\.env
    echo [УСПЕХ] Файл окружения клиента создан
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] Файл окружения клиента уже существует
)

REM Окружение бэкенда
if not exist "backend\.env" (
    echo # Конфигурация базы данных > backend\.env
    echo DB_HOST=localhost >> backend\.env
    echo DB_PORT=5432 >> backend\.env
    echo DB_NAME=touristoo_runner >> backend\.env
    echo DB_USER=postgres >> backend\.env
    echo DB_PASSWORD=password >> backend\.env
    echo. >> backend\.env
    echo # Конфигурация JWT >> backend\.env
    echo JWT_SECRET=your_jwt_secret_key_here >> backend\.env
    echo JWT_REFRESH_SECRET=your_jwt_refresh_secret_key_here >> backend\.env
    echo JWT_EXPIRES_IN=1h >> backend\.env
    echo JWT_REFRESH_EXPIRES_IN=7d >> backend\.env
    echo. >> backend\.env
    echo # Конфигурация Yandex Cloud (замените на ваши реальные учетные данные) >> backend\.env
    echo YC_ACCESS_KEY_ID=your_access_key_id >> backend\.env
    echo YC_SECRET_ACCESS_KEY=your_secret_access_key >> backend\.env
    echo YC_BUCKET_NAME=touristoo-assets >> backend\.env
    echo YC_REGION=ru-central1 >> backend\.env
    echo. >> backend\.env
    echo # Конфигурация Yandex Ads (замените на ваши реальные Ad Unit ID) >> backend\.env
    echo YANDEX_ADS_BANNER_UNIT_ID=your_banner_unit_id >> backend\.env
    echo YANDEX_ADS_INTERSTITIAL_UNIT_ID=your_interstitial_unit_id >> backend\.env
    echo YANDEX_ADS_REWARDED_UNIT_ID=your_rewarded_unit_id >> backend\.env
    echo. >> backend\.env
    echo # Конфигурация сервера >> backend\.env
    echo PORT=3000 >> backend\.env
    echo NODE_ENV=development >> backend\.env
    echo ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8081 >> backend\.env
    echo [УСПЕХ] Файл окружения бэкенда создан
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] Файл окружения бэкенда уже существует
)

REM Создание полезных скриптов
echo [ИНФО] Создание полезных скриптов...

REM Скрипт запуска разработки
echo @echo off > запуск-разработки.bat
echo echo 🚀 Запуск среды разработки Touristoo Runner... >> запуск-разработки.bat
echo. >> запуск-разработки.bat
echo echo Запуск сервера бэкенда... >> запуск-разработки.bat
echo start "Бэкенд" cmd /k "cd backend && npm run dev" >> запуск-разработки.bat
echo. >> запуск-разработки.bat
echo echo Запуск React Native клиента... >> запуск-разработки.bat
echo start "Клиент" cmd /k "cd client && npm start" >> запуск-разработки.bat
echo. >> запуск-разработки.bat
echo echo Среда разработки запущена! >> запуск-разработки.bat
echo pause >> запуск-разработки.bat

REM Скрипт сборки
echo @echo off > сборка.bat
echo echo 🔨 Сборка Touristoo Runner... >> сборка.bat
echo. >> сборка.bat
echo echo Сборка бэкенда... >> сборка.bat
echo cd backend && npm run build >> сборка.bat
echo. >> сборка.bat
echo echo Сборка клиента... >> сборка.bat
echo cd ../client && npm run build >> сборка.bat
echo. >> сборка.bat
echo echo ✅ Сборка завершена! >> сборка.bat
echo pause >> сборка.bat

REM Скрипт тестирования
echo @echo off > тестирование.bat
echo echo 🧪 Запуск тестов... >> тестирование.bat
echo. >> тестирование.bat
echo echo Тестирование бэкенда... >> тестирование.bat
echo cd backend && npm test >> тестирование.bat
echo. >> тестирование.bat
echo echo Тестирование клиента... >> тестирование.bat
echo cd ../client && npm test >> тестирование.bat
echo. >> тестирование.bat
echo echo ✅ Тестирование завершено! >> тестирование.bat
echo pause >> тестирование.bat

echo [УСПЕХ] Полезные скрипты созданы

echo.
echo 🎉 Настройка завершена успешно!
echo.
echo Следующие шаги:
echo 1. Настройте ваши учетные данные Yandex Cloud в файлах .env
echo 2. Настройте ваши Yandex Ads Ad Unit ID
echo 3. Запустите 'запуск-разработки.bat' для запуска среды разработки
echo 4. Следуйте руководству НАСТРОЙКА_YANDEX_CLOUD.md для развертывания в продакшене
echo.
echo Полезные команды:
echo   запуск-разработки.bat  - Запуск среды разработки
echo   сборка.bat             - Сборка проекта
echo   тестирование.bat       - Запуск тестов
echo.
echo Удачной разработки! 🚀
pause
