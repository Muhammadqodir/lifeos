import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<ShadFormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.saveAndValidate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // Show toast
            ShadToaster.of(context).show(
              ShadToast.destructive(
                title: const Text('Error'),
                description: Text(state.message),
              ),
            );
            
            // Clear password but keep email when error occurs
            _passwordController.clear();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 400,
              child: ShadCard(
                title: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                description: const Text('Enter your credentials to continue'),
                child: ShadForm(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      ShadInputFormField(
                        id: 'email',
                        label: const Text('Email'),
                        controller: _emailController,
                        placeholder: const Text('email@example.com'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        id: 'password',
                        label: const Text('Password'),
                        controller: _passwordController,
                        placeholder: const Text('Enter your password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return ShadButton(
                            onPressed: isLoading ? null : _handleLogin,
                            child: isLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Sign In'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: Colors.black87),
                          ),
                          ShadButton.ghost(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<AuthBloc>(),
                                    child: const RegisterPage(),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Sign Up'),
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
