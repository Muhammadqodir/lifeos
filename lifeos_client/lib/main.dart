import 'package:lifeos_client/features/auth/presentation/pages/splash_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/custom_theme.dart';
import 'core/theme/presentation/bloc/theme_bloc.dart';
import 'core/theme/presentation/bloc/theme_state.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/security/presentation/bloc/security_bloc.dart';
import 'features/navigation/presentation/pages/main_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (_) => getIt<ThemeBloc>()),
        BlocProvider(create: (_) => getIt<SecurityBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ShadcnApp(
            title: 'LifeOS',
            theme: CustomTheme.lightTheme(),
            darkTheme: CustomTheme.darkTheme(),
            themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return const MainPage();
                }
                if (state is AuthChecking) {
                  return const SplashPage();
                }
                return const LoginPage();
              },
            ),
          );
        },
      ),
    );
  }
}
