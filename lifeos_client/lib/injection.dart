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
import 'features/finance/data/datasources/finance_api_client.dart';
import 'features/finance/data/repositories/finance_repository_impl.dart';
import 'features/finance/domain/repositories/finance_repository.dart';
import 'features/finance/presentation/bloc/add_wallet_bloc.dart';
import 'features/finance/presentation/bloc/manage_wallets_bloc.dart';
import 'features/finance/presentation/bloc/manage_transactions_bloc.dart';
import 'features/finance/presentation/bloc/add_transaction_bloc.dart';
import 'features/finance/presentation/bloc/analytics_bloc.dart';
import 'features/finance/presentation/bloc/finance_settings_bloc.dart';
import 'features/health/data/datasources/health_api_client.dart';
import 'features/health/data/datasources/workout_local_storage.dart';
import 'features/health/data/repositories/health_repository_impl.dart';
import 'features/health/data/repositories/workout_repository.dart';
import 'features/health/domain/repositories/health_repository.dart';
import 'features/health/domain/repositories/workout_repository.dart';
import 'features/health/presentation/bloc/health_home_bloc.dart';
import 'features/health/presentation/bloc/workout_bloc.dart';
import 'features/health/presentation/bloc/exercise_bloc.dart';
import 'features/health/presentation/bloc/sleep_entry_bloc.dart';
import 'features/health/presentation/bloc/wellbeing_entry_bloc.dart';
import 'features/health/presentation/bloc/workout_sessions_bloc.dart';
import 'features/projects/data/datasources/projects_api_client.dart';
import 'features/projects/data/repositories/projects_repository_impl.dart';
import 'features/projects/domain/repositories/projects_repository.dart';
import 'features/projects/presentation/bloc/manage_projects_bloc.dart';
import 'features/projects/presentation/bloc/add_project_bloc.dart';
import 'features/projects/data/repositories/todos_repository_impl.dart';
import 'features/projects/domain/repositories/todos_repository.dart';
import 'features/projects/presentation/bloc/manage_todos_bloc.dart';
import 'features/projects/presentation/bloc/create_todo_bloc.dart';
import 'features/habits/data/datasources/habits_api_client.dart';
import 'features/habits/data/repositories/habits_repository_impl.dart';
import 'features/habits/domain/repositories/habits_repository.dart';
import 'features/habits/presentation/bloc/habits_list_bloc.dart';
import 'features/habits/presentation/bloc/create_habit_bloc.dart';
import 'features/habits/presentation/bloc/log_entry_bloc.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Dio with interceptors
  final dio = Dio(
    BaseOptions(
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
    ),
  );

  // Add auth interceptor for automatic token management
  dio.interceptors.add(AuthInterceptor(sharedPreferences, dio));

  getIt.registerSingleton<Dio>(dio);

  // Data sources
  getIt.registerLazySingleton<AuthApiClient>(
    () => AuthApiClient(dio: getIt<Dio>(), baseUrl: AppConfig.apiBaseUrl),
  );

  getIt.registerLazySingleton<FinanceApiClient>(
    () => FinanceApiClient(dio: getIt<Dio>(), baseUrl: AppConfig.apiBaseUrl),
  );

  getIt.registerLazySingleton<HealthApiClient>(
    () => HealthApiClient(dio: getIt<Dio>(), baseUrl: AppConfig.apiBaseUrl),
  );

  getIt.registerLazySingleton<ProjectsApiClient>(
    () => ProjectsApiClient(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<HabitsApiClient>(
    () => HabitsApiClient(dio: getIt<Dio>(), baseUrl: AppConfig.apiBaseUrl),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiClient: getIt<AuthApiClient>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(apiClient: getIt<FinanceApiClient>()),
  );

  getIt.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(apiClient: getIt<HealthApiClient>()),
  );

  getIt.registerLazySingleton<WorkoutLocalStorage>(
    () => WorkoutLocalStorage(prefs: getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<WorkoutRepository>(
    () => WorkoutRepositoryImpl(
      apiClient: getIt<HealthApiClient>(),
      localStorage: getIt<WorkoutLocalStorage>(),
    ),
  );

  getIt.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepositoryImpl(apiClient: getIt<ProjectsApiClient>()),
  );

  getIt.registerLazySingleton<HabitsRepository>(
    () => HabitsRepositoryImpl(apiClient: getIt<HabitsApiClient>()),
  );

  getIt.registerLazySingleton<TodosRepository>(
    () => TodosRepositoryImpl(getIt<ProjectsApiClient>()),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      todosRepository: getIt<TodosRepository>(),
      habitsRepository: getIt<HabitsRepository>(),
    ),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<NavigationBloc>(() => NavigationBloc());

  getIt.registerFactory<AddWalletBloc>(
    () => AddWalletBloc(financeRepository: getIt<FinanceRepository>()),
  );

  getIt.registerFactory<ManageWalletsBloc>(
    () => ManageWalletsBloc(financeRepository: getIt<FinanceRepository>()),
  );

  getIt.registerFactory<ManageTransactionsBloc>(
    () => ManageTransactionsBloc(financeRepository: getIt<FinanceRepository>()),
  );

  getIt.registerFactory<AddTransactionBloc>(
    () => AddTransactionBloc(financeRepository: getIt<FinanceRepository>()),
  );

  getIt.registerFactory<WorkoutBloc>(
    () => WorkoutBloc(repository: getIt<WorkoutRepository>()),
  );

  getIt.registerFactory<ExerciseBloc>(
    () => ExerciseBloc(repository: getIt<WorkoutRepository>()),
  );

  getIt.registerFactory<WorkoutSessionsBloc>(
    () => WorkoutSessionsBloc(workoutRepository: getIt<WorkoutRepository>()),
  );

  getIt.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(financeRepository: getIt<FinanceRepository>()),
  );

  getIt.registerFactory<FinanceSettingsBloc>(
    () => FinanceSettingsBloc(financeRepository: getIt<FinanceRepository>()),
  );

  getIt.registerFactory<HealthHomeBloc>(
    () => HealthHomeBloc(healthRepository: getIt<HealthRepository>()),
  );

  getIt.registerFactory<SleepEntryBloc>(
    () => SleepEntryBloc(healthRepository: getIt<HealthRepository>()),
  );

  getIt.registerFactory<ManageProjectsBloc>(
    () => ManageProjectsBloc(projectsRepository: getIt<ProjectsRepository>()),
  );

  getIt.registerFactory<AddProjectBloc>(
    () => AddProjectBloc(projectsRepository: getIt<ProjectsRepository>()),
  );

  getIt.registerFactory<ManageTodosBloc>(
    () => ManageTodosBloc(getIt<TodosRepository>()),
  );

  getIt.registerFactory<CreateTodoBloc>(
    () => CreateTodoBloc(getIt<TodosRepository>()),
  );

  getIt.registerFactory<HabitsListBloc>(
    () => HabitsListBloc(habitsRepository: getIt<HabitsRepository>()),
  );

  getIt.registerFactory<CreateHabitBloc>(
    () => CreateHabitBloc(habitsRepository: getIt<HabitsRepository>()),
  );

  getIt.registerFactory<LogEntryBloc>(
    () => LogEntryBloc(habitsRepository: getIt<HabitsRepository>()),
  );

  getIt.registerFactory<WellbeingEntryBloc>(
    () => WellbeingEntryBloc(healthRepository: getIt<HealthRepository>()),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(homeRepository: getIt<HomeRepository>()),
  );

  getIt.registerSingleton<ThemeBloc>(ThemeBloc(getIt<SharedPreferences>()));
}
