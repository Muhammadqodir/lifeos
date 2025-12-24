import '../../domain/entities/user.dart';

class UserDto {
  final int id;
  final String firstName;
  final String lastName;
  final String? fatherName;
  final String? dateOfBirth;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final String? lastLoginAt;
  final String createdAt;
  final String updatedAt;

  UserDto({
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

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fatherName: json['father_name'],
      dateOfBirth: json['date_of_birth'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      isActive: json['is_active'],
      lastLoginAt: json['last_login_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  User toEntity() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      fatherName: fatherName,
      dateOfBirth: dateOfBirth != null ? DateTime.parse(dateOfBirth!) : null,
      email: email,
      avatarUrl: avatarUrl,
      isActive: isActive,
      lastLoginAt: lastLoginAt != null ? DateTime.parse(lastLoginAt!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

class AuthResponseDto {
  final UserDto user;
  final String token;

  AuthResponseDto({required this.user, required this.token});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      user: UserDto.fromJson(json['user']),
      token: json['token'],
    );
  }
}
