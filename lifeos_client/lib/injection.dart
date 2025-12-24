import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_config.dart';
import 'core/network/auth_interceptor.dart';
import 'core/theme/presentation/bloc/theme_bloc.dart';
import 'features/auth/data/datasources/auth_api_client.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/navigation/presentation/bloc/navigation_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dio with interceptors
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
    receiveTimeout: Duration(seconds: AppConfig.receiveTimeoutSeconds),
    sendTimeout: Duration(seconds: AppConfig.sendTimeoutSeconds),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    followRedirects: false,
    validateStatus: (status) {
      // Accept all status codes and handle them in the error handler
      return status != null && status < 500;
    },
  ));
  
  // Add auth interceptor for automatic token management
  dio.interceptors.add(AuthInterceptor(sharedPreferences, dio));
  
  getIt.registerSingleton<Dio>(dio);

  // Data sources
  getIt.registerLazySingleton<AuthApiClient>(
    () => AuthApiClient(
      dio: getIt<Dio>(),
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiClient: getIt<AuthApiClient>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<NavigationBloc>(
    () => NavigationBloc(),
  );

  getIt.registerSingleton<ThemeBloc>(
    ThemeBloc(getIt<SharedPreferences>()),
  );
}
