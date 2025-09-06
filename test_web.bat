@echo off
echo Запуск Touristoo в веб-браузере для тестирования...
echo.

REM Проверяем наличие Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Ошибка: Flutter не найден. Установите Flutter и добавьте его в PATH.
    pause
    exit /b 1
)

REM Получаем зависимости
echo Получение зависимостей...
flutter pub get
if %errorlevel% neq 0 (
    echo Ошибка при получении зависимостей.
    pause
    exit /b 1
)

REM Запускаем в веб-браузере
echo Запуск в веб-браузере...
echo Приложение откроется в Chrome по адресу: http://localhost:8080
echo.
echo Для тестирования на мобильном устройстве:
echo 1. Узнайте IP адрес вашего компьютера
echo 2. Откройте в мобильном браузере: http://YOUR_IP:8080
echo.

flutter run -d web-server --web-port 8080
if %errorlevel% neq 0 (
    echo Ошибка при запуске веб-сервера.
    pause
    exit /b 1
)

pause
