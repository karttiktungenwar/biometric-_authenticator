part of 'biometric_bloc.dart';

abstract class BiometricEvent {
  const BiometricEvent();
}

class CheckBiometricAvailabilityEvent extends BiometricEvent {
  const CheckBiometricAvailabilityEvent();
}

class AuthenticateWithBiometricEvent extends BiometricEvent {
  final String localizedReason;

  const AuthenticateWithBiometricEvent({
    this.localizedReason = 'Please scan your fingerprint or face to authenticate',
  });
}

class ResetBiometricAuthEvent extends BiometricEvent {
  const ResetBiometricAuthEvent();
}
