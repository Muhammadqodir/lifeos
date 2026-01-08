<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ExerciseFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => null, // System exercise by default
            'name' => fake()->words(2, true),
            'muscle_group' => fake()->randomElement(['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core']),
            'image' => null,
        ];
    }

    public function custom(): static
    {
        return $this->state(fn (array $attributes) => [
            'user_id' => User::factory(),
        ]);
    }
}
