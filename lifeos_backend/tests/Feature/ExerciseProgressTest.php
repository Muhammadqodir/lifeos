<?php

namespace Tests\Feature;

use App\Models\Exercise;
use App\Models\User;
use App\Models\WorkoutExercise;
use App\Models\WorkoutSession;
use App\Models\WorkoutSet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ExerciseProgressTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_get_exercise_progress(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        // Create exercise
        $exercise = Exercise::factory()->create(['user_id' => null]);

        // Create workout session
        $session = WorkoutSession::factory()->create([
            'user_id' => $user->id,
            'started_at' => '2026-01-04 10:00:00',
            'ended_at' => '2026-01-04 11:00:00',
        ]);

        // Create workout exercise
        $workoutExercise = WorkoutExercise::factory()->create([
            'session_id' => $session->id,
            'exercise_id' => $exercise->id,
        ]);

        // Create sets
        WorkoutSet::factory()->create([
            'workout_exercise_id' => $workoutExercise->id,
            'set_index' => 1,
            'weight_kg' => 80,
            'reps' => 8,
            'is_done' => true,
        ]);

        WorkoutSet::factory()->create([
            'workout_exercise_id' => $workoutExercise->id,
            'set_index' => 2,
            'weight_kg' => 80,
            'reps' => 8,
            'is_done' => true,
        ]);

        $response = $this->getJson("/api/v1/gym/exercises/{$exercise->id}/progress");

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'exercise' => ['id', 'name'],
            'points' => [
                '*' => [
                    'date',
                    'volume',
                    'best_set_weight',
                    'best_e1rm',
                ],
            ],
        ]);

        // Check calculations
        $points = $response->json('points');
        $this->assertCount(1, $points);
        $this->assertEquals(1280, $points[0]['volume']); // 80 * 8 * 2 sets
        $this->assertEquals(80, $points[0]['best_set_weight']);
    }

    public function test_user_cannot_see_other_users_progress(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        Sanctum::actingAs($user);

        $exercise = Exercise::factory()->create(['user_id' => null]);

        // Create workout for other user
        $session = WorkoutSession::factory()->create([
            'user_id' => $otherUser->id,
            'started_at' => '2026-01-04 10:00:00',
            'ended_at' => '2026-01-04 11:00:00',
        ]);

        $workoutExercise = WorkoutExercise::factory()->create([
            'session_id' => $session->id,
            'exercise_id' => $exercise->id,
        ]);

        WorkoutSet::factory()->create([
            'workout_exercise_id' => $workoutExercise->id,
            'weight_kg' => 100,
            'reps' => 10,
            'is_done' => true,
        ]);

        $response = $this->getJson("/api/v1/gym/exercises/{$exercise->id}/progress");

        $response->assertStatus(200);
        $this->assertCount(0, $response->json('points'));
    }
}
