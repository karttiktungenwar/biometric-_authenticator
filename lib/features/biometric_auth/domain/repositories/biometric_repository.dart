import '../entities/biometric_info_entity.dart';
import '../entities/biometric_type_entity.dart';

abstract class BiometricRepository {
  Future<bool> isDeviceSupported();
  Future<bool> canCheckBiometrics();
  Future<List<BiometricTypeEntity>> getAvailableBiometrics();
  Future<BiometricInfoEntity> getBiometricInfo();
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  });
}
