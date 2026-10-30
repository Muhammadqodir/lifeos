<?php

namespace Tests\Unit\Services;

use App\Models\User;
use App\Models\WorkoutSession;
use App\Services\WorkoutService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class WorkoutServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_streak_counts_consecutive_days_back_from_today_or_yesterday(): void
    {
        $user = User::factory()->create();
        foreach (['2026-03-07 18:00', '2026-03-08 07:00', '2026-03-08 19:00', '2026-03-09 18:00', '2026-03-05 18:00'] as $at) {
            WorkoutSession::factory()->create(['user_id' => $user->id, 'started_at' => $at, 'ended_at' => $at]);
        }
        $service = new WorkoutService;

        $this->assertSame(3, $service->currentStreak($user->id, Carbon::parse('2026-03-10')));
        $this->assertSame(3, $service->currentStreak($user->id, Carbon::parse('2026-03-09')));
        $this->assertSame(0, $service->currentStreak($user->id, Carbon::parse('2026-03-11')));
    }
}
