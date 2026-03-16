# Passcode & Face ID Security Feature

This feature adds local passcode protection with Face ID/Touch ID support to the LifeOS app.

## Features Implemented

1. **Set Local Passcode**: Users can set a 6-digit passcode to protect the app
2. **Face ID/Touch ID Support**: Optional biometric authentication that can be enabled when setting the passcode
3. **Splash Screen Integration**: The app automatically shows the unlock screen when a passcode is set
4. **Security Settings Page**: Manage passcode and biometric settings from the settings menu

## File Structure

```
lib/features/security/
├── data/
│   ├── datasources/
│   │   └── security_local_storage.dart     # Local storage for passcode & biometric settings
│   └── repositories/
│       └── security_repository_impl.dart    # Repository implementation
├── domain/
│   ├── entities/
│   │   └── security_settings.dart           # Security settings model
│   └── repositories/
│       └── security_repository.dart         # Repository interface
└── presentation/
    ├── bloc/
    │   ├── security_bloc.dart               # BLoC for managing security state
    │   ├── security_event.dart              # Security events
    │   └── security_state.dart              # Security states
    ├── pages/
    │   ├── security_settings_page.dart      # Main security settings page
    │   ├── set_passcode_page.dart           # Page to set/change passcode
    │   └── unlock_page.dart                 # Unlock screen shown on app launch
    └── widgets/
        └── passcode_input.dart              # Reusable passcode input widget with number pad
```

## How It Works

### 1. Setting a Passcode

- Navigate to **Other** tab → **Passcode** (in Settings section)
- Tap "Set Passcode"
- Enter a 6-digit passcode
- Confirm the passcode by re-entering it
- Optionally enable Face ID/Touch ID
- Passcode is stored locally using SharedPreferences

### 2. Unlocking the App

When the app is opened:
1. Splash screen checks if a passcode is set
2. If yes, shows the unlock page
3. User can unlock using:
   - Passcode (manual entry)
   - Face ID/Touch ID (if enabled - auto-triggered)
4. Upon successful unlock, the app proceeds to the main page

### 3. Security Settings

From the Security Settings page, users can:
- Set a passcode (if not set)
- Change the current passcode
- Remove the passcode
- View biometric authentication status

## Technical Details

### Dependencies Added

- `local_auth: ^2.3.0` - For biometric authentication (Face ID/Touch ID)

### iOS Permissions

Added to `ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>LifeOS uses Face ID to unlock the app</string>
```

### Architecture

- **Clean Architecture**: Follows the existing project structure with data/domain/presentation layers
- **BLoC Pattern**: Uses flutter_bloc for state management
- **Repository Pattern**: Separates data access logic from business logic
- **Dependency Injection**: Registered in `injection.dart` using GetIt

### State Management

The `SecurityBloc` manages:
- `SecurityLocked` - App is locked, waiting for unlock
- `SecurityUnlocked` - User successfully unlocked
- `SecuritySettingsLoaded` - Security settings loaded
- `SecurityPasscodeSet` - Passcode successfully set
- `SecurityPasscodeCleared` - Passcode removed
- `SecurityVerificationFailed` - Invalid passcode entered
- `SecurityError` - Error occurred

### Storage

Passcode and settings are stored in SharedPreferences with keys:
- `local_passcode` - The 6-digit passcode (plain text, locally stored)
- `biometric_enabled` - Boolean flag for biometric authentication

## UI/UX

- **Follows shadcn_flutter design system** - Consistent with the rest of the app
- **Number pad interface** - Easy-to-use number pad for passcode entry
- **Visual feedback** - Dots show passcode progress, error states highlighted in red
- **Biometric auto-trigger** - Face ID/Touch ID automatically attempts when enabled
- **Settings integration** - Accessible from the main settings menu

## Usage Example

```dart
// Navigate to security settings
Navigator.of(context).push(
  CupertinoPageRoute(
    builder: (context) => const SecuritySettingsPage(),
  ),
);
```

## Future Enhancements

- Encrypted passcode storage
- Passcode attempt limits
- Auto-lock timer options
- Fingerprint on Android devices
- Pattern lock alternative
