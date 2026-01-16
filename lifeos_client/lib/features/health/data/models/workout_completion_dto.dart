import 'package:equatable/equatable.dart';

class WorkoutCompletionDto extends Equatable {
  final int? id;
  final int? workoutSessionId;
  final String? photoPath;
  final double? bodyWeightKg;
  final double? heightCm;
  final double? bicepsCm;
  final double? chestCm;
  final double? waistCm;
  final double? thighsCm;
  final double? calfsCm;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkoutCompletionDto({
    this.id,
    this.workoutSessionId,
    this.photoPath,
    this.bodyWeightKg,
    this.heightCm,
    this.bicepsCm,
    this.chestCm,
    this.waistCm,
    this.thighsCm,
    this.calfsCm,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutCompletionDto.fromJson(Map<String, dynamic> json) {
    return WorkoutCompletionDto(
      id: json['id'] as int?,
      workoutSessionId: json['workout_session_id'] as int?,
      photoPath: json['photo_path'] as String?,
      bodyWeightKg: json['body_weight_kg'] != null
          ? (json['body_weight_kg'] as num).toDouble()
          : null,
      heightCm: json['height_cm'] != null
          ? (json['height_cm'] as num).toDouble()
          : null,
      bicepsCm: json['biceps_cm'] != null
          ? (json['biceps_cm'] as num).toDouble()
          : null,
      chestCm: json['chest_cm'] != null
          ? (json['chest_cm'] as num).toDouble()
          : null,
      waistCm: json['waist_cm'] != null
          ? (json['waist_cm'] as num).toDouble()
          : null,
      thighsCm: json['thighs_cm'] != null
          ? (json['thighs_cm'] as num).toDouble()
          : null,
      calfsCm: json['calfs_cm'] != null
          ? (json['calfs_cm'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (workoutSessionId != null) 'workout_session_id': workoutSessionId,
      'photo_path': photoPath,
      'body_weight_kg': bodyWeightKg,
      'height_cm': heightCm,
      'biceps_cm': bicepsCm,
      'chest_cm': chestCm,
      'waist_cm': waistCm,
      'thighs_cm': thighsCm,
      'calfs_cm': calfsCm,
      'notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  WorkoutCompletionDto copyWith({
    int? id,
    int? workoutSessionId,
    String? photoPath,
    double? bodyWeightKg,
    double? heightCm,
    double? bicepsCm,
    double? chestCm,
    double? waistCm,
    double? thighsCm,
    double? calfsCm,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutCompletionDto(
      id: id ?? this.id,
      workoutSessionId: workoutSessionId ?? this.workoutSessionId,
      photoPath: photoPath ?? this.photoPath,
      bodyWeightKg: bodyWeightKg ?? this.bodyWeightKg,
      heightCm: heightCm ?? this.heightCm,
      bicepsCm: bicepsCm ?? this.bicepsCm,
      chestCm: chestCm ?? this.chestCm,
      waistCm: waistCm ?? this.waistCm,
      thighsCm: thighsCm ?? this.thighsCm,
      calfsCm: calfsCm ?? this.calfsCm,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workoutSessionId,
        photoPath,
        bodyWeightKg,
        heightCm,
        bicepsCm,
        chestCm,
        waistCm,
        thighsCm,
        calfsCm,
        notes,
        createdAt,
        updatedAt,
      ];
}
