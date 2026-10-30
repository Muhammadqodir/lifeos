<?php

namespace App\Services;

use App\Models\Habit;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;

/**
 * Streaks and completion rate for a habit.
 *
 * A "period" is a day, ISO week or month depending on the habit's
 * frequency; a streak counts consecutive periods with at least one entry.
 * The Flutter client computes the same numbers from its local copy (see
 * lib/features/habits/domain/habit_stats.dart); keep the two in step.
 */
class HabitStatsService
{
    /**
     * @return array{current_streak: int, longest_streak: int, completion_rate: float, is_completed_today: bool, total_entries: int, entries_by_date: array<string, bool>}
     */
    public function stats(Habit $habit, int $days = 30, ?Carbon $today = null): array
    {
        $today = ($today ?? Carbon::today())->copy()->startOfDay();
        $dates = $this->entryDates($habit);
        $from = $today->copy()->subDays($days - 1)->toDateString();

        return [
            'current_streak' => $this->currentStreak($habit, $dates, $today),
            'longest_streak' => $this->longestStreak($habit, $dates),
            'completion_rate' => $this->completionRate($habit, $dates, $today),
            'is_completed_today' => $dates->contains($today->toDateString()),
            'total_entries' => $dates->count(),
            'entries_by_date' => $dates
                ->filter(fn (string $date) => $date >= $from && $date <= $today->toDateString())
                ->sortDesc()
                ->mapWithKeys(fn (string $date) => [$date => true])
                ->all(),
        ];
    }

    /**
     * Consecutive periods with an entry, ending in the current or the
     * previous period (so a daily streak survives until tonight).
     */
    public function currentStreak(Habit $habit, ?Collection $dates = null, ?Carbon $today = null): int
    {
        $today = ($today ?? Carbon::today())->copy()->startOfDay();
        $periods = $this->periods($habit, $dates ?? $this->entryDates($habit))
            ->filter(fn (string $period) => $period <= $this->periodKey($habit, $today))
            ->sortDesc()
            ->values();

        $expected = $today->copy();
        if ($periods->first() !== $this->periodKey($habit, $expected)) {
            $expected = $this->previousPeriod($habit, $expected);
        }

        $streak = 0;
        foreach ($periods as $period) {
            if ($period !== $this->periodKey($habit, $expected)) {
                break;
            }
            $streak++;
            $expected = $this->previousPeriod($habit, $expected);
        }

        return $streak;
    }

    public function longestStreak(Habit $habit, ?Collection $dates = null): int
    {
        $periods = $this->periods($habit, $dates ?? $this->entryDates($habit))->sort()->values();

        $longest = 0;
        $run = 0;
        $previous = null;
        foreach ($periods as $period) {
            $run = $previous !== null && $this->periodKey($habit, $this->nextPeriod($habit, $this->periodStart($habit, $previous))) === $period
                ? $run + 1
                : 1;
            $longest = max($longest, $run);
            $previous = $period;
        }

        return $longest;
    }

    /**
     * Percentage of periods since the habit was created that have an entry.
     */
    public function completionRate(Habit $habit, ?Collection $dates = null, ?Carbon $today = null): float
    {
        $today = ($today ?? Carbon::today())->copy()->startOfDay();
        $start = Carbon::parse($habit->created_at)->startOfDay();
        if ($start->greaterThan($today)) {
            return 0.0;
        }

        $totalDays = (int) $start->diffInDays($today) + 1;
        $expected = match ($habit->frequency) {
            Habit::FREQUENCY_WEEKLY => (int) ceil($totalDays / 7),
            Habit::FREQUENCY_MONTHLY => (int) $start->copy()->startOfMonth()->diffInMonths($today->copy()->startOfMonth()) + 1,
            default => $totalDays,
        };

        $inRange = ($dates ?? $this->entryDates($habit))
            ->filter(fn (string $date) => $date >= $start->toDateString() && $date <= $today->toDateString());
        $done = $this->periods($habit, $inRange)->count();

        return $expected > 0 ? round(min($done / $expected, 1) * 100, 2) : 0.0;
    }

    /** @return Collection<int, string> Y-m-d dates of the habit's entries. */
    private function entryDates(Habit $habit): Collection
    {
        return $habit->entries()
            ->pluck('date')
            ->map(fn ($date) => Carbon::parse($date)->toDateString())
            ->unique()
            ->values();
    }

    /** @return Collection<int, string> */
    private function periods(Habit $habit, Collection $dates): Collection
    {
        return $dates
            ->map(fn (string $date) => $this->periodKey($habit, Carbon::parse($date)))
            ->unique()
            ->values();
    }

    /** Sortable key of the period containing $date. */
    private function periodKey(Habit $habit, Carbon $date): string
    {
        return match ($habit->frequency) {
            Habit::FREQUENCY_WEEKLY => $date->copy()->startOfWeek(Carbon::MONDAY)->toDateString(),
            Habit::FREQUENCY_MONTHLY => $date->format('Y-m'),
            default => $date->toDateString(),
        };
    }

    private function periodStart(Habit $habit, string $key): Carbon
    {
        return $habit->frequency === Habit::FREQUENCY_MONTHLY
            ? Carbon::parse($key.'-01')
            : Carbon::parse($key);
    }

    private function previousPeriod(Habit $habit, Carbon $date): Carbon
    {
        return match ($habit->frequency) {
            Habit::FREQUENCY_WEEKLY => $date->copy()->subWeek(),
            Habit::FREQUENCY_MONTHLY => $date->copy()->startOfMonth()->subMonth(),
            default => $date->copy()->subDay(),
        };
    }

    private function nextPeriod(Habit $habit, Carbon $date): Carbon
    {
        return match ($habit->frequency) {
            Habit::FREQUENCY_WEEKLY => $date->copy()->addWeek(),
            Habit::FREQUENCY_MONTHLY => $date->copy()->startOfMonth()->addMonth(),
            default => $date->copy()->addDay(),
        };
    }
}
