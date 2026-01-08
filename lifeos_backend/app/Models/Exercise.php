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
}
