import 'package:equatable/equatable.dart';

abstract class SleepEntryEvent extends Equatable {
  const SleepEntryEvent();

  @override
  List<Object?> get props => [];
}

class CreateSleepEntry extends SleepEntryEvent {
  final String date;
  final String sleepStart;
  final String sleepEnd;
  final int quality;
  final String? note;

  const CreateSleepEntry({
    required this.date,
    required this.sleepStart,
    required this.sleepEnd,
    required this.quality,
    this.note,
  });

  @override
  List<Object?> get props => [date, sleepStart, sleepEnd, quality, note];
}
