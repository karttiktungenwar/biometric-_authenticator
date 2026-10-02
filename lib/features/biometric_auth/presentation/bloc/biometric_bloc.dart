import 'package:biometric_authenticator/core/enums/auth_status.dart';
import 'package:biometric_authenticator/core/errors/failures.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/entities/biometric_info_entity.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/usecases/authenticate_biometric_usecase.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/usecases/check_biometric_support_usecase.dart';
import 'package:biometric_authenticator/features/biometric_auth/domain/usecases/get_available_biometrics_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'biometric_event.dart';
part 'biometric_state.dart';

class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  final CheckBiometricSupportUseCase checkBiometricSupportUseCase;
  final GetAvailableBiometricsUseCase getAvailableBiometricsUseCase;
  final AuthenticateBiometricUseCase authenticateBiometricUseCase;

  BiometricBloc({
    required this.checkBiometricSupportUseCase,
    required this.getAvailableBiometricsUseCase,
    required this.authenticateBiometricUseCase,
  }) : super(const BiometricState()) {
    on<CheckBiometricAvailabilityEvent>(_onCheckBiometricAvailability);
    on<AuthenticateWithBiometricEvent>(_onAuthenticateWithBiometric);
    on<ResetBiometricAuthEvent>(_onResetBiometricAuth);
  }

  Future<void> _onCheckBiometricAvailability(
    CheckBiometricAvailabilityEvent event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final info = await checkBiometricSupportUseCase();
      emit(state.copyWith(
        isLoading: false,
        biometricInfo: info,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        biometricInfo: const BiometricInfoEntity(
          isSupported: false,
          canCheckBiometrics: false,
          availableBiometrics: [],
        ),
        authStatus: AuthStatus.error,
        errorMessage: 'Failed to check biometric availability: ${e.toString()}',
      ));
    }
  }

  Future<void> _onAuthenticateWithBiometric(
    AuthenticateWithBiometricEvent event,
    Emitter<BiometricState> emit,
  ) async {
    emit(state.copyWith(
      authStatus: AuthStatus.authenticating,
      errorMessage: null,
    ));

    try {
      final isSuccess = await authenticateBiometricUseCase(
        localizedReason: event.localizedReason,
      );

      if (isSuccess) {
        emit(state.copyWith(
          authStatus: AuthStatus.authenticated,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(
          authStatus: AuthStatus.failed,
          errorMessage: 'Authentication failed or was canceled by user.',
        ));
      }
    } on Failure catch (failure) {
      emit(state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: failure.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  void _onResetBiometricAuth(
    ResetBiometricAuthEvent event,
    Emitter<BiometricState> emit,
  ) {
    emit(state.copyWith(
      authStatus: AuthStatus.initial,
      errorMessage: null,
    ));
  }
}
