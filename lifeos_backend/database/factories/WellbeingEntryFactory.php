<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class WellbeingEntryFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'date' => fake()->date(),
            'energy' => fake()->numberBetween(1, 5),
            'stress' => fake()->numberBetween(1, 5),
            'note' => fake()->optional()->sentence(),
        ];
    }
}
