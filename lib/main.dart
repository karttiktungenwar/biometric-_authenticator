import 'package:flutter/material.dart';
import 'core/injection/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/biometric_auth/presentation/pages/biometric_auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initInjection();
  runApp(const BiometricAuthenticatorApp());
}

class BiometricAuthenticatorApp extends StatelessWidget {
  const BiometricAuthenticatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric Authenticator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const BiometricAuthPage(),
    );
  }
}
