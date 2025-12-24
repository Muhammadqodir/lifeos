import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'LifeOS',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ShadCard(
                  width: 400,
                  title: const Text(
                    'Profile',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildInfoRow('Name', user.fullName),
                      if (user.fatherName != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow('Father Name', user.fatherName!),
                      ],
                      const SizedBox(height: 12),
                      _buildInfoRow('Email', user.email),
                      if (user.dateOfBirth != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Date of Birth',
                          '${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}',
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Status',
                        user.isActive ? 'Active' : 'Inactive',
                        valueColor:
                            user.isActive ? Colors.green : Colors.red,
                      ),
                      if (user.lastLoginAt != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Last Login',
                          '${user.lastLoginAt!.day}/${user.lastLoginAt!.month}/${user.lastLoginAt!.year}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
