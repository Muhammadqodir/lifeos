<?php

namespace Database\Factories;

use App\Models\Project;
use App\Models\Todo;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Todo>
 */
class TodoFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var class-string<\Illuminate\Database\Eloquent\Model>
     */
    protected $model = Todo::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $status = fake()->randomElement(Todo::getAllowedStatuses());

        return [
            'user_id' => User::factory(),
            'project_id' => Project::factory(),
            'title' => fake()->sentence(4),
            'comment' => fake()->optional()->paragraph(),
            'status' => $status,
            'priority' => fake()->randomElement(Todo::getAllowedPriorities()),
            'urgency' => fake()->randomElement(Todo::getAllowedUrgencies()),
            'energy' => fake()->randomElement(Todo::getAllowedEnergies()),
            'time_spent_minutes' => fake()->optional()->numberBetween(5, 300),
            'planned_date_time' => fake()->optional()->dateTimeBetween('now', '+30 days'),
            'completed_at' => $status === Todo::STATUS_DONE ? now() : null,
            'tags' => fake()->optional()->randomElements(['work', 'personal', 'urgent', 'health', 'finance'], 2),
        ];
    }

    /**
     * Indicate that the todo is planned.
     */
    public function planned(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Todo::STATUS_PLANNED,
            'completed_at' => null,
        ]);
    }

    /**
     * Indicate that the todo is in progress.
     */
    public function inProgress(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Todo::STATUS_IN_PROGRESS,
            'completed_at' => null,
        ]);
    }

    /**
     * Indicate that the todo is blocked.
     */
    public function blocked(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Todo::STATUS_BLOCKED,
            'completed_at' => null,
        ]);
    }

    /**
     * Indicate that the todo is done.
     */
    public function done(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => Todo::STATUS_DONE,
            'completed_at' => now(),
        ]);
    }
}
