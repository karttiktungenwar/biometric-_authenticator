import '../repositories/biometric_repository.dart';

class AuthenticateBiometricUseCase {
  final BiometricRepository repository;

  AuthenticateBiometricUseCase(this.repository);

  Future<bool> call({
    String localizedReason = 'Please authenticate to access the application',
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
