# Touristoo Runner

A 3D endless runner game built with Flutter for RuStore, featuring Yandex Cloud integration and YooKassa payments.

## Features

- 🎮 **3D Graphics**: Immersive 3D gameplay with smooth animations
- 🏃 **Endless Runner**: Procedurally generated obstacles and power-ups
- 🏆 **Leaderboards**: Compete with players worldwide
- 🛍️ **Shop System**: Unlock new skins and purchase coin packs
- 💰 **YooKassa Integration**: Secure payment processing
- ☁️ **Yandex Cloud**: Backend services and analytics
- 📱 **RuStore Ready**: Optimized for Russian app store
- 🎵 **Audio System**: Dynamic music and sound effects
- 📊 **Analytics**: Comprehensive game analytics

## Tech Stack

- **Frontend**: Flutter 3.10+
- **3D Graphics**: Custom 3D rendering with Flutter
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Yandex Cloud Functions
- **Database**: PostgreSQL
- **Payments**: YooKassa
- **Analytics**: Yandex AppMetrica, Firebase Analytics
- **Storage**: Hive, SharedPreferences

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── navigation/      # App routing
│   ├── providers/       # State management
│   ├── services/        # Core services
│   └── theme/           # App theming
├── features/
│   ├── auth/            # Authentication
│   ├── game/            # Game logic and 3D rendering
│   ├── home/            # Home screen
│   ├── leaderboard/     # Leaderboards
│   ├── profile/         # User profile
│   ├── settings/        # App settings
│   └── shop/            # In-app purchases
└── main.dart           # App entry point
```

## Getting Started

### Prerequisites

- Flutter 3.10 or higher
- Dart 3.0 or higher
- Android Studio / VS Code
- Android SDK 21+
- iOS 12.0+ (for iOS development)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/touristoo-runner.git
   cd touristoo-runner
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure environment**

   - Copy `lib/core/config/app_config.dart.example` to `lib/core/config/app_config.dart`
   - Update API keys and configuration values

5. **Run the app**
   ```bash
   flutter run
   ```

## Configuration

### Yandex Cloud Setup

1. Create a Yandex Cloud account
2. Set up Cloud Functions
3. Configure API keys in `app_config.dart`
4. Set up database connection

### YooKassa Setup

1. Register with YooKassa
2. Get your Shop ID and Secret Key
3. Configure payment settings in `app_config.dart`

### RuStore Preparation

1. Register as a developer on RuStore
2. Create app listing
3. Configure app signing
4. Upload APK/AAB files

## Game Features

### 3D Graphics

- Custom 3D rendering engine
- Smooth 60 FPS gameplay
- Dynamic lighting and shadows
- Particle effects

### Gameplay

- Lane-based running mechanics
- Obstacle avoidance (jump, slide, duck)
- Power-up collection
- Progressive difficulty
- Score and distance tracking

### Progression System

- Player levels and experience
- Unlockable skins and characters
- Achievement system
- Daily challenges

### Social Features

- Global leaderboards
- Score sharing
- Player profiles
- Friend system

## API Endpoints

### Authentication

- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/refresh` - Token refresh

### Game Data

- `GET /api/leaderboard` - Get leaderboard
- `POST /api/game/save` - Save game progress
- `GET /api/player/profile` - Get player profile

### Shop

- `GET /api/shop/skins` - Get available skins
- `POST /api/shop/purchase` - Process purchase
- `GET /api/shop/coin-packs` - Get coin packs

## Building for Production

### Android (RuStore)

1. **Generate signed APK**

   ```bash
   flutter build apk --release
   ```

2. **Generate App Bundle**

   ```bash
   flutter build appbundle --release
   ```

3. **Upload to RuStore**
   - Use RuStore Developer Console
   - Upload AAB file
   - Configure store listing

### iOS (App Store)

1. **Build for iOS**

   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace`
   - Archive and upload to App Store Connect

## Performance Optimization

- **3D Rendering**: Optimized for 60 FPS on mid-range devices
- **Memory Management**: Efficient object pooling
- **Asset Optimization**: Compressed textures and models
- **Network**: Cached API responses
- **Battery**: Optimized rendering loops

## Analytics

### Yandex AppMetrica

- User behavior tracking
- Custom events
- Crash reporting
- Performance monitoring

### Firebase Analytics

- Game progression tracking
- In-app purchase analytics
- User engagement metrics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:

- Create an issue on GitHub
- Contact: support@touristoo.run
- Documentation: https://docs.touristoo.run

## Roadmap

- [ ] Multiplayer mode
- [ ] New game modes
- [ ] AR features
- [ ] Social features
- [ ] More 3D environments
- [ ] Custom character creation

---

**Touristoo Runner** - Where every step is an adventure! 🏃‍♂️✨
