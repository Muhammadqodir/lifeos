import 'package:equatable/equatable.dart';

class CreateProjectDto extends Equatable {
  final String title;
  final String? description;
  final String color;
  final String? icon;
  final List<String>? tags;

  const CreateProjectDto({
    required this.title,
    this.description,
    required this.color,
    this.icon,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'color': color,
      'icon': icon,
      'tags': tags,
    };
  }

  @override
  List<Object?> get props => [title, description, color, icon, tags];
}
