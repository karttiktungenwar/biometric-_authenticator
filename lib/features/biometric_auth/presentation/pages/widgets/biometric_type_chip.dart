import 'package:flutter/material.dart';
import '../../../domain/entities/biometric_type_entity.dart';

class BiometricTypeChip extends StatelessWidget {
  final BiometricTypeEntity biometricType;

  const BiometricTypeChip({super.key, required this.biometricType});

  IconData _getIcon() {
    switch (biometricType.category) {
      case BiometricCategory.fingerprint:
        return Icons.fingerprint;
      case BiometricCategory.face:
        return Icons.face;
      case BiometricCategory.iris:
        return Icons.remove_red_eye;
      case BiometricCategory.strong:
      case BiometricCategory.weak:
        return Icons.security;
      case BiometricCategory.unknown:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            biometricType.displayName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
