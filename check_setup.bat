@echo off
echo Проверка готовности к запуску Touristoo...
echo.

REM Проверяем Flutter
echo [1/4] Проверка Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter не найден!
    echo Установите Flutter: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
) else (
    echo ✅ Flutter установлен
)

REM Проверяем зависимости
echo.
echo [2/4] Проверка зависимостей...
if not exist "pubspec.yaml" (
    echo ❌ pubspec.yaml не найден!
    pause
    exit /b 1
) else (
    echo ✅ pubspec.yaml найден
)

REM Устанавливаем зависимости
echo.
echo [3/4] Установка зависимостей...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Ошибка при установке зависимостей!
    pause
    exit /b 1
) else (
    echo ✅ Зависимости установлены
)

REM Проверяем доступные устройства
echo.
echo [4/4] Проверка доступных устройств...
flutter devices
echo.

echo ========================================
echo   СИСТЕМА ГОТОВА К ЗАПУСКУ!
echo ========================================
echo.
echo Доступные команды:
echo - test_web.bat     - Запуск в веб-браузере
echo - test_mobile.bat  - Запуск для мобильного тестирования
echo - run.bat          - Обычный запуск Flutter
echo - build.bat        - Сборка APK/AAB
echo.

pause
