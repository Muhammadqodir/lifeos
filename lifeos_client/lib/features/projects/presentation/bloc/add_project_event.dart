import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class AddProjectEvent extends Equatable {
  const AddProjectEvent();

  @override
  List<Object?> get props => [];
}

class AddProjectSubmitted extends AddProjectEvent {
  final String title;
  final String? description;
  final String color;
  final XFile? iconImage;
  final List<String>? tags;

  const AddProjectSubmitted({
    required this.title,
    this.description,
    required this.color,
    this.iconImage,
    this.tags,
  });

  @override
  List<Object?> get props => [title, description, color, iconImage, tags];
}
