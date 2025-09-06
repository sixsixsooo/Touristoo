@echo off
echo Запуск Touristoo для тестирования на мобильном устройстве...
echo.

REM Проверяем наличие Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Ошибка: Flutter не найден. Установите Flutter и добавьте его в PATH.
    pause
    exit /b 1
)

REM Получаем IP адрес компьютера
echo Получение IP адреса компьютера...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set IP=%%a
    goto :found
)
:found
set IP=%IP: =%

echo IP адрес компьютера: %IP%
echo.

REM Получаем зависимости
echo Получение зависимостей...
flutter pub get
if %errorlevel% neq 0 (
    echo Ошибка при получении зависимостей.
    pause
    exit /b 1
)

REM Запускаем веб-сервер
echo Запуск веб-сервера...
echo.
echo ========================================
echo   ТЕСТИРОВАНИЕ НА МОБИЛЬНОМ УСТРОЙСТВЕ
echo ========================================
echo.
echo 1. Убедитесь, что мобильное устройство подключено к той же Wi-Fi сети
echo 2. Откройте в мобильном браузере: http://%IP%:8080
echo 3. Или отсканируйте QR-код (если поддерживается)
echo.
echo Для остановки нажмите Ctrl+C
echo.

flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
if %errorlevel% neq 0 (
    echo Ошибка при запуске веб-сервера.
    pause
    exit /b 1
)

pause
