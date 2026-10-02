import '../entities/biometric_info_entity.dart';
import '../repositories/biometric_repository.dart';

class CheckBiometricSupportUseCase {
  final BiometricRepository repository;

  CheckBiometricSupportUseCase(this.repository);

  Future<BiometricInfoEntity> call() async {
    return await repository.getBiometricInfo();
  }
}
