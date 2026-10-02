import 'package:equatable/equatable.dart';
import '../../domain/entities/biometric_info_entity.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  failed,
  error,
}

abstract class BiometricState extends Equatable {
  const BiometricState();

  @override
  List<Object?> get props => [];
}

class BiometricInitialState extends BiometricState {
  const BiometricInitialState();
}

class BiometricLoadingState extends BiometricState {
  const BiometricLoadingState();
}

class BiometricStatusState extends BiometricState {
  final BiometricInfoEntity biometricInfo;
  final AuthStatus authStatus;
  final String? errorMessage;

  const BiometricStatusState({
    required this.biometricInfo,
    this.authStatus = AuthStatus.initial,
    this.errorMessage,
  });

  BiometricStatusState copyWith({
    BiometricInfoEntity? biometricInfo,
    AuthStatus? authStatus,
    String? errorMessage,
  }) {
    return BiometricStatusState(
      biometricInfo: biometricInfo ?? this.biometricInfo,
      authStatus: authStatus ?? this.authStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [biometricInfo, authStatus, errorMessage];
}
