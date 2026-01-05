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
        'rpe',
        'is_done',
    ];

    protected $casts = [
        'set_index' => 'integer',
        'weight_kg' => 'decimal:2',
        'reps' => 'integer',
        'rpe' => 'integer',
        'is_done' => 'boolean',
    ];

    public function workoutExercise(): BelongsTo
    {
        return $this->belongsTo(WorkoutExercise::class);
    }

    /**
     * Calculate estimated 1RM using Epley formula
     */
    public function getEstimated1RM(): float
    {
        return (float) ($this->weight_kg * (1 + $this->reps / 30.0));
    }
}
