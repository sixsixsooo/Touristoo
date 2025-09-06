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

REM Запускаем приложение
echo Запуск приложения...
flutter run
if %errorlevel% neq 0 (
    echo Ошибка при запуске приложения.
    pause
    exit /b 1
)

pause
