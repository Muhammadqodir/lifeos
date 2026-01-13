import 'package:equatable/equatable.dart';

abstract class WellbeingEntryEvent extends Equatable {
  const WellbeingEntryEvent();

  @override
  List<Object?> get props => [];
}

class CreateWellbeingEntry extends WellbeingEntryEvent {
  final String date;
  final int energy;
  final int stress;
  final String? note;

  const CreateWellbeingEntry({
    required this.date,
    required this.energy,
    required this.stress,
    this.note,
  });

  @override
  List<Object?> get props => [date, energy, stress, note];
}
