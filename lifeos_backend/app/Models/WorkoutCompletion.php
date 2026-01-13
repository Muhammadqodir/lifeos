<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WorkoutCompletion extends Model
{
    use HasFactory;

    protected $fillable = [
        'workout_session_id',
        'photo_path',
        'body_weight_kg',
        'height_cm',
        'biceps_cm',
        'chest_cm',
        'waist_cm',
        'thighs_cm',
        'calfs_cm',
        'notes',
    ];

    protected $casts = [
        'body_weight_kg' => 'decimal:2',
        'height_cm' => 'decimal:2',
        'biceps_cm' => 'decimal:2',
        'chest_cm' => 'decimal:2',
        'waist_cm' => 'decimal:2',
        'thighs_cm' => 'decimal:2',
        'calfs_cm' => 'decimal:2',
    ];

    public function workoutSession(): BelongsTo
    {
        return $this->belongsTo(WorkoutSession::class);
    }
}
