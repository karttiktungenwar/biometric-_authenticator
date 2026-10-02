import 'package:equatable/equatable.dart';

enum BiometricCategory {
  fingerprint,
  face,
  iris,
  weak,
  strong,
  unknown,
}

class BiometricTypeEntity extends Equatable {
  final BiometricCategory category;
  final String displayName;

  const BiometricTypeEntity({
    required this.category,
    required this.displayName,
  });

  @override
  List<Object?> get props => [category, displayName];
}
