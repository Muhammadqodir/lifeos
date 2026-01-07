<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WorkoutSet extends Model
{
    use HasFactory;
    protected $fillable = [
        'workout_exercise_id',
        'set_index',
        'weight_kg',
        'reps',
        'duration_seconds',
        'distance_meters',
        'rpe',
        'is_done',
    ];

    protected $casts = [
        'set_index' => 'integer',
        'weight_kg' => 'decimal:2',
        'reps' => 'integer',
        'duration_seconds' => 'integer',
        'distance_meters' => 'decimal:2',
        'rpe' => 'integer',
        'is_done' => 'boolean',
    ];

    public function workoutExercise(): BelongsTo
    {
        return $this->belongsTo(WorkoutExercise::class);
    }

    /**
     * Calculate estimated 1RM using Epley formula
     * Only applicable for strength exercises
     */
    public function getEstimated1RM(): ?float
    {
        if (!$this->weight_kg || !$this->reps) {
            return null;
        }
        return (float) ($this->weight_kg * (1 + $this->reps / 30.0));
    }

    /**
     * Check if this is a cardio/time-based set
     */
    public function isCardio(): bool
    {
        return $this->duration_seconds !== null || $this->distance_meters !== null;
    }
}
