# Repository Info

- Name: Mobile Phone Sales Management System (Flutter)
- Platforms: Android, iOS, Web, Windows, macOS, Linux (Flutter multi-platform)
- Core packages: firebase_core, firebase_auth, cloud_firestore, provider, intl, image_picker

## Firebase configuration
- Android: google-services.json present at android/app/google-services.json
- iOS: GoogleService-Info.plist not found (add to ios/Runner/)
- Web/Windows/Linux/macOS: firebase_options.dart not found (generate with FlutterFire)

### Generate firebase_options.dart
1. dart pub global activate flutterfire_cli
2. flutterfire configure

This will create lib/firebase_options.dart and configure platforms.

## SDK constraints
- pubspec.yaml uses: sdk ">=3.3.0 <4.0.0" (compatible with recent Flutter stable)

## Typical run steps
1. flutter clean
2. flutter pub get
3. flutter run -d <device>

## Notes
- main.dart initializes Firebase with default options so Android/iOS will work using native configs. Web/desktop still require firebase_options.dart.
- Ensure Firestore security rules and Authentication providers are set in Firebase Console.