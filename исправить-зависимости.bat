@echo off
echo 🔧 Исправление конфликтов зависимостей Touristoo Runner...

echo [ИНФО] Очистка кэша npm...
npm cache clean --force

echo [ИНФО] Удаление node_modules и package-lock.json...
if exist "node_modules" rmdir /s /q "node_modules"
if exist "package-lock.json" del "package-lock.json"
if exist "backend\node_modules" rmdir /s /q "backend\node_modules"
if exist "backend\package-lock.json" del "backend\package-lock.json"

echo [ИНФО] Установка зависимостей клиента с совместимыми версиями...
npm install --legacy-peer-deps

echo [ИНФО] Установка зависимостей бэкенда...
cd backend
npm install --legacy-peer-deps
cd ..

echo [ИНФО] Копирование файлов окружения...
if not exist ".env" copy "client.env" ".env"
if not exist "backend\.env" copy "backend\env.local" "backend\.env"

echo [ИНФО] Проверка установки expo-three и three...
npm list expo-three three

echo [УСПЕХ] Зависимости исправлены! Теперь можно запускать проект.
echo.
echo Следующие команды:
echo   npm start          - Запуск клиента
echo   cd backend && npm run dev  - Запуск бэкенда
pause
