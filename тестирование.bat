@echo off
echo 🧪 Тестирование проекта Touristoo Runner...

echo [ИНФО] Тестирование клиента...
npm test

echo [ИНФО] Тестирование бэкенда...
cd backend
npm test
cd ..

echo [УСПЕХ] Тестирование завершено!
pause
