import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/injection_container.dart';
import '../bloc/biometric_bloc.dart';
import '../bloc/biometric_event.dart';
import '../bloc/biometric_state.dart';
import 'widgets/auth_success_view.dart';
import 'widgets/biometric_action_button.dart';
import 'widgets/biometric_status_card.dart';

class BiometricAuthPage extends StatelessWidget {
  const BiometricAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BiometricBloc>(
      create: (_) => sl<BiometricBloc>()..add(const CheckBiometricAvailabilityEvent()),
      child: const _BiometricAuthView(),
    );
  }
}

class _BiometricAuthView extends StatelessWidget {
  const _BiometricAuthView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Security'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-check Biometrics',
            onPressed: () {
              context.read<BiometricBloc>().add(const CheckBiometricAvailabilityEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<BiometricBloc, BiometricState>(
        listener: (context, state) {
          if (state is BiometricStatusState) {
            if (state.authStatus == AuthStatus.authenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Authentication Successful!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state.authStatus == AuthStatus.failed || state.authStatus == AuthStatus.error) {
              final message = state.errorMessage ?? 'Authentication failed';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(message)),
                    ],
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is BiometricLoadingState || state is BiometricInitialState) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking biometric hardware...'),
                ],
              ),
            );
          }

          if (state is BiometricStatusState) {
            final info = state.biometricInfo;
            final isAuthenticated = state.authStatus == AuthStatus.authenticated;
            final isAuthenticating = state.authStatus == AuthStatus.authenticating;

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.security_outlined,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clean Architecture & BLoC',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Biometric Authentication for Android & iOS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Status details card
                    BiometricStatusCard(info: info),
                    const SizedBox(height: 32),

                    // Action area or Success View
                    if (isAuthenticated)
                      AuthSuccessView(
                        onLockPressed: () {
                          context.read<BiometricBloc>().add(const ResetBiometricAuthEvent());
                        },
                      )
                    else
                      BiometricActionButton(
                        isEnabled: info.isBiometricReady,
                        isAuthenticating: isAuthenticating,
                        onPressed: () {
                          context.read<BiometricBloc>().add(
                                const AuthenticateWithBiometricEvent(
                                  localizedReason: 'Scan fingerprint or face to unlock app',
                                ),
                              );
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
