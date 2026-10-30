import 'package:flutter/services.dart' show TextInputAction;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:lifeos_client/core/ui/ui.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fatherNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        fatherName: _fatherNameController.text.isEmpty
            ? null
            : _fatherNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: const [AppHeader(title: '', showBorder: false)],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // The app shell replaces the login screen underneath; close the
            // pushed register page so the user lands in the app.
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AuthError) {
            AppToast.error(
              context,
              "Couldn't create your account",
              message: state.message,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create your account',
                    style: context.theme.typography.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your data stays private to you.',
                    style: context.text.itemSubtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppFormField(
                                label: 'First name',
                                child: TextField(
                                  controller: _firstNameController,
                                  placeholder: const Text('John'),
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) =>
                                      FocusScope.of(context).nextFocus(),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppFormField(
                                label: 'Last name',
                                child: TextField(
                                  controller: _lastNameController,
                                  placeholder: const Text('Doe'),
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) =>
                                      FocusScope.of(context).nextFocus(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppFormField(
                          label: 'Middle name',
                          optional: true,
                          child: TextField(
                            controller: _fatherNameController,
                            placeholder: const Text('Optional'),
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                          ),
                        ),
                        AppFormField(
                          label: 'Email',
                          child: TextField(
                            controller: _emailController,
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
                            placeholder: const Text('At least 8 characters'),
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            onSubmitted: (_) =>
                                FocusScope.of(context).nextFocus(),
                          ),
                        ),
                        AppFormField(
                          label: 'Confirm password',
                          child: TextField(
                            controller: _passwordConfirmationController,
                            placeholder: const Text('Repeat the password'),
                            obscureText: true,
                            textInputAction: TextInputAction.go,
                            onSubmitted: (_) => _handleRegister(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => FormSubmitButton(
                            label: 'Create account',
                            loadingLabel: 'Creating account…',
                            loading: state is AuthLoading,
                            onPressed: _handleRegister,
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
                        'Already have an account?',
                        style: context.text.itemSubtitle,
                      ),
                      GhostButton(
                        size: ButtonSize.small,
                        density: ButtonDensity.compact,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Sign in'),
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
