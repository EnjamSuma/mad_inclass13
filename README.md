# Firebase Authentication in Flutter

**In-Class Activity 13B – Mobile App Development**

**Student:** Suma Enjam  
**GitHub:** https://github.com/EnjamSuma/mad_inclass13

## Project Overview

This Flutter app uses Firebase Authentication to allow users to register, sign in, sign out, view their profile, and change their password.

## Features

- Email/password registration and sign-in
- Profile screen displaying the user's email
- Sign-out functionality
- Password update with reauthentication
- Form validation and error messages
- Automatic screen updates using `authStateChanges()`

## Technologies Used

Flutter, Dart, Firebase Authentication, Firebase Core, FlutterFire CLI, and Android.

## Project Structure

```text
lib/
├── main.dart
├── firebase_options.dart
├── services/
│   └── auth_service.dart
└── screens/
    ├── authentication_screen.dart
    └── profile_screen.dart
```

## Setup and Run

1. Install Flutter and Firebase CLI tools.
2. Clone the repository and install dependencies:

```bash
git clone https://github.com/EnjamSuma/mad_inclass13.git
cd mad_inclass13
flutter pub get
```

3. Configure Firebase using `flutterfire configure` and enable Email/Password authentication in Firebase Console.
4. Run the application:

```bash
flutter run
```

Build the APK:

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

## Testing

Successfully tested registration, sign-in, sign-out, password changes, Firebase user creation, and form validation on Android.

Session restoration and expired-session recovery were tested.

## Learning and Future Improvements

This activity helped me understand Firebase Authentication, authentication-state management, and secure password updates. Future improvements include automated testing, password reset, and email verification.

## AI Use Disclosure

I used ChatGPT for code guidance, clarification, and review. I manually tested the main authentication features.

## References

- https://firebase.google.com/docs/auth/flutter/start
- https://firebase.google.com/docs/auth/flutter/manage-users
