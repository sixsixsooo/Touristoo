@echo off
echo 🔍 Проверка проекта Touristoo Runner...

echo [ИНФО] Проверка структуры проекта...
if not exist "src" (
    echo [ОШИБКА] Директория src не найдена
    exit /b 1
)

if not exist "backend" (
    echo [ОШИБКА] Директория backend не найдена
    exit /b 1
)

echo [ИНФО] Проверка зависимостей клиента...
if not exist "node_modules" (
    echo [ОШИБКА] Зависимости клиента не установлены
    exit /b 1
)

echo [ИНФО] Проверка зависимостей бэкенда...
if not exist "backend\node_modules" (
    echo [ОШИБКА] Зависимости бэкенда не установлены
    exit /b 1
)

echo [ИНФО] Проверка файлов конфигурации...
if not exist "package.json" (
    echo [ОШИБКА] package.json не найден
    exit /b 1
)

if not exist "backend\package.json" (
    echo [ОШИБКА] backend\package.json не найден
    exit /b 1
)

if not exist "app.json" (
    echo [ОШИБКА] app.json не найден
    exit /b 1
)

echo [ИНФО] Проверка TypeScript конфигурации...
npx tsc --noEmit
if %errorlevel% neq 0 (
    echo [ПРЕДУПРЕЖДЕНИЕ] Обнаружены ошибки TypeScript
)

echo [ИНФО] Проверка ESLint...
npx eslint src --ext .ts,.tsx --max-warnings 0
if %errorlevel% neq 0 (
    echo [ПРЕДУПРЕЖДЕНИЕ] Обнаружены предупреждения ESLint
)

echo [УСПЕХ] Проект готов к запуску!
echo.
echo Доступные команды:
echo   запуск-проекта.bat    - Запуск полного проекта
echo   npm start            - Запуск только клиента
echo   cd backend && npm run dev  - Запуск только бэкенда
echo   тестирование.bat     - Запуск тестов
echo.
pause
