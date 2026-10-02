import '../entities/biometric_type_entity.dart';
import '../repositories/biometric_repository.dart';

class GetAvailableBiometricsUseCase {
  final BiometricRepository repository;

  GetAvailableBiometricsUseCase(this.repository);

  Future<List<BiometricTypeEntity>> call() async {
    return await repository.getAvailableBiometrics();
  }
}
