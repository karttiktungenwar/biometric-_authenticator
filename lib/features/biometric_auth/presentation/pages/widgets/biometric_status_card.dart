import 'package:biometric_authenticator/features/biometric_auth/domain/entities/biometric_info_entity.dart';
import 'package:flutter/material.dart';

import 'biometric_type_chip.dart';

class BiometricStatusCard extends StatelessWidget {
  final BiometricInfoEntity info;

  const BiometricStatusCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  info.isSupported ? Icons.check_circle_outline : Icons.highlight_off,
                  color: info.isSupported ? Colors.greenAccent : Colors.redAccent,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Biometric Hardware: ${info.isSupported ? "Supported" : "Not Supported"}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  info.canCheckBiometrics ? Icons.lock_open : Icons.lock,
                  color: info.canCheckBiometrics ? Colors.greenAccent : Colors.orangeAccent,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Biometric Enrollment: ${info.canCheckBiometrics ? "Enrolled & Ready" : "Not Enrolled / Unavailable"}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (info.availableBiometrics.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Available Sensors:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: info.availableBiometrics
                    .map((bio) => BiometricTypeChip(biometricType: bio))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
