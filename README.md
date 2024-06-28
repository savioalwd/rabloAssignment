# Flutter Chat App

A basic chat application with email and password authentication using Firebase. This application allows users to sign up, log in, and chat with other authenticated users. Messages are stored and synchronized in real-time using Firebase Firestore. created for robol.in company as intern assignment

## Features

- User Authentication (Sign In, Sign Up, Sign Out)
- Real-time chat with other users
- CRUD operations for basic information
- Messages stored in Firebase Firestore

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Firebase Firestore

## Installation

1. Clone the repository:

2. Install dependencies

## Important Notes

- Ensure you have set up Firebase for this project. Follow Firebase setup instructions for:
- Firebase Authentication
- Firebase Firestore
- Firebase Storage

- Update the `google-services.json` file:
- Generate `google-services.json` from the Firebase console for your project.
- Place the `google-services.json` file in the `android/app` directory of your Flutter project[for ios do the same and place the config json file in corresponding folder].


- Configure Firebase Firestore Rules:
- Update Firestore database rules to allow read and write access based on your project requirements.

These instructions are intended for development purposes only. Ensure proper security measures and configurations are applied for production deployment.


- find the release apk in build\app\outputs\flutter-apk\app-release.apk
