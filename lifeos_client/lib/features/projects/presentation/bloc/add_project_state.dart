import 'package:equatable/equatable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

abstract class AddProjectState extends Equatable {
  const AddProjectState();

  @override
  List<Object?> get props => [];
}

class AddProjectWithData extends AddProjectState {
  final String title;
  final String description;
  final String color;
  final XFile? iconImage;
  final List<String> tags;

  const AddProjectWithData({
    required this.title,
    required this.description,
    required this.color,
    this.iconImage,
    required this.tags,
  });

  @override
  List<Object?> get props => [title, description, color, iconImage, tags];
}

class AddProjectInitial extends AddProjectWithData {
  const AddProjectInitial()
      : super(
          title: '',
          description: '',
          color: 'FF6B7280',
          iconImage: null,
          tags: const [],
        );
}

class AddProjectEditing extends AddProjectWithData {
  const AddProjectEditing({
    required super.title,
    required super.description,
    required super.color,
    super.iconImage,
    required super.tags,
  });

  AddProjectEditing copyWith({
    String? title,
    String? description,
    String? color,
    XFile? iconImage,
    List<String>? tags,
  }) {
    return AddProjectEditing(
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      iconImage: iconImage ?? this.iconImage,
      tags: tags ?? this.tags,
    );
  }
}

class AddProjectSubmitting extends AddProjectWithData {
  const AddProjectSubmitting({
    required super.title,
    required super.description,
    required super.color,
    super.iconImage,
    required super.tags,
  });
}

class AddProjectSuccess extends AddProjectWithData {
  const AddProjectSuccess({
    required super.title,
    required super.description,
    required super.color,
    super.iconImage,
    required super.tags,
  });
}

class AddProjectError extends AddProjectWithData {
  final String message;

  const AddProjectError({
    required this.message,
    required super.title,
    required super.description,
    required super.color,
    super.iconImage,
    required super.tags,
  });

  @override
  List<Object?> get props => [message, title, description, color, iconImage, tags];
}
