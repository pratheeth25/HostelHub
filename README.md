# HostelHub

A Flutter + Firebase mobile application for community hostel event management.

## Features Implemented

### Authentication
- Email/password login and registration
- User profile with Name, Course, Year, and Hostel Block/Section
- Role-based access: 3rd-year students are Admins; others are Regular Users

### Admin Features (3rd-Year Students)
- Create, edit, and delete events
- Upload event banner/poster via Firebase Storage
- Set event title, description, date/time, venue, and participant limit
- View registered attendee lists
- Send push notifications to all users
- Mark student attendance for events

### Student Features
- View upcoming events in a clean dashboard
- RSVP / register for events
- View personal attendance status
- Receive event reminders and push notifications
- Dashboard sections: Upcoming Events, My Registered Events, Announcements

### Core Screens
- **Splash Screen** – animated logo with auto-navigation
- **Login / Register** – form validation, role auto-assignment by year
- **Home Dashboard** – tabbed bottom navigation
- **Event Details** – full info, banner, register button
- **Create / Edit Event** (Admin) – full form with image picker
- **Attendance Screen** (Admin) – list attendees and toggle attendance
- **Profile Screen** – view and edit user profile
- **Notifications Screen** – list push and in-app notifications

### Technical Highlights
- **Flutter Riverpod** state management with code generation
- **Firebase Auth** for secure authentication
- **Cloud Firestore** for real-time CRUD operations
- **Firebase Cloud Messaging** for push notifications
- **Firebase Storage** for event image uploads
- **go_router** for declarative navigation with auth guards
- **Material 3** design system with dark mode support
- **Shared Preferences** for local caching of user preferences
- **Shimmer loading** skeletons for better UX
- **flutter_animate** for smooth transitions
- Modular clean architecture (features / services / models / core / widgets)

## Firebase Collections
| Collection | Description |
|---|---|
| `users` | User profiles with role, year, block info |
| `events` | Event documents with metadata and banner URL |
| `registrations` | Maps userId ↔ eventId registrations |
| `attendance` | Attendance records per event |
| `notifications` | In-app notification documents |

## Folder Structure
```
lib/
 ├── core/
 │    ├── theme/
 │    ├── router/
 │    └── constants/
 ├── services/
 │    ├── auth_service.dart
 │    ├── firestore_service.dart
 │    ├── storage_service.dart
 │    └── notification_service.dart
 ├── models/
 │    ├── user_model.dart
 │    ├── event_model.dart
 │    ├── registration_model.dart
 │    ├── attendance_model.dart
 │    └── notification_model.dart
 ├── features/
 │    ├── auth/
 │    ├── events/
 │    ├── attendance/
 │    ├── notifications/
 │    └── profile/
 ├── widgets/
 └── main.dart
```

## Setup Instructions

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an Android/iOS app and download `google-services.json` / `GoogleService-Info.plist`
3. Place the config files in the appropriate native directories
4. Enable Email/Password Authentication in Firebase Console
5. Create Firestore database in production mode
6. Enable Firebase Storage
7. Run `flutter pub get`
8. Run `flutter run`

## Tech Stack
- Flutter 3.x
- Firebase (Auth, Firestore, Storage, Messaging)
- Riverpod 2 (state management)
- go_router (navigation)
- Material 3
