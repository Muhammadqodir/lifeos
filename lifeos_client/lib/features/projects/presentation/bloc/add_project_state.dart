import 'package:equatable/equatable.dart';

abstract class AddProjectState extends Equatable {
  const AddProjectState();

  @override
  List<Object?> get props => [];
}

class AddProjectInitial extends AddProjectState {
  const AddProjectInitial();
}

class AddProjectSubmitting extends AddProjectState {
  const AddProjectSubmitting();
}

class AddProjectSuccess extends AddProjectState {
  const AddProjectSuccess();
}

class AddProjectError extends AddProjectState {
  final String message;

  const AddProjectError({required this.message});

  @override
  List<Object?> get props => [message];
}
