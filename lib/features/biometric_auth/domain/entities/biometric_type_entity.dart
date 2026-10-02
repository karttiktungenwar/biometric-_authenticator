import 'package:biometric_authenticator/core/enums/biometric_category.dart';

class BiometricTypeEntity {
  final BiometricCategory category;
  final String displayName;

  const BiometricTypeEntity({
    required this.category,
    required this.displayName,
  });

}
