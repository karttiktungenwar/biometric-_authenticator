import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/biometric_info_entity.dart';
import '../../domain/usecases/authenticate_biometric_usecase.dart';
import '../../domain/usecases/check_biometric_support_usecase.dart';
import '../../domain/usecases/get_available_biometrics_usecase.dart';
import 'biometric_event.dart';
import 'biometric_state.dart';

class BiometricBloc extends Bloc<BiometricEvent, BiometricState> {
  final CheckBiometricSupportUseCase checkBiometricSupportUseCase;
  final GetAvailableBiometricsUseCase getAvailableBiometricsUseCase;
  final AuthenticateBiometricUseCase authenticateBiometricUseCase;

  BiometricBloc({
    required this.checkBiometricSupportUseCase,
    required this.getAvailableBiometricsUseCase,
    required this.authenticateBiometricUseCase,
  }) : super(const BiometricInitialState()) {
    on<CheckBiometricAvailabilityEvent>(_onCheckBiometricAvailability);
    on<AuthenticateWithBiometricEvent>(_onAuthenticateWithBiometric);
    on<ResetBiometricAuthEvent>(_onResetBiometricAuth);
  }

  Future<void> _onCheckBiometricAvailability(
    CheckBiometricAvailabilityEvent event,
    Emitter<BiometricState> emit,
  ) async {
    emit(const BiometricLoadingState());
    try {
      final info = await checkBiometricSupportUseCase();
      emit(BiometricStatusState(biometricInfo: info));
    } catch (e) {
      emit(BiometricStatusState(
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
    final currentState = state;
    if (currentState is! BiometricStatusState) return;

    emit(currentState.copyWith(
      authStatus: AuthStatus.authenticating,
      errorMessage: null,
    ));

    try {
      final isSuccess = await authenticateBiometricUseCase(
        localizedReason: event.localizedReason,
      );

      if (isSuccess) {
        emit(currentState.copyWith(
          authStatus: AuthStatus.authenticated,
          errorMessage: null,
        ));
      } else {
        emit(currentState.copyWith(
          authStatus: AuthStatus.failed,
          errorMessage: 'Authentication failed or was canceled by user.',
        ));
      }
    } on Failure catch (failure) {
      emit(currentState.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: failure.message,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        authStatus: AuthStatus.error,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  void _onResetBiometricAuth(
    ResetBiometricAuthEvent event,
    Emitter<BiometricState> emit,
  ) {
    final currentState = state;
    if (currentState is BiometricStatusState) {
      emit(currentState.copyWith(
        authStatus: AuthStatus.initial,
        errorMessage: null,
      ));
    }
  }
}
