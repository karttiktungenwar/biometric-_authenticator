# Building a Secure Biometric Authentication App in Flutter with BLoC and Clean Architecture (Android & iOS)

> *A step-by-step deep dive into implementing Fingerprint and Face ID authentication using BLoC state management, Clean Architecture principles, and GetIt dependency injection.*

---

![Flutter Biometric Security](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter) ![BLoC](https://img.shields.io/badge/State--Management-BLoC-8A2BE2) ![Architecture](https://img.shields.io/badge/Architecture-Clean-brightgreen) ![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-blue)

In modern mobile app development, user security and frictionless authentication are top priorities. Biometric authentication—utilizing Fingerprint sensors, Face ID, or Iris scanners—provides the gold standard for quick, high-security login flows.

In this story, we will explore how to build a production-grade **Biometric Authentication Application** in Flutter that runs seamlessly on both **Android** and **iOS**. We will architect the project using **Clean Architecture** and manage UI states cleanly with **BLoC (Business Logic Component)**.

---

## 🏛️ Clean Architecture Breakdown

To keep our codebase scalable, maintainable, and testable, we segregate code into three core layers:

```text
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                      │
│   BiometricAuthPage  ─►  BiometricBloc  ─►  UI Widgets      │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                        DOMAIN LAYER                         │
│   Use Cases  ─►  Entities  ─►  BiometricRepository (Abstract)│
└──────────────────────────────▲──────────────────────────────┘
                               │
┌──────────────────────────────┴──────────────────────────────┐
│                         DATA LAYER                          │
│   BiometricRepositoryImpl  ─►  BiometricLocalDataSource      │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                       PLATFORM LAYER                        │
│   local_auth Plugin  (Android BiometricPrompt / iOS LocalAuth)│
└─────────────────────────────────────────────────────────────┘
```

1. **Domain Layer**: Contains business entities (`BiometricInfoEntity`), repository interfaces, and use cases (`CheckBiometricSupportUseCase`, `AuthenticateBiometricUseCase`). Has **zero dependencies** on external libraries or Flutter UI.
2. **Data Layer**: Implements domain repositories, communicates with local hardware datasources (`LocalAuthentication`), and maps platform exceptions (`PlatformException`) into strongly typed domain failures.
3. **Presentation Layer**: Uses BLoC (`BiometricBloc`, `BiometricEvent`, `BiometricState`) to handle state transitions and renders responsive UI widgets with feedback.

---

## 🛠️ Step 1: Dependencies Setup

Add the required production packages to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_bloc: ^8.1.6     # State Management
  local_auth: ^2.3.0       # Platform Biometric Hardware API
  equatable: ^2.0.7        # Value equality comparison
  get_it: ^8.0.3           # Service Locator / Dependency Injection
  cupertino_icons: ^1.0.8
```

Run `flutter pub get` to fetch dependencies.

---

## 📱 Step 2: Native Platform Configuration

Biometric hardware features require explicit permissions and activity configuration on both operating systems.

### 🤖 1. Android Configuration

#### A. Permissions
Add biometric permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
    
    <application ...>
    ...
```

#### B. Activity Type
`local_auth` on Android requires `FlutterFragmentActivity` instead of standard `FlutterActivity` to host the system authentication dialog.

Update `android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
package com.biometric.authenticator.biometric_authenticator

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

---

### 🍎 2. iOS Configuration

On iOS, Face ID requires a privacy rationale string in `ios/Runner/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID / Touch ID / Biometrics to authenticate you securely.</string>
```

---

## 🧬 Step 3: Domain Layer Implementation

### 1. Entities

`lib/features/biometric_auth/domain/entities/biometric_type_entity.dart`:
```dart
import 'package:equatable/equatable.dart';

enum BiometricCategory { fingerprint, face, iris, weak, strong, unknown }

class BiometricTypeEntity extends Equatable {
  final BiometricCategory category;
  final String displayName;

  const BiometricTypeEntity({required this.category, required this.displayName});

  @override
  List<Object?> get props => [category, displayName];
}
```

`lib/features/biometric_auth/domain/entities/biometric_info_entity.dart`:
```dart
import 'package:equatable/equatable.dart';
import 'biometric_type_entity.dart';

class BiometricInfoEntity extends Equatable {
  final bool isSupported;
  final bool canCheckBiometrics;
  final List<BiometricTypeEntity> availableBiometrics;

  const BiometricInfoEntity({
    required this.isSupported,
    required this.canCheckBiometrics,
    required this.availableBiometrics,
  });

  bool get isBiometricReady => isSupported && canCheckBiometrics && availableBiometrics.isNotEmpty;

  @override
  List<Object?> get props => [isSupported, canCheckBiometrics, availableBiometrics];
}
```

### 2. Repository Contract & Use Cases

`lib/features/biometric_auth/domain/usecases/authenticate_biometric_usecase.dart`:
```dart
import '../repositories/biometric_repository.dart';

class AuthenticateBiometricUseCase {
  final BiometricRepository repository;

  AuthenticateBiometricUseCase(this.repository);

  Future<bool> call({
    String localizedReason = 'Please scan your fingerprint or face to authenticate',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    return await repository.authenticate(
      localizedReason: localizedReason,
      useErrorDialogs: useErrorDialogs,
      stickyAuth: stickyAuth,
    );
  }
}
```

---

## 💾 Step 4: Data Layer & Failure Handling

The repository implementation delegates calls to `BiometricLocalDataSource` and maps raw exceptions (`NotEnrolled`, `LockedOut`, `PasscodeNotSet`) into strongly typed domain failures.

`lib/features/biometric_auth/data/repositories/biometric_repository_impl.dart`:
```dart
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/biometric_repository.dart';

class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricLocalDataSource localDataSource;

  BiometricRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      return await localDataSource.authenticate(
        localizedReason: localizedReason,
        useErrorDialogs: useErrorDialogs,
        stickyAuth: stickyAuth,
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') throw const BiometricNotSupportedFailure();
      if (e.code == 'NotEnrolled') throw const BiometricNotEnrolledFailure();
      if (e.code == 'PasscodeNotSet') throw const PasscodeNotSetFailure();
      throw BiometricUnknownFailure(e.message ?? 'Authentication failed');
    }
  }
}
```

---

## ⚡ Step 5: BLoC State Management

### Events & States

- **Events**: `CheckBiometricAvailabilityEvent`, `AuthenticateWithBiometricEvent`, `ResetBiometricAuthEvent`.
- **States**: `BiometricInitialState`, `BiometricLoadingState`, `BiometricStatusState` holding `AuthStatus` (`initial`, `authenticating`, `authenticated`, `failed`, `error`).

`lib/features/biometric_auth/presentation/bloc/biometric_bloc.dart`:
```dart
class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  final CheckBiometricSupportUseCase checkBiometricSupportUseCase;
  final AuthenticateBiometricUseCase authenticateBiometricUseCase;

  BiometricBloc({
    required this.checkBiometricSupportUseCase,
    required this.authenticateBiometricUseCase,
  }) : super(const BiometricInitialState()) {
    on<CheckBiometricAvailabilityEvent>(_onCheckBiometricAvailability);
    on<AuthenticateWithBiometricEvent>(_onAuthenticateWithBiometric);
  }

  Future<void> _onAuthenticateWithBiometric(
    AuthenticateWithBiometricEvent event,
    Emitter<BiometricState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BiometricStatusState) return;

    emit(currentState.copyWith(authStatus: AuthStatus.authenticating));

    try {
      final isSuccess = await authenticateBiometricUseCase(
        localizedReason: event.localizedReason,
      );

      if (isSuccess) {
        emit(currentState.copyWith(authStatus: AuthStatus.authenticated));
      } else {
        emit(currentState.copyWith(
          authStatus: AuthStatus.failed,
          errorMessage: 'Authentication failed or canceled by user.',
        ));
      }
    } on Failure catch (failure) {
      emit(currentState.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: failure.message,
      ));
    }
  }
}
```

---

## 🎨 Step 6: Presentation & User Experience

We build interactive UI components that deliver clear visual feedback:

1. **`BiometricActionButton`**: Displays a smooth pulsing animation when active or authenticating.
2. **`BiometricStatusCard`**: Real-time status cards showing if hardware is supported and biometrics are enrolled.
3. **`BiometricTypeChip`**: Interactive chips showing hardware sensors available on the user's specific device (Fingerprint, Face ID, Iris).
4. **`AuthSuccessView`**: Displays decrypted secure content / vault access upon successful biometric verification.

```dart
BiometricActionButton(
  isEnabled: info.isBiometricReady,
  isAuthenticating: isAuthenticating,
  onPressed: () {
    context.read<BiometricBloc>().add(
          const AuthenticateWithBiometricEvent(
            localizedReason: 'Scan fingerprint or face to unlock app',
          ),
        );
  },
)
```

---

## 💉 Step 7: Dependency Injection Setup

`lib/core/injection/injection_container.dart`:
```dart
final sl = GetIt.instance;

Future<void> initInjection() async {
  // BLoC
  sl.registerFactory(() => BiometricBloc(
        checkBiometricSupportUseCase: sl(),
        getAvailableBiometricsUseCase: sl(),
        authenticateBiometricUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => CheckBiometricSupportUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailableBiometricsUseCase(sl()));
  sl.registerLazySingleton(() => AuthenticateBiometricUseCase(sl()));

  // Repository & Datasource
  sl.registerLazySingleton<BiometricRepository>(() => BiometricRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<BiometricLocalDataSource>(() => BiometricLocalDataSourceImpl(auth: sl()));
  sl.registerLazySingleton(() => LocalAuthentication());
}
```

---

## 🏁 Conclusion & Takeaways

By applying **Clean Architecture** with **BLoC** state management to biometric authentication:

- **Decoupled Architecture**: Domain logic has zero dependencies on Flutter UI or `local_auth` platform details.
- **Cross-Platform Readiness**: Smooth biometric experience across Android devices (Fingerprint/BiometricPrompt) and iOS devices (Touch ID/Face ID).
- **Testability**: Every use case and BLoC state can be unit-tested seamlessly without needing physical device hardware mockups.
- **Production UX**: Rich visual feedback, state handling, error banners, and animated interactive scanner components.

---

### 💻 Running the Project

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Run unit & widget tests
flutter test

# 4. Launch on connected Android device or iOS Simulator
flutter run
```

*Happy Flutter Coding! 🚀*
