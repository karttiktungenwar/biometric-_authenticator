part of 'biometric_bloc.dart';

class BiometricState extends Equatable {
  final bool isLoading;
  final BiometricInfoEntity biometricInfo;
  final AuthStatus authStatus;
  final String? errorMessage;

  const BiometricState({
    this.isLoading = false,
    this.biometricInfo = const BiometricInfoEntity(
      isSupported: false,
      canCheckBiometrics: false,
      availableBiometrics: [],
    ),
    this.authStatus = AuthStatus.initial,
    this.errorMessage,
  });

  BiometricState copyWith({
    bool? isLoading,
    BiometricInfoEntity? biometricInfo,
    AuthStatus? authStatus,
    String? errorMessage,
  }) {
    return BiometricState(
      isLoading: isLoading ?? this.isLoading,
      biometricInfo: biometricInfo ?? this.biometricInfo,
      authStatus: authStatus ?? this.authStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, biometricInfo, authStatus, errorMessage];
}
