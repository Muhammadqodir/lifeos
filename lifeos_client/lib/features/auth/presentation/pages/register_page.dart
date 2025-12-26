import 'package:lifeos_client/utils/toast.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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
      backgroundColor: Colors.white,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showToast(
              context: context,
              builder: (context, overlay) {
                return Utils.buildToast(
                  context,
                  overlay,
                  'Error',
                  state.message,
                );
              },
              location: ToastLocation.bottomCenter,
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 400,
              child: Card(
                child: Form(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      TextField(
                        controller: _firstNameController,
                        placeholder: const Text('John'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _lastNameController,
                        placeholder: const Text('Doe'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _fatherNameController,
                        placeholder: const Text('Middle name'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        placeholder: const Text('email@example.com'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        placeholder: const Text('Minimum 8 characters'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordConfirmationController,
                        placeholder: const Text('Re-enter password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return PrimaryButton(
                            onPressed: isLoading ? null : _handleRegister,
                            child: isLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Create Account'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                          ),
                          Button.ghost(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Sign In'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
