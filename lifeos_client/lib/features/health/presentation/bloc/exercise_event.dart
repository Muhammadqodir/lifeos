import 'package:equatable/equatable.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExercises extends ExerciseEvent {}

class FilterExercises extends ExerciseEvent {
  final String? type;
  final String? muscleGroup;

  const FilterExercises({this.type, this.muscleGroup});

  @override
  List<Object?> get props => [type, muscleGroup];
}

class SearchExercises extends ExerciseEvent {
  final String query;

  const SearchExercises(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateExercise extends ExerciseEvent {
  final String name;
  final String type;
  final String? muscleGroup;
  final String? imagePath;

  const CreateExercise({
    required this.name,
    required this.type,
    this.muscleGroup,
    this.imagePath,
  });

  @override
  List<Object?> get props => [name, type, muscleGroup, imagePath];
}

class DeleteExercise extends ExerciseEvent {
  final int exerciseId;

  const DeleteExercise(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}
