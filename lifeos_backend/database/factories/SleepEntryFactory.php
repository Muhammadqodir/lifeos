<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class SleepEntryFactory extends Factory
{
    public function definition(): array
    {
        $sleepStart = fake()->dateTimeBetween('-1 week', 'now');
        $sleepEnd = (clone $sleepStart)->modify('+' . fake()->numberBetween(6, 9) . ' hours');

        return [
            'user_id' => User::factory(),
            'date' => fake()->date(),
            'sleep_start' => $sleepStart,
            'sleep_end' => $sleepEnd,
            'quality' => fake()->numberBetween(1, 5),
            'note' => fake()->optional()->sentence(),
        ];
    }
}
