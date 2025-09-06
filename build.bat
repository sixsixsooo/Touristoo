@echo off
echo Сборка Flutter APK для RuStore...
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

REM Очищаем предыдущую сборку
echo Очистка предыдущей сборки...
flutter clean
flutter pub get

REM Собираем APK
echo Сборка APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo Ошибка при сборке APK.
    pause
    exit /b 1
)

REM Собираем AAB для RuStore
echo Сборка AAB для RuStore...
flutter build appbundle --release
if %errorlevel% neq 0 (
    echo Ошибка при сборке AAB.
    pause
    exit /b 1
)

echo.
echo Сборка завершена успешно!
echo APK: build\app\outputs\flutter-apk\app-release.apk
echo AAB: build\app\outputs\bundle\release\app-release.aab
echo.
echo Теперь можно загрузить AAB в RuStore.
echo.
pause
