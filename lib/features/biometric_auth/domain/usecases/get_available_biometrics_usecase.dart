import 'package:biometric_authenticator/features/biometric_auth/domain/entities/biometric_type_entity.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/repositories/biometric_repository.dart';

class GetAvailableBiometricsUseCase {
  final BiometricRepository repository;

  GetAvailableBiometricsUseCase(this.repository);

  Future<List<BiometricTypeEntity>> call() async {
    return await repository.getAvailableBiometrics();
  }
}
