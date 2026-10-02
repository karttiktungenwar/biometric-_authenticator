import 'package:local_auth/local_auth.dart';

abstract class BiometricLocalDataSource {
  Future<bool> isDeviceSupported();
  Future<bool> canCheckBiometrics();
  Future<List<BiometricType>> getAvailableBiometrics();
  Future<bool> authenticate({
    required String localizedReason,
    required bool useErrorDialogs,
    required bool stickyAuth,
  });
}

class BiometricLocalDataSourceImpl implements BiometricLocalDataSource {
  final LocalAuthentication auth;

  BiometricLocalDataSourceImpl({required this.auth});

  @override
  Future<bool> isDeviceSupported() async {
    return await auth.isDeviceSupported();
  }

  @override
  Future<bool> canCheckBiometrics() async {
    return await auth.canCheckBiometrics;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await auth.getAvailableBiometrics();
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required bool useErrorDialogs,
    required bool stickyAuth,
  }) async {
    return await auth.authenticate(
      localizedReason: localizedReason,
      options: AuthenticationOptions(
        useErrorDialogs: useErrorDialogs,
        stickyAuth: stickyAuth,
        biometricOnly: true,
      ),
    );
  }
}
