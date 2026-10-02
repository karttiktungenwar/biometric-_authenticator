import 'package:flutter/material.dart';

class AuthSuccessView extends StatelessWidget {
  final VoidCallback onLockPressed;

  const AuthSuccessView({super.key, required this.onLockPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 64,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Access Granted!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Biometric authentication was successful. You now have access to protected data.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.cyanAccent),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Encrypted Token: bio_token_8a92f4e19',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onLockPressed,
          icon: const Icon(Icons.lock_reset),
          label: const Text('Lock Vault'),
        ),
      ],
    );
  }
}
