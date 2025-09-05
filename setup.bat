@echo off
REM Touristoo Runner Game Setup Script for Windows
REM This script sets up the development environment for the Touristoo Runner mobile game

echo 🎮 Setting up Touristoo Runner Game Development Environment...

REM Check if Node.js is installed
echo [INFO] Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
)
echo [SUCCESS] Node.js is installed

REM Check if npm is installed
echo [INFO] Checking npm installation...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed. Please install npm.
    pause
    exit /b 1
)
echo [SUCCESS] npm is installed

REM Check if Expo CLI is installed
echo [INFO] Checking Expo CLI installation...
expo --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Expo CLI is not installed. Installing globally...
    npm install -g @expo/cli
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Expo CLI
        pause
        exit /b 1
    )
    echo [SUCCESS] Expo CLI installed successfully
)

REM Setup client dependencies
echo [INFO] Setting up client dependencies...
cd client
if %errorlevel% neq 0 (
    echo [ERROR] Client directory not found
    pause
    exit /b 1
)

echo [INFO] Installing React Native dependencies...
npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install client dependencies
    pause
    exit /b 1
)

echo [INFO] Installing 3D rendering dependencies...
npm install expo-gl expo-three three @types/three
if %errorlevel% neq 0 (
    echo [WARNING] Some 3D dependencies might not have installed correctly
)

echo [INFO] Installing navigation and state management dependencies...
npm install @react-navigation/native @react-navigation/stack @react-navigation/bottom-tabs
npm install react-native-screens react-native-safe-area-context
npm install @reduxjs/toolkit react-redux
npm install axios
npm install expo-sqlite @react-native-async-storage/async-storage
if %errorlevel% neq 0 (
    echo [WARNING] Some navigation dependencies might not have installed correctly
)

echo [INFO] Installing development dependencies...
npm install --save-dev @types/react @types/react-native typescript
if %errorlevel% neq 0 (
    echo [WARNING] Some dev dependencies might not have installed correctly
)

echo [SUCCESS] Client dependencies installed successfully
cd ..

REM Setup backend dependencies
echo [INFO] Setting up backend dependencies...
cd backend
if %errorlevel% neq 0 (
    echo [ERROR] Backend directory not found
    pause
    exit /b 1
)

echo [INFO] Installing Node.js dependencies...
npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install backend dependencies
    pause
    exit /b 1
)

echo [SUCCESS] Backend dependencies installed successfully
cd ..

REM Create environment files
echo [INFO] Creating environment files...

REM Client environment
if not exist "client\.env" (
    echo # API Configuration > client\.env
    echo API_BASE_URL=http://localhost:3000 >> client\.env
    echo API_TIMEOUT=10000 >> client\.env
    echo. >> client\.env
    echo # Yandex Ads Configuration (replace with your actual Ad Unit IDs) >> client\.env
    echo YANDEX_ADS_BANNER_UNIT_ID=your_banner_unit_id >> client\.env
    echo YANDEX_ADS_INTERSTITIAL_UNIT_ID=your_interstitial_unit_id >> client\.env
    echo YANDEX_ADS_REWARDED_UNIT_ID=your_rewarded_unit_id >> client\.env
    echo. >> client\.env
    echo # App Configuration >> client\.env
    echo APP_NAME=Touristoo Runner >> client\.env
    echo APP_VERSION=1.0.0 >> client\.env
    echo [SUCCESS] Client environment file created
) else (
    echo [WARNING] Client environment file already exists
)

REM Backend environment
if not exist "backend\.env" (
    echo # Database Configuration > backend\.env
    echo DB_HOST=localhost >> backend\.env
    echo DB_PORT=5432 >> backend\.env
    echo DB_NAME=touristoo_runner >> backend\.env
    echo DB_USER=postgres >> backend\.env
    echo DB_PASSWORD=password >> backend\.env
    echo. >> backend\.env
    echo # JWT Configuration >> backend\.env
    echo JWT_SECRET=your_jwt_secret_key_here >> backend\.env
    echo JWT_REFRESH_SECRET=your_jwt_refresh_secret_key_here >> backend\.env
    echo JWT_EXPIRES_IN=1h >> backend\.env
    echo JWT_REFRESH_EXPIRES_IN=7d >> backend\.env
    echo. >> backend\.env
    echo # Yandex Cloud Configuration (replace with your actual credentials) >> backend\.env
    echo YC_ACCESS_KEY_ID=your_access_key_id >> backend\.env
    echo YC_SECRET_ACCESS_KEY=your_secret_access_key >> backend\.env
    echo YC_BUCKET_NAME=touristoo-assets >> backend\.env
    echo YC_REGION=ru-central1 >> backend\.env
    echo. >> backend\.env
    echo # Yandex Ads Configuration (replace with your actual Ad Unit IDs) >> backend\.env
    echo YANDEX_ADS_BANNER_UNIT_ID=your_banner_unit_id >> backend\.env
    echo YANDEX_ADS_INTERSTITIAL_UNIT_ID=your_interstitial_unit_id >> backend\.env
    echo YANDEX_ADS_REWARDED_UNIT_ID=your_rewarded_unit_id >> backend\.env
    echo. >> backend\.env
    echo # Server Configuration >> backend\.env
    echo PORT=3000 >> backend\.env
    echo NODE_ENV=development >> backend\.env
    echo ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8081 >> backend\.env
    echo [SUCCESS] Backend environment file created
) else (
    echo [WARNING] Backend environment file already exists
)

REM Create useful scripts
echo [INFO] Creating useful scripts...

REM Start development script
echo @echo off > start-dev.bat
echo echo 🚀 Starting Touristoo Runner Development Environment... >> start-dev.bat
echo. >> start-dev.bat
echo echo Starting backend server... >> start-dev.bat
echo start "Backend" cmd /k "cd backend && npm run dev" >> start-dev.bat
echo. >> start-dev.bat
echo echo Starting React Native client... >> start-dev.bat
echo start "Client" cmd /k "cd client && npm start" >> start-dev.bat
echo. >> start-dev.bat
echo echo Development environment started! >> start-dev.bat
echo pause >> start-dev.bat

REM Build script
echo @echo off > build.bat
echo echo 🔨 Building Touristoo Runner... >> build.bat
echo. >> build.bat
echo echo Building backend... >> build.bat
echo cd backend && npm run build >> build.bat
echo. >> build.bat
echo echo Building client... >> build.bat
echo cd ../client && npm run build >> build.bat
echo. >> build.bat
echo echo ✅ Build completed! >> build.bat
echo pause >> build.bat

REM Test script
echo @echo off > test.bat
echo echo 🧪 Running tests... >> test.bat
echo. >> test.bat
echo echo Testing backend... >> test.bat
echo cd backend && npm test >> test.bat
echo. >> test.bat
echo echo Testing client... >> test.bat
echo cd ../client && npm test >> test.bat
echo. >> test.bat
echo echo ✅ Tests completed! >> test.bat
echo pause >> test.bat

echo [SUCCESS] Useful scripts created

echo.
echo 🎉 Setup completed successfully!
echo.
echo Next steps:
echo 1. Configure your Yandex Cloud credentials in the .env files
echo 2. Set up your Yandex Ads Ad Unit IDs
echo 3. Run 'start-dev.bat' to start the development environment
echo 4. Follow the YANDEX_CLOUD_SETUP.md guide for production deployment
echo.
echo Useful commands:
echo   start-dev.bat  - Start development environment
echo   build.bat      - Build the project
echo   test.bat       - Run tests
echo.
echo Happy coding! 🚀
pause
