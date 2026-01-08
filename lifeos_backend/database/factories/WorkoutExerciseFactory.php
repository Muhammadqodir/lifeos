<?php

namespace Database\Factories;

use App\Models\Exercise;
use App\Models\WorkoutSession;
use Illuminate\Database\Eloquent\Factories\Factory;

class WorkoutExerciseFactory extends Factory
{
    public function definition(): array
    {
        return [
            'session_id' => WorkoutSession::factory(),
            'exercise_id' => Exercise::factory(),
            'sort_order' => fake()->numberBetween(0, 10),
        ];
    }
}
