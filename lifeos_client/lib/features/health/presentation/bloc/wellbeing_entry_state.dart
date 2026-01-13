import 'package:equatable/equatable.dart';
import '../../data/models/wellbeing_entry_dto.dart';

abstract class WellbeingEntryState extends Equatable {
  const WellbeingEntryState();

  @override
  List<Object?> get props => [];
}

class WellbeingEntryInitial extends WellbeingEntryState {}

class WellbeingEntryLoading extends WellbeingEntryState {}

class WellbeingEntrySuccess extends WellbeingEntryState {
  final WellbeingEntryDto wellbeingEntry;

  const WellbeingEntrySuccess({required this.wellbeingEntry});

  @override
  List<Object?> get props => [wellbeingEntry];
}

class WellbeingEntryFailure extends WellbeingEntryState {
  final String message;

  const WellbeingEntryFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
