import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<ShadFormState>();
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
    if (_formKey.currentState!.saveAndValidate()) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ShadToaster.of(context).show(
              ShadToast.destructive(
                title: const Text('Error'),
                description: Text(state.message),
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 400,
              child: ShadCard(
                title: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                description: const Text('Fill in your details to register'),
                child: ShadForm(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      ShadInputFormField(
                        id: 'first_name',
                        label: const Text('First Name'),
                        controller: _firstNameController,
                        placeholder: const Text('John'),
                        validator: (value) {
                          if (value.isEmpty) return 'First name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        id: 'last_name',
                        label: const Text('Last Name'),
                        controller: _lastNameController,
                        placeholder: const Text('Doe'),
                        validator: (value) {
                          if (value.isEmpty) return 'Last name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        id: 'father_name',
                        label: const Text('Father Name (Optional)'),
                        controller: _fatherNameController,
                        placeholder: const Text('Middle name'),
                      ),
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        id: 'email',
                        label: const Text('Email'),
                        controller: _emailController,
                        placeholder: const Text('email@example.com'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value.isEmpty) return 'Email is required';
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        id: 'password',
                        label: const Text('Password'),
                        controller: _passwordController,
                        placeholder: const Text('Minimum 8 characters'),
                        obscureText: true,
                        validator: (value) {
                          if (value.isEmpty) return 'Password is required';
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ShadInputFormField(
                        id: 'password_confirmation',
                        label: const Text('Confirm Password'),
                        controller: _passwordConfirmationController,
                        placeholder: const Text('Re-enter password'),
                        obscureText: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Password confirmation is required';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return ShadButton(
                            onPressed: isLoading ? null : _handleRegister,
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
                            style: TextStyle(color: Colors.black87),
                          ),
                          ShadButton.ghost(
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
