import 'package:biometric_authenticator/features/biometric_auth/domain/entities/biometric_info_entity.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/repositories/biometric_repository.dart';

class CheckBiometricSupportUseCase {
  final BiometricRepository repository;

  CheckBiometricSupportUseCase(this.repository);

  Future<BiometricInfoEntity> call() async {
    return await repository.getBiometricInfo();
  }
}
