<?php

namespace App\Models;

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
    use HasFactory, SoftDeletes;

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
     * Calculate the current streak for this habit.
     */
    public function getCurrentStreak(): int
    {
        $entries = $this->entries()
            ->orderBy('date', 'desc')
            ->get();

        if ($entries->isEmpty()) {
            return 0;
        }

        $streak = 0;
        $expectedDate = Carbon::today();
        $firstEntry = true;

        foreach ($entries as $entry) {
            $entryDate = Carbon::parse($entry->date);

            if ($this->frequency === self::FREQUENCY_DAILY) {
                // For daily habits, allow starting from today or yesterday
                if ($firstEntry) {
                    if ($entryDate->isToday() || $entryDate->isYesterday()) {
                        $streak++;
                        $expectedDate = $entryDate->copy()->subDay();
                        $firstEntry = false;
                    } else {
                        // Streak is broken, no recent activity
                        break;
                    }
                } else {
                    // Check consecutive days
                    if ($entryDate->isSameDay($expectedDate)) {
                        $streak++;
                        $expectedDate = $expectedDate->subDay();
                    } else {
                        break;
                    }
                }
            } elseif ($this->frequency === self::FREQUENCY_WEEKLY) {
                // For weekly habits, allow starting from current week or last week
                if ($firstEntry) {
                    $currentWeekStart = Carbon::now()->startOfWeek();
                    $lastWeekStart = Carbon::now()->subWeek()->startOfWeek();

                    if ($entryDate->greaterThanOrEqualTo($lastWeekStart)) {
                        $streak++;
                        $expectedDate = $entryDate->copy()->subWeek();
                        $firstEntry = false;
                    } else {
                        break;
                    }
                } else {
                    if ($entryDate->isSameWeek($expectedDate)) {
                        $streak++;
                        $expectedDate = $expectedDate->subWeek();
                    } else {
                        break;
                    }
                }
            } elseif ($this->frequency === self::FREQUENCY_MONTHLY) {
                // For monthly habits, allow starting from current month or last month
                if ($firstEntry) {
                    $currentMonth = Carbon::now()->startOfMonth();
                    $lastMonth = Carbon::now()->subMonth()->startOfMonth();

                    if ($entryDate->greaterThanOrEqualTo($lastMonth)) {
                        $streak++;
                        $expectedDate = $entryDate->copy()->subMonth();
                        $firstEntry = false;
                    } else {
                        break;
                    }
                } else {
                    if ($entryDate->isSameMonth($expectedDate)) {
                        $streak++;
                        $expectedDate = $expectedDate->subMonth();
                    } else {
                        break;
                    }
                }
            }
        }

        return $streak;
    }

    /**
     * Calculate the longest streak for this habit.
     */
    public function getLongestStreak(): int
    {
        $entries = $this->entries()
            ->orderBy('date', 'asc')
            ->get();

        if ($entries->isEmpty()) {
            return 0;
        }

        $longestStreak = 1;
        $currentStreak = 1;
        $previousDate = null;

        foreach ($entries as $index => $entry) {
            $entryDate = Carbon::parse($entry->date);

            if ($previousDate === null) {
                $previousDate = $entryDate;
                continue;
            }

            $isConsecutive = false;

            if ($this->frequency === self::FREQUENCY_DAILY) {
                // Check if it's the next day
                $isConsecutive = $previousDate->copy()->addDay()->isSameDay($entryDate);
            } elseif ($this->frequency === self::FREQUENCY_WEEKLY) {
                // Check if it's in the next week
                $nextWeekStart = $previousDate->copy()->addWeek()->startOfWeek();
                $nextWeekEnd = $previousDate->copy()->addWeek()->endOfWeek();
                $isConsecutive = $entryDate->between($nextWeekStart, $nextWeekEnd);
            } elseif ($this->frequency === self::FREQUENCY_MONTHLY) {
                // Check if it's in the next month
                $nextMonthStart = $previousDate->copy()->addMonth()->startOfMonth();
                $nextMonthEnd = $previousDate->copy()->addMonth()->endOfMonth();
                $isConsecutive = $entryDate->between($nextMonthStart, $nextMonthEnd);
            }

            if ($isConsecutive) {
                $currentStreak++;
                $longestStreak = max($longestStreak, $currentStreak);
            } else {
                $currentStreak = 1;
            }

            $previousDate = $entryDate;
        }

        return $longestStreak;
    }

    /**
     * Calculate the completion rate since habit creation.
     */
    public function getCompletionRate(): float
    {
        // Calculate from habit creation date to today
        $startDate = Carbon::parse($this->created_at)->startOfDay();
        $endDate = Carbon::today();

        // Get total days since creation
        $totalDays = $startDate->diffInDays($endDate) + 1;

        if ($totalDays === 0) {
            return 0;
        }

        $entriesCount = $this->entries()
            ->whereBetween('date', [$startDate, $endDate])
            ->count();

        if ($this->frequency === self::FREQUENCY_DAILY) {
            $expectedEntries = $totalDays;
        } elseif ($this->frequency === self::FREQUENCY_WEEKLY) {
            // Calculate number of weeks since creation
            $expectedEntries = ceil($totalDays / 7);
        } elseif ($this->frequency === self::FREQUENCY_MONTHLY) {
            // Calculate number of months since creation
            $expectedEntries = $startDate->diffInMonths($endDate) + 1;
        } else {
            $expectedEntries = $totalDays;
        }

        if ($expectedEntries === 0) {
            return 0;
        }

        return round(($entriesCount / $expectedEntries) * 100, 2);
    }

    /**
     * Check if the habit is completed today.
     */
    public function isCompletedToday(): bool
    {
        return $this->entries()
            ->whereDate('date', Carbon::today())
            ->exists();
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
