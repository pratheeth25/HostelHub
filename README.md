# Hostel Hub

A Flutter + Firebase hostel management application for students and admins.

## Features

- **Authentication** — Email/password login and registration with role-based access (student / admin)
- **Announcements** — Admin posts announcements; students receive them in real time
- **Attendance** — Two types:
  - *Evening Gathering* — mandatory daily attendance, marked by admin
  - *Scheduled Event* — admin-created events with optional start/end times
  - Students can mark themselves as on leave for any event
- **Complaints** — Students submit complaints (optionally anonymous); admin updates status
- **Food / Meals** — Meal tracking per student
- **Admin Dashboard** — Overview and management tools

## Tech Stack

- Flutter (cross-platform — Android primary)
- Firebase Auth, Firestore, Storage, Messaging
- Provider for state management
- `intl` for date/time formatting

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.x
- A Firebase project with Android app registered
- `google-services.json` placed in `android/app/`

### Setup

```bash
flutter pub get
flutter run
```

To build a release APK:

```bash
flutter build apk --release
```

The output is at `build/app/outputs/flutter-apk/app-release.apk`.

## Project Structure

```
lib/
  core/           # Shared models, providers, theme, widgets
  features/
    admin/        # Admin dashboard
    announcements/
    attendance/
    auth/
    complaints/
    food/
    home/
  firebase_options.dart
  main.dart
```

## Firebase Setup

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for Firestore rules and index configuration.
