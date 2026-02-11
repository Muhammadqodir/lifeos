<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Exercise extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'name',
        'type',
        'image',
        'muscle_group',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function workoutExercises(): HasMany
    {
        return $this->hasMany(WorkoutExercise::class);
    }

    /**
     * Scope for exercises accessible by a user (system + user's custom)
     */
    public function scopeAccessibleBy(Builder $query, int $userId): Builder
    {
        return $query->where(function ($q) use ($userId) {
            $q->whereNull('user_id')
              ->orWhere('user_id', $userId);
        });
    }

    /**
     * Check if exercise is a system exercise
     */
    public function isSystem(): bool
    {
        return is_null($this->user_id);
    }

    /**
     * Get the most recent completed sets for this exercise
     * Used to show hints when creating new sets
     */
    public function getLastSessionSets(int $userId)
    {
        // Find the most recent completed session with this exercise
        $lastSession = WorkoutSession::query()
            ->where('user_id', $userId)
            ->whereNotNull('ended_at')
            ->whereHas('workoutExercises', function ($query) {
                $query->where('exercise_id', $this->id);
            })
            ->orderBy('ended_at', 'desc')
            ->first();

        if (!$lastSession) {
            return collect([]);
        }

        // Get the workout exercise for this exercise in that session
        $workoutExercise = $lastSession->workoutExercises()
            ->where('exercise_id', $this->id)
            ->first();

        if (!$workoutExercise) {
            return collect([]);
        }

        // Return the sets for that workout exercise
        return $workoutExercise->sets()->orderBy('set_index')->get();
    }
}
