<?php

namespace App\Models;

use App\Models\Concerns\Syncable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Carbon;
use App\Models\User;
use App\Models\HabitEntry;

class Habit extends Model
{
    use HasFactory, SoftDeletes, Syncable;

    // Status constants
    public const STATUS_ACTIVE = 'active';
    public const STATUS_ARCHIVED = 'archived';

    // Frequency constants
    public const FREQUENCY_DAILY = 'daily';
    public const FREQUENCY_WEEKLY = 'weekly';
    public const FREQUENCY_MONTHLY = 'monthly';

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'color',
        'icon',
        'status',
        'frequency',
        'frequency_days',
        'reminder_time',
        'goal_duration',
        'tags',
    ];

    protected $casts = [
        'frequency_days' => 'array',
        'tags' => 'array',
        'goal_duration' => 'integer',
    ];

    /**
     * Get the user that owns the habit.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the entries for the habit.
     */
    public function entries(): HasMany
    {
        return $this->hasMany(HabitEntry::class);
    }

    /**
     * Get allowed status values.
     */
    public static function getAllowedStatuses(): array
    {
        return [
            self::STATUS_ACTIVE,
            self::STATUS_ARCHIVED,
        ];
    }

    /**
     * Get allowed frequency values.
     */
    public static function getAllowedFrequencies(): array
    {
        return [
            self::FREQUENCY_DAILY,
            self::FREQUENCY_WEEKLY,
            self::FREQUENCY_MONTHLY,
        ];
    }

    /**
     * Check if the habit is completed today.
     */
    public function isCompletedToday(): bool
    {
        // Prefer the flag loaded via withCompletedToday() to avoid one query per habit.
        if (array_key_exists('completed_today', $this->attributes)) {
            return (bool) $this->attributes['completed_today'];
        }

        return $this->entries()
            ->whereDate('date', Carbon::today())
            ->exists();
    }

    /**
     * Eager-load whether each habit has an entry for today.
     */
    public function scopeWithCompletedToday($query)
    {
        return $query->withExists([
            'entries as completed_today' => fn ($q) => $q->whereDate('date', Carbon::today()),
        ]);
    }

    /**
     * Get entries for a specific date range.
     */
    public function getEntriesInRange(Carbon $startDate, Carbon $endDate)
    {
        return $this->entries()
            ->whereBetween('date', [$startDate, $endDate])
            ->orderBy('date', 'desc')
            ->get();
    }
}
