<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class WorkoutExercise extends Model
{
    use HasFactory;
    protected $fillable = [
        'session_id',
        'exercise_id',
        'sort_order',
    ];

    protected $casts = [
        'sort_order' => 'integer',
    ];

    public function session(): BelongsTo
    {
        return $this->belongsTo(WorkoutSession::class, 'session_id');
    }

    public function exercise(): BelongsTo
    {
        return $this->belongsTo(Exercise::class);
    }

    public function sets(): HasMany
    {
        return $this->hasMany(WorkoutSet::class)->orderBy('set_index');
    }
}
