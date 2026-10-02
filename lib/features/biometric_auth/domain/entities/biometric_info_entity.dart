import 'package:equatable/equatable.dart';
import 'biometric_type_entity.dart';

class BiometricInfoEntity extends Equatable {
  final bool isSupported;
  final bool canCheckBiometrics;
  final List<BiometricTypeEntity> availableBiometrics;

  const BiometricInfoEntity({
    required this.isSupported,
    required this.canCheckBiometrics,
    required this.availableBiometrics,
  });

  bool get isBiometricReady => isSupported && canCheckBiometrics && availableBiometrics.isNotEmpty;

  @override
  List<Object?> get props => [isSupported, canCheckBiometrics, availableBiometrics];
}
