<?php

namespace Tests\Feature;

use App\Models\SleepEntry;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SleepEntryTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_sleep_entry(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/health/sleep', [
            'date' => '2026-01-04',
            'sleep_start' => '2026-01-03 23:00:00',
            'sleep_end' => '2026-01-04 07:00:00',
            'quality' => 4,
            'note' => 'Good sleep',
        ]);

        $response->assertStatus(201);
        $response->assertJsonStructure([
            'data' => [
                'id',
                'date',
                'sleep_start',
                'sleep_end',
                'duration_hours',
                'quality',
                'note',
            ],
        ]);

        $this->assertDatabaseHas('sleep_entries', [
            'user_id' => $user->id,
            'date' => '2026-01-04',
            'quality' => 4,
        ]);
    }

    public function test_user_can_view_their_sleep_entries(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        SleepEntry::factory()->count(3)->create(['user_id' => $user->id]);

        $response = $this->getJson('/api/v1/health/sleep');

        $response->assertStatus(200);
        $response->assertJsonCount(3, 'data');
    }

    public function test_user_cannot_view_other_users_sleep_entries(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        Sanctum::actingAs($user);

        SleepEntry::factory()->create(['user_id' => $user->id]);
        SleepEntry::factory()->create(['user_id' => $otherUser->id]);

        $response = $this->getJson('/api/v1/health/sleep');

        $response->assertStatus(200);
        $response->assertJsonCount(1, 'data');
    }

    public function test_user_can_get_sleep_summary(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        SleepEntry::factory()->count(5)->create([
            'user_id' => $user->id,
            'quality' => 4,
        ]);

        $response = $this->getJson('/api/v1/health/sleep/summary');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'count',
            'avg_duration_hours',
            'avg_quality',
            'points',
        ]);
    }
}
