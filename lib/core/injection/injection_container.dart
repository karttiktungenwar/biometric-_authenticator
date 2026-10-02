import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import '../../features/biometric_auth/data/datasources/biometric_local_datasource.dart';
import '../../features/biometric_auth/data/repositories/biometric_repository_impl.dart';
import '../../features/biometric_auth/domain/repositories/biometric_repository.dart';
import '../../features/biometric_auth/domain/usecases/authenticate_biometric_usecase.dart';
import '../../features/biometric_auth/domain/usecases/check_biometric_support_usecase.dart';
import '../../features/biometric_auth/domain/usecases/get_available_biometrics_usecase.dart';
import '../../features/biometric_auth/presentation/bloc/biometric_bloc.dart';

final sl = GetIt.instance;

Future<void> initInjection() async {
  // BLoC
  sl.registerFactory(
    () => BiometricBloc(
      checkBiometricSupportUseCase: sl(),
      getAvailableBiometricsUseCase: sl(),
      authenticateBiometricUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CheckBiometricSupportUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailableBiometricsUseCase(sl()));
  sl.registerLazySingleton(() => AuthenticateBiometricUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BiometricRepository>(
    () => BiometricRepositoryImpl(localDataSource: sl()),
  );

  // Data source
  sl.registerLazySingleton<BiometricLocalDataSource>(
    () => BiometricLocalDataSourceImpl(auth: sl()),
  );

  // External
  sl.registerLazySingleton(() => LocalAuthentication());
}
