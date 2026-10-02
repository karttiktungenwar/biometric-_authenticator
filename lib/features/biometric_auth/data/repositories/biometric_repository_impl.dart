import 'package:biometric_authenticator/core/enums/biometric_category.dart';
import 'package:biometric_authenticator/features/biometric_auth/data/data_sources/biometric_local_datasource.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:biometric_authenticator/core/errors/failures.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/entities/biometric_info_entity.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/entities/biometric_type_entity.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/repositories/biometric_repository.dart';


class BiometricRepositoryImpl implements BiometricRepository {
  final BiometricLocalDataSource localDataSource;

  BiometricRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> isDeviceSupported() async {
    try {
      return await localDataSource.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      return await localDataSource.canCheckBiometrics();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<BiometricTypeEntity>> getAvailableBiometrics() async {
    try {
      final types = await localDataSource.getAvailableBiometrics();
      return types.map(_mapBiometricTypeToEntity).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<BiometricInfoEntity> getBiometricInfo() async {
    final isSupported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    final available = await getAvailableBiometrics();

    return BiometricInfoEntity(
      isSupported: isSupported,
      canCheckBiometrics: canCheck,
      availableBiometrics: available,
    );
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final result = await localDataSource.authenticate(
        localizedReason: localizedReason,
        useErrorDialogs: useErrorDialogs,
        stickyAuth: stickyAuth,
      );
      return result;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        throw const BiometricNotSupportedFailure();
      } else if (e.code == 'NotEnrolled') {
        throw const BiometricNotEnrolledFailure();
      } else if (e.code == 'PasscodeNotSet') {
        throw const PasscodeNotSetFailure();
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        throw const BiometricUnknownFailure('Biometrics locked out due to too many failed attempts. Try again later.');
      } else {
        throw BiometricUnknownFailure(e.message ?? 'Authentication failed');
      }
    } catch (e) {
      throw BiometricUnknownFailure(e.toString());
    }
  }

  BiometricTypeEntity _mapBiometricTypeToEntity(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return const BiometricTypeEntity(
          category: BiometricCategory.fingerprint,
          displayName: 'Fingerprint Sensor',
        );
      case BiometricType.face:
        return const BiometricTypeEntity(
          category: BiometricCategory.face,
          displayName: 'Face Recognition',
        );
      case BiometricType.iris:
        return const BiometricTypeEntity(
          category: BiometricCategory.iris,
          displayName: 'Iris Scanner',
        );
      case BiometricType.strong:
        return const BiometricTypeEntity(
          category: BiometricCategory.strong,
          displayName: 'Strong Biometric',
        );
      case BiometricType.weak:
        return const BiometricTypeEntity(
          category: BiometricCategory.weak,
          displayName: 'Weak Biometric',
        );
    }
  }
}
