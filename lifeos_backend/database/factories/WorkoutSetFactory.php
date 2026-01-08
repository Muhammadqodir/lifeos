<?php

namespace Database\Factories;

use App\Models\WorkoutExercise;
use Illuminate\Database\Eloquent\Factories\Factory;

class WorkoutSetFactory extends Factory
{
    public function definition(): array
    {
        return [
            'workout_exercise_id' => WorkoutExercise::factory(),
            'set_index' => fake()->numberBetween(1, 5),
            'weight_kg' => fake()->randomFloat(2, 20, 200),
            'reps' => fake()->numberBetween(1, 15),
            'rpe' => fake()->optional()->numberBetween(1, 10),
            'is_done' => true,
        ];
    }
}
