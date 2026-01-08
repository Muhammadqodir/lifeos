<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class WorkoutSessionFactory extends Factory
{
    public function definition(): array
    {
        $startedAt = fake()->dateTimeBetween('-1 week', 'now');
        $endedAt = (clone $startedAt)->modify('+' . fake()->numberBetween(30, 120) . ' minutes');

        return [
            'user_id' => User::factory(),
            'started_at' => $startedAt,
            'ended_at' => $endedAt,
            'note' => fake()->optional()->sentence(),
        ];
    }
}
