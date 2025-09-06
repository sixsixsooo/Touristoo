@echo off
echo 🚀 Запуск проекта Touristoo Runner...

echo [ИНФО] Проверка установки зависимостей...
if not exist "node_modules" (
    echo [ОШИБКА] Зависимости не установлены. Запустите сначала исправить-зависимости.bat
    pause
    exit /b 1
)

if not exist "backend\node_modules" (
    echo [ОШИБКА] Зависимости бэкенда не установлены. Запустите сначала исправить-зависимости.bat
    pause
    exit /b 1
)

echo [ИНФО] Копирование файлов окружения...
if not exist ".env" copy "client.env" ".env" >nul 2>&1
if not exist "backend\.env" copy "backend\env.local" "backend\.env" >nul 2>&1

echo [ИНФО] Запуск бэкенда в отдельном окне...
start "Touristoo Backend" cmd /k "cd backend && npm run dev"

echo [ИНФО] Ожидание запуска бэкенда (5 секунд)...
timeout /t 5 /nobreak >nul

echo [ИНФО] Запуск клиента...
npm start

pause
