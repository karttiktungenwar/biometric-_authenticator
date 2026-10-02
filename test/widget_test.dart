import 'package:flutter_test/flutter_test.dart';
import 'package:biometric_authenticator/core/injection/injection_container.dart' as di;
import 'package:biometric_authenticator/main.dart';

void main() {
  testWidgets('Biometric authenticator smoke test', (WidgetTester tester) async {
    await di.initInjection();
    await tester.pumpWidget(const BiometricAuthenticatorApp());
    expect(find.text('Biometric Security'), findsOneWidget);
  });
}
