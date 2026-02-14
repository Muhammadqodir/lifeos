import 'package:equatable/equatable.dart';

abstract class LogEntryEvent extends Equatable {
  const LogEntryEvent();

  @override
  List<Object?> get props => [];
}

class LogEntrySubmitted extends LogEntryEvent {
  final int habitId;
  final String date;
  final String? completedAt;
  final String? note;

  const LogEntrySubmitted({
    required this.habitId,
    required this.date,
    this.completedAt,
    this.note,
  });

  @override
  List<Object?> get props => [habitId, date, completedAt, note];
}

class DeleteEntrySubmitted extends LogEntryEvent {
  final int entryId;

  const DeleteEntrySubmitted({required this.entryId});

  @override
  List<Object?> get props => [entryId];
}
