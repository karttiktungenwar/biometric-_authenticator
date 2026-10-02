import 'package:equatable/equatable.dart';

abstract class BiometricEvent extends Equatable {
  const BiometricEvent();

  @override
  List<Object?> get props => [];
}

class CheckBiometricAvailabilityEvent extends BiometricEvent {
  const CheckBiometricAvailabilityEvent();
}

class AuthenticateWithBiometricEvent extends BiometricEvent {
  final String localizedReason;

  const AuthenticateWithBiometricEvent({
    this.localizedReason = 'Please scan your fingerprint or face to authenticate',
  });

  @override
  List<Object?> get props => [localizedReason];
}

class ResetBiometricAuthEvent extends BiometricEvent {
  const ResetBiometricAuthEvent();
}
