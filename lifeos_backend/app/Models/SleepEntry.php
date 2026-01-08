<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SleepEntry extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'date',
        'sleep_start',
        'sleep_end',
        'quality',
        'note',
    ];

    protected $casts = [
        'date' => 'date',
        'sleep_start' => 'datetime',
        'sleep_end' => 'datetime',
        'quality' => 'integer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get duration in hours
     */
    public function getDurationHours(): ?float
    {
        if (!$this->sleep_start || !$this->sleep_end) {
            return null;
        }

        return $this->sleep_start->diffInMinutes($this->sleep_end) / 60;
    }
}
