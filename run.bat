@echo off
echo Запуск Flutter проекта Touristoo...
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

REM Показываем доступные устройства
echo.
echo Доступные устройства:
flutter devices
echo.

REM Запускаем приложение
echo Запуск приложения...
echo Для выбора устройства используйте: flutter run -d <device_id>
echo.

flutter run
if %errorlevel% neq 0 (
    echo Ошибка при запуске приложения.
    echo.
    echo Попробуйте:
    echo - test_web.bat для запуска в браузере
    echo - test_mobile.bat для мобильного тестирования
    pause
    exit /b 1
)

pause
