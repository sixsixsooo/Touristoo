# Настройка для RuStore

Этот документ описывает процесс настройки приложения Touristoo Runner для публикации в RuStore.

## Требования RuStore

### 1. Регистрация разработчика

- Зарегистрируйтесь на [RuStore Developer Console](https://developer.rustore.ru/)
- Подтвердите личность и заполните все необходимые данные
- Получите доступ к панели разработчика

### 2. Создание приложения

- Создайте новое приложение в консоли RuStore
- Укажите название: "Touristoo Runner"
- Выберите категорию: "Игры" > "Аркады"
- Укажите возрастной рейтинг: 3+

### 3. Настройка подписи

- Создайте keystore для подписи APK/AAB
- Загрузите сертификат в RuStore
- Настройте автоматическую подпись

## Конфигурация приложения

### 1. AndroidManifest.xml

```xml
<application
    android:label="Touristoo Runner"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">

    <!-- RuStore specific permissions -->
    <uses-permission android:name="ru.rustore.permission.BILLING" />

    <!-- Queries for RuStore -->
    <queries>
        <package android:name="ru.rustore.rustoreapp" />
    </queries>
</application>
```

### 2. Подпись APK

```bash
# Создание keystore
keytool -genkey -v -keystore touristoo-release-key.keystore -alias touristoo -keyalg RSA -keysize 2048 -validity 10000

# Подпись APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore touristoo-release-key.keystore app-release-unsigned.apk touristoo

# Выравнивание APK
zipalign -v 4 app-release-unsigned.apk app-release-signed.apk
```

### 3. Сборка для RuStore

```bash
# Сборка AAB (рекомендуется)
flutter build appbundle --release

# Сборка APK
flutter build apk --release --target-platform android-arm64
```

## Интеграция с RuStore SDK

### 1. Добавление зависимостей

```gradle
dependencies {
    implementation 'ru.rustore:rustore-sdk:1.0.0'
    implementation 'ru.rustore:rustore-billing:1.0.0'
}
```

### 2. Инициализация SDK

```dart
import 'package:rustore_sdk/rustore_sdk.dart';

class RuStoreService {
  static Future<void> initialize() async {
    await RuStoreSDK.initialize();
    await RuStoreBilling.initialize();
  }
}
```

### 3. Обработка платежей

```dart
class PaymentService {
  static Future<void> processPayment(String productId) async {
    try {
      final purchase = await RuStoreBilling.purchase(productId);
      if (purchase.isSuccessful) {
        // Обработка успешной покупки
        await _handleSuccessfulPurchase(purchase);
      }
    } catch (e) {
      // Обработка ошибки
      print('Payment failed: $e');
    }
  }
}
```

## Метаданные приложения

### 1. Описание на русском языке

```
Touristoo Runner - это захватывающая 3D игра-раннер, которая перенесет вас в мир приключений.

Особенности:
• Потрясающая 3D графика
• Увлекательный геймплей
• Система достижений
• Таблица лидеров
• Магазин скинов
• Интеграция с Яндекс Cloud

Бегите, прыгайте, уклоняйтесь от препятствий и собирайте монеты в этом захватывающем приключении!
```

### 2. Скриншоты

- Подготовьте скриншоты для разных экранов
- Минимум 2 скриншота, рекомендуется 5-8
- Разрешение: 1080x1920 или выше
- Формат: PNG или JPEG

### 3. Иконка приложения

- Размер: 512x512 пикселей
- Формат: PNG
- Прозрачный фон не допускается
- Должна быть узнаваемой в маленьком размере

## Тестирование

### 1. Внутреннее тестирование

- Загрузите AAB в RuStore Console
- Добавьте тестовых пользователей
- Протестируйте все функции

### 2. Закрытое тестирование

- Пригласите бета-тестеров
- Соберите отзывы
- Исправьте найденные ошибки

### 3. Открытое тестирование

- Публичный релиз для ограниченной аудитории
- Мониторинг отзывов и рейтингов
- Подготовка к полному релизу

## Публикация

### 1. Подготовка к релизу

- Убедитесь, что все тесты пройдены
- Обновите версию приложения
- Подготовьте описание обновления

### 2. Загрузка в RuStore

- Загрузите финальный AAB
- Заполните все обязательные поля
- Отправьте на модерацию

### 3. Модерация

- Ожидайте проверки RuStore (1-3 дня)
- Отвечайте на вопросы модераторов
- Вносите исправления при необходимости

## Поддержка после релиза

### 1. Мониторинг

- Отслеживайте отзывы пользователей
- Анализируйте метрики использования
- Мониторьте краши и ошибки

### 2. Обновления

- Регулярно выпускайте обновления
- Исправляйте найденные ошибки
- Добавляйте новый контент

### 3. Поддержка пользователей

- Отвечайте на отзывы в RuStore
- Предоставляйте техническую поддержку
- Собирайте обратную связь

## Контакты

- **Email**: support@touristoo.run
- **Telegram**: @touristoo_support
- **Website**: https://touristoo.run

## Полезные ссылки

- [RuStore Developer Console](https://developer.rustore.ru/)
- [Документация RuStore](https://docs.rustore.ru/)
- [Flutter для Android](https://docs.flutter.dev/deployment/android)
- [Подпись приложений](https://developer.android.com/studio/publish/app-signing)
