# Quick Start Guide

## Prerequisites

### Backend
- PHP 8.2+
- Composer
- SQLite (or MySQL/PostgreSQL)

### Frontend
- Flutter SDK 3.8.1+
- Dart 3.8.1+
- An emulator or physical device

## Setup & Run

### 1. Backend Setup

```bash
# Navigate to backend directory
cd lifeos_backend

# Install dependencies and setup
composer run setup

# Start development server
composer run dev
```

The backend will be available at `http://localhost:8000`

### 2. Frontend Setup

```bash
# Navigate to client directory
cd lifeos_client

# Get dependencies
flutter pub get

# Run the app (select device when prompted)
flutter run
```

## Test the Authentication Flow

1. **Register a new account:**
   - Open the app (starts on login page)
   - Click "Sign Up"
   - Fill in the form:
     - First Name: John
     - Last Name: Doe
     - Father Name: (optional)
     - Email: john@example.com
     - Password: password123
     - Confirm Password: password123
   - Click "Create Account"

2. **View profile:**
   - After successful registration, you'll be logged in automatically
   - See your profile information on the home page

3. **Logout:**
   - Click the logout icon in the app bar
   - You'll be redirected to the login page

4. **Login:**
   - Email: john@example.com
   - Password: password123
   - Click "Sign In"

## API Testing with cURL

### Register
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "John",
    "last_name": "Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### Login
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Get Current User (replace TOKEN with actual token from login response)
```bash
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer TOKEN"
```

### Logout (replace TOKEN with actual token)
```bash
curl -X POST http://localhost:8000/api/auth/logout \
  -H "Authorization: Bearer TOKEN"
```

## Troubleshooting

### Backend Issues

**Port already in use:**
```bash
# Stop the existing process or change port in .env
APP_PORT=8001
```

**Database errors:**
```bash
# Reset database
php artisan migrate:fresh
```

### Frontend Issues

**Cannot connect to backend:**
- For Android emulator: Use `http://10.0.2.2:8000` in `lib/injection.dart`
- For iOS simulator: Use `http://localhost:8000`
- For physical device: Use your machine's IP (e.g., `http://192.168.1.100:8000`)

**Dependencies error:**
```bash
flutter clean
flutter pub get
```

**Hot reload not working after state changes:**
- Stop the app and run `flutter run` again

## Next Development Steps

1. Add email verification
2. Add password reset
3. Add profile editing
4. Add avatar upload
5. Add more features to the home page
6. Add unit and widget tests
7. Add CI/CD pipeline

## Project Structure

```
lifeos/
├── lifeos_backend/          # Laravel API
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/Auth/
│   │   │   ├── Requests/Auth/
│   │   │   └── Resources/
│   │   └── Models/
│   ├── routes/
│   │   └── api.php
│   └── database/migrations/
│
└── lifeos_client/           # Flutter App
    └── lib/
        ├── features/auth/
        │   ├── data/
        │   ├── domain/
        │   └── presentation/
        ├── injection.dart
        └── main.dart
```

Enjoy building with LifeOS! 🚀
