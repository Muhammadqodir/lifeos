import 'package:equatable/equatable.dart';

class WellbeingEntryDto extends Equatable {
  final int id;
  final String date;
  final int? energy;
  final int? stress;
  final String? note;

  const WellbeingEntryDto({
    required this.id,
    required this.date,
    this.energy,
    this.stress,
    this.note,
  });

  factory WellbeingEntryDto.fromJson(Map<String, dynamic> json) {
    return WellbeingEntryDto(
      id: json['id'] as int,
      date: json['date'] as String,
      energy: json['energy'] as int?,
      stress: json['stress'] as int?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'energy': energy,
      'stress': stress,
      'note': note,
    };
  }

  @override
  List<Object?> get props => [id, date, energy, stress, note];
}
