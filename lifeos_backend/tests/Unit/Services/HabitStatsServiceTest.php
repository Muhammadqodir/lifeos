<?php

namespace Tests\Unit\Services;

use App\Models\Habit;
use App\Models\HabitEntry;
use App\Models\User;
use App\Services\HabitStatsService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class HabitStatsServiceTest extends TestCase
{
    use RefreshDatabase;

    private function habit(string $frequency, array $dates, string $createdAt = '2026-01-01'): Habit
    {
        $user = User::factory()->create();
        $habit = Habit::create([
            'user_id' => $user->id,
            'title' => 'Read',
            'frequency' => $frequency,
        ]);
        $habit->forceFill(['created_at' => $createdAt])->save();
        foreach ($dates as $date) {
            HabitEntry::create([
                'habit_id' => $habit->id,
                'user_id' => $user->id,
                'date' => $date,
                'completed_at' => $date.' 08:00:00',
            ]);
        }

        return $habit->fresh();
    }

    public function test_daily_streak_survives_until_the_day_ends(): void
    {
        $today = Carbon::parse('2026-03-10');
        $habit = $this->habit('daily', ['2026-03-07', '2026-03-08', '2026-03-09']);
        $service = new HabitStatsService;

        $this->assertSame(3, $service->currentStreak($habit, today: $today));
        $this->assertSame(0, $service->currentStreak($habit, today: Carbon::parse('2026-03-11')));
        $this->assertSame(3, $service->longestStreak($habit));
    }

    public function test_weekly_streak_counts_weeks_not_days(): void
    {
        // Mon 2 Mar, Wed 4 Mar (same week), Tue 10 Mar.
        $habit = $this->habit('weekly', ['2026-03-02', '2026-03-04', '2026-03-10']);
        $service = new HabitStatsService;

        $this->assertSame(2, $service->currentStreak($habit, today: Carbon::parse('2026-03-12')));
        $this->assertSame(2, $service->longestStreak($habit));
    }

    public function test_completion_rate_is_capped_and_counts_periods(): void
    {
        $habit = $this->habit('weekly', ['2026-03-02', '2026-03-03', '2026-03-04'], createdAt: '2026-03-02');

        $rate = (new HabitStatsService)->completionRate($habit, today: Carbon::parse('2026-03-08'));

        $this->assertSame(100.0, $rate);
    }

    public function test_stats_payload(): void
    {
        $habit = $this->habit('daily', ['2026-03-09', '2026-03-10']);

        $stats = (new HabitStatsService)->stats($habit, 7, Carbon::parse('2026-03-10'));

        $this->assertTrue($stats['is_completed_today']);
        $this->assertSame(2, $stats['total_entries']);
        $this->assertSame(['2026-03-10' => true, '2026-03-09' => true], $stats['entries_by_date']);
    }
}
