#!/bin/bash

# Touristoo Runner Game Setup Script
# This script sets up the development environment for the Touristoo Runner mobile game

set -e

echo "🎮 Setting up Touristoo Runner Game Development Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Node.js is installed
check_node() {
    print_status "Checking Node.js installation..."
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_success "Node.js is installed: $NODE_VERSION"
    else
        print_error "Node.js is not installed. Please install Node.js 18+ from https://nodejs.org/"
        exit 1
    fi
}

# Check if npm is installed
check_npm() {
    print_status "Checking npm installation..."
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_success "npm is installed: $NPM_VERSION"
    else
        print_error "npm is not installed. Please install npm."
        exit 1
    fi
}

# Check if Expo CLI is installed
check_expo() {
    print_status "Checking Expo CLI installation..."
    if command -v expo &> /dev/null; then
        EXPO_VERSION=$(expo --version)
        print_success "Expo CLI is installed: $EXPO_VERSION"
    else
        print_warning "Expo CLI is not installed. Installing globally..."
        npm install -g @expo/cli
        print_success "Expo CLI installed successfully"
    fi
}

# Setup client dependencies
setup_client() {
    print_status "Setting up client dependencies..."
    cd client
    
    # Install dependencies
    print_status "Installing React Native dependencies..."
    npm install
    
    # Install additional dependencies for 3D rendering
    print_status "Installing 3D rendering dependencies..."
    npm install expo-gl expo-three three @types/three
    
    # Install additional dependencies for navigation and state management
    print_status "Installing navigation and state management dependencies..."
    npm install @react-navigation/native @react-navigation/stack @react-navigation/bottom-tabs
    npm install react-native-screens react-native-safe-area-context
    npm install @reduxjs/toolkit react-redux
    npm install axios
    npm install expo-sqlite @react-native-async-storage/async-storage
    
    # Install development dependencies
    print_status "Installing development dependencies..."
    npm install --save-dev @types/react @types/react-native typescript
    
    print_success "Client dependencies installed successfully"
    cd ..
}

# Setup backend dependencies
setup_backend() {
    print_status "Setting up backend dependencies..."
    cd backend
    
    # Install dependencies
    print_status "Installing Node.js dependencies..."
    npm install
    
    print_success "Backend dependencies installed successfully"
    cd ..
}

# Create environment files
setup_environment() {
    print_status "Creating environment files..."
    
    # Client environment
    if [ ! -f "client/.env" ]; then
        cat > client/.env << EOF
# API Configuration
API_BASE_URL=http://localhost:3000
API_TIMEOUT=10000

# Yandex Ads Configuration (replace with your actual Ad Unit IDs)
YANDEX_ADS_BANNER_UNIT_ID=your_banner_unit_id
YANDEX_ADS_INTERSTITIAL_UNIT_ID=your_interstitial_unit_id
YANDEX_ADS_REWARDED_UNIT_ID=your_rewarded_unit_id

# App Configuration
APP_NAME=Touristoo Runner
APP_VERSION=1.0.0
EOF
        print_success "Client environment file created"
    else
        print_warning "Client environment file already exists"
    fi
    
    # Backend environment
    if [ ! -f "backend/.env" ]; then
        cat > backend/.env << EOF
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=touristoo_runner
DB_USER=postgres
DB_PASSWORD=password

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_here
JWT_REFRESH_SECRET=your_jwt_refresh_secret_key_here
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Yandex Cloud Configuration (replace with your actual credentials)
YC_ACCESS_KEY_ID=your_access_key_id
YC_SECRET_ACCESS_KEY=your_secret_access_key
YC_BUCKET_NAME=touristoo-assets
YC_REGION=ru-central1

# Yandex Ads Configuration (replace with your actual Ad Unit IDs)
YANDEX_ADS_BANNER_UNIT_ID=your_banner_unit_id
YANDEX_ADS_INTERSTITIAL_UNIT_ID=your_interstitial_unit_id
YANDEX_ADS_REWARDED_UNIT_ID=your_rewarded_unit_id

# Server Configuration
PORT=3000
NODE_ENV=development
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8081
EOF
        print_success "Backend environment file created"
    else
        print_warning "Backend environment file already exists"
    fi
}

# Setup database
setup_database() {
    print_status "Setting up database..."
    
    # Check if PostgreSQL is installed
    if command -v psql &> /dev/null; then
        print_success "PostgreSQL is installed"
        
        # Create database if it doesn't exist
        print_status "Creating database..."
        createdb touristoo_runner 2>/dev/null || print_warning "Database might already exist"
        
        # Run database initialization
        print_status "Initializing database tables..."
        cd backend
        npm run db:init 2>/dev/null || print_warning "Database initialization might have failed"
        cd ..
        
        print_success "Database setup completed"
    else
        print_warning "PostgreSQL is not installed. Please install PostgreSQL and run the database setup manually."
        print_warning "You can also use Docker: docker run --name postgres -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres"
    fi
}

# Create useful scripts
create_scripts() {
    print_status "Creating useful scripts..."
    
    # Start development script
    cat > start-dev.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Touristoo Runner Development Environment..."

# Start backend in background
echo "Starting backend server..."
cd backend && npm run dev &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 3

# Start client
echo "Starting React Native client..."
cd ../client && npm start

# Cleanup on exit
trap "kill $BACKEND_PID" EXIT
EOF
    chmod +x start-dev.sh
    
    # Build script
    cat > build.sh << 'EOF'
#!/bin/bash
echo "🔨 Building Touristoo Runner..."

# Build backend
echo "Building backend..."
cd backend && npm run build

# Build client
echo "Building client..."
cd ../client && npm run build

echo "✅ Build completed!"
EOF
    chmod +x build.sh
    
    # Test script
    cat > test.sh << 'EOF'
#!/bin/bash
echo "🧪 Running tests..."

# Test backend
echo "Testing backend..."
cd backend && npm test

# Test client
echo "Testing client..."
cd ../client && npm test

echo "✅ Tests completed!"
EOF
    chmod +x test.sh
    
    print_success "Useful scripts created"
}

# Main setup function
main() {
    echo "🎮 Touristoo Runner Game Setup"
    echo "=============================="
    echo ""
    
    # Check prerequisites
    check_node
    check_npm
    check_expo
    
    # Setup project
    setup_client
    setup_backend
    setup_environment
    setup_database
    create_scripts
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Configure your Yandex Cloud credentials in the .env files"
    echo "2. Set up your Yandex Ads Ad Unit IDs"
    echo "3. Run './start-dev.sh' to start the development environment"
    echo "4. Follow the YANDEX_CLOUD_SETUP.md guide for production deployment"
    echo ""
    echo "Useful commands:"
    echo "  ./start-dev.sh  - Start development environment"
    echo "  ./build.sh      - Build the project"
    echo "  ./test.sh       - Run tests"
    echo ""
    echo "Happy coding! 🚀"
}

# Run main function
main "$@"
