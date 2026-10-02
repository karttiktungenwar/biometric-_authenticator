import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class BiometricNotSupportedFailure extends Failure {
  const BiometricNotSupportedFailure([super.message = 'Biometric authentication is not supported on this device.']);
}

class BiometricNotEnrolledFailure extends Failure {
  const BiometricNotEnrolledFailure([super.message = 'No biometrics enrolled. Please set up fingerprint or Face ID in device settings.']);
}

class PasscodeNotSetFailure extends Failure {
  const PasscodeNotSetFailure([super.message = 'Device passcode or PIN is not set.']);
}

class AuthenticationFailedFailure extends Failure {
  const AuthenticationFailedFailure([super.message = 'Authentication failed. Please try again.']);
}

class BiometricUnknownFailure extends Failure {
  const BiometricUnknownFailure(super.message);
}
