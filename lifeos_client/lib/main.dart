import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/presentation/bloc/theme_bloc.dart';
import 'core/theme/presentation/bloc/theme_state.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
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
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ShadcnApp(
            title: 'LifeOS',
            theme: ThemeData(
              colorScheme: ColorSchemes.lightDefaultColor,
              radius: 0.7,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorSchemes.darkDefaultColor,
              radius: 0.7,
            ),
            themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return const MainPage();
                }

                // Show LoginPage for all other states (Initial, Unauthenticated, Error, Loading)
                return const LoginPage();
              },
            ),
          );
        },
      ),
    );
  }
}
