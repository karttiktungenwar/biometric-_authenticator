import 'package:biometric_authenticator/features/biometric_auth/domain/entities/biometric_info_entity.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/entities/biometric_type_entity.dart';

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
