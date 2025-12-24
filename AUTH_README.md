# LifeOS Authentication System

## Overview

This is a complete authentication system for LifeOS with a Laravel backend and Flutter mobile client.

## Backend (Laravel)

### User Model Fields
- `id` - Primary key
- `first_name` - User's first name
- `last_name` - User's last name
- `father_name` - Father's name (nullable)
- `date_of_birth` - Date of birth (nullable)
- `email` - Email address (unique)
- `password` - Hashed password
- `avatar_url` - Profile picture URL (nullable)
- `is_active` - Account status (default: true)
- `last_login_at` - Last login timestamp (nullable)
- `created_at` - Registration date
- `updated_at` - Last update timestamp

### API Endpoints

All endpoints are prefixed with `/api/auth`

#### POST /api/auth/register
Register a new user.

**Request Body:**
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "father_name": "Michael", // optional
  "date_of_birth": "1990-01-01", // optional
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response:**
```json
{
  "user": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "father_name": "Michael",
    "date_of_birth": "1990-01-01",
    "email": "john@example.com",
    "avatar_url": null,
    "is_active": true,
    "last_login_at": null,
    "created_at": "2025-12-24T10:00:00.000000Z",
    "updated_at": "2025-12-24T10:00:00.000000Z"
  },
  "token": "1|..."
}
```

#### POST /api/auth/login
Login an existing user.

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "user": { /* user object */ },
  "token": "2|..."
}
```

#### POST /api/auth/logout
Logout the authenticated user (requires authentication).

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "message": "Logged out successfully"
}
```

#### GET /api/auth/me
Get current authenticated user details (requires authentication).

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "user": { /* user object */ }
}
```

### Running the Backend

```bash
cd lifeos_backend
composer run dev  # Starts Laravel server, queue worker, and Vite
```

The API will be available at `http://localhost:8000`

## Frontend (Flutter)

### Features
- Clean Architecture (Domain, Data, Presentation layers)
- BLoC pattern for state management
- Shadcn UI components with white/black color scheme
- Token-based authentication
- Persistent login (stored in SharedPreferences)
- Form validation
- Error handling with toast messages

### Project Structure

```
lib/
  features/
    auth/
      data/
        datasources/
          auth_api_client.dart
        models/
          user_dto.dart
        repositories/
          auth_repository_impl.dart
      domain/
        entities/
          user.dart
        repositories/
          auth_repository.dart
      presentation/
        bloc/
          auth_bloc.dart
          auth_event.dart
          auth_state.dart
        pages/
          login_page.dart
          register_page.dart
          home_page.dart
  injection.dart  # Dependency injection setup
  main.dart       # App entry point
```

### Configuration

Update the backend URL in `lib/injection.dart`:

```dart
AuthApiClient(
  dio: getIt<Dio>(),
  baseUrl: 'http://localhost:8000', // Change to your backend URL
),
```

For Android emulator, use `http://10.0.2.2:8000`
For iOS simulator, use `http://localhost:8000`
For physical devices, use your machine's IP address (e.g., `http://192.168.1.100:8000`)

### Running the Client

```bash
cd lifeos_client
flutter run
```

Select your target device when prompted.

## Testing the System

1. **Start the backend:**
   ```bash
   cd lifeos_backend
   composer run dev
   ```

2. **In another terminal, start the Flutter app:**
   ```bash
   cd lifeos_client
   flutter run
   ```

3. **Test the flow:**
   - App starts on login page
   - Click "Sign Up" to register a new account
   - Fill in the registration form
   - After registration, you'll be automatically logged in
   - View your profile on the home page
   - Click logout to sign out
   - Login again with your credentials

## Design

The UI uses a minimal black and white color scheme:
- Background: White
- Primary color: Black
- Text: Black/Gray variations
- Components: Shadcn UI library with white theme

## Security Features

- Passwords are hashed using Laravel's bcrypt
- API tokens are managed by Laravel Sanctum
- Tokens are stored securely in SharedPreferences
- Validation on both frontend and backend
- Account status check (is_active) on login

## Next Steps

- Add password reset functionality
- Add email verification
- Add profile editing
- Add avatar upload
- Add refresh token mechanism
- Add more robust error handling
- Add loading states
- Add unit and integration tests
