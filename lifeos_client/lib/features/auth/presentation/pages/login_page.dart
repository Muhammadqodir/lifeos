import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_page.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppToast.error(context, "Couldn't sign in", message: state.message);

            // Clear password but keep email when error occurs
            _passwordController.clear();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 56,
                      height: 56,
                      color: context.colors.foreground,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Welcome to LifeOS',
                    style: context.theme.typography.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sign in to continue.',
                    style: context.text.itemSubtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppFormField(
                          label: 'Email',
                          child: TextField(
                            controller: _emailController,
                            autofocus: isDesktopPlatform,
                            placeholder: const Text('you@example.com'),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                          ),
                        ),
                        AppFormField(
                          label: 'Password',
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.go,
                            // Return submits, like any sign-in form.
                            onSubmitted: (_) => _handleLogin(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => FormSubmitButton(
                            label: 'Sign in',
                            loadingLabel: 'Signing in…',
                            loading: state is AuthLoading,
                            onPressed: _handleLogin,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: context.text.itemSubtitle,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      GhostButton(
                        size: ButtonSize.small,
                        density: ButtonDensity.compact,
                        onPressed: () => Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AuthBloc>(),
                              child: const RegisterPage(),
                            ),
                          ),
                        ),
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
