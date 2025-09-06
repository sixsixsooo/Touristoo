@echo off
echo Удаление Node.js backend...
echo.

REM Удаляем папку backend
if exist "backend" (
    echo Удаляем папку backend...
    rmdir /s /q "backend"
    echo Папка backend удалена.
) else (
    echo Папка backend не найдена.
)

REM Удаляем package.json и package-lock.json из корня
if exist "package.json" (
    echo Удаляем package.json...
    del "package.json"
)

if exist "package-lock.json" (
    echo Удаляем package-lock.json...
    del "package-lock.json"
)

REM Удаляем node_modules
if exist "node_modules" (
    echo Удаляем node_modules...
    rmdir /s /q "node_modules"
)

REM Удаляем Jest конфигурацию
if exist "jest.config.js" (
    echo Удаляем jest.config.js...
    del "jest.config.js"
)

if exist "jest.setup.js" (
    echo Удаляем jest.setup.js...
    del "jest.setup.js"
)

REM Удаляем папку src (React Native)
if exist "src" (
    echo Удаляем папку src...
    rmdir /s /q "src"
)

REM Удаляем app.json
if exist "app.json" (
    echo Удаляем app.json...
    del "app.json"
)

REM Удаляем client.env
if exist "client.env" (
    echo Удаляем client.env...
    del "client.env"
)

echo.
echo Node.js backend успешно удален!
echo Теперь проект использует только VK Cloud Functions.
echo.
pause
