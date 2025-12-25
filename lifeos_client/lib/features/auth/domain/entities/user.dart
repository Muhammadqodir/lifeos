import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? fatherName;
  final DateTime? dateOfBirth;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.fatherName,
    this.dateOfBirth,
    required this.email,
    this.avatarUrl,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        fatherName,
        dateOfBirth,
        email,
        avatarUrl,
        isActive,
        lastLoginAt,
        createdAt,
        updatedAt,
      ];
}
