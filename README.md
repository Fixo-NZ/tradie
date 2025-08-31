# Tradie App

A Flutter application for tradies to connect with homeowners in New Zealand, built with scalability to expand to other countries.

## Features

- **Authentication**: Login and registration for tradies
- **MVVM Architecture**: Clean separation of concerns
- **State Management**: Riverpod for reactive state management
- **HTTP Client**: Dio for API communication
- **Routing**: Go Router for navigation
- **Secure Storage**: Flutter Secure Storage for token management

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture:

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── constants/       # API constants
│   ├── models/          # Data models
│   ├── network/         # Network layer (Dio client, API results)
│   └── router/          # App routing
├── data/
│   └── repositories/    # Data repositories
├── presentation/
│   ├── screens/         # UI screens
│   ├── viewmodels/      # Business logic
│   └── widgets/         # Reusable widgets
└── main.dart
```

## Setup

### Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Laravel API server (separate project)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code for JSON serialization:
   ```bash
   dart run build_runner build
   ```

4. Update API configuration in `lib/core/config/app_config.dart`:
   ```dart
   static const String apiBaseUrl = 'https://your-laravel-api.com/api';
   ```

### Laravel API Endpoints

The app expects the following endpoints from your Laravel API:

- `POST /auth/login` - Tradie login
- `POST /auth/register` - Tradie registration  
- `POST /auth/logout` - Logout
- `POST /auth/refresh` - Refresh token

### Tradie Model

Based on the Laravel migration, the tradie model includes:

- Personal info: first_name, middle_name, last_name, email, phone
- Profile: avatar, bio, business_name, license_number
- Location: address, city, region, postal_code, latitude, longitude
- Business: insurance_details, years_experience, hourly_rate
- Availability: availability_status, service_radius

## Running the App

```bash
flutter run
```

## Development

### Adding New Features

1. Create models in `lib/core/models/`
2. Add repositories in `lib/data/repositories/`
3. Create ViewModels in `lib/presentation/viewmodels/`
4. Build UI screens in `lib/presentation/screens/`

### Code Generation

When adding new models with JSON serialization:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Dependencies

- **flutter_riverpod**: State management
- **dio**: HTTP client
- **go_router**: Routing
- **json_annotation**: JSON serialization
- **flutter_secure_storage**: Secure token storage
- **formz**: Form validation

## Next Steps

- Implement profile management
- Add job management features
- Implement real-time messaging
- Add location services
- Implement push notifications
- Add payment integration
