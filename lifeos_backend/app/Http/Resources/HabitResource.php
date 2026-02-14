<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HabitResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'color' => $this->color,
            'icon' => $this->icon,
            'status' => $this->status,
            'frequency' => $this->frequency,
            'frequency_days' => $this->frequency_days ?? [],
            'reminder_time' => $this->reminder_time ? substr($this->reminder_time, 0, 5) : null,
            'goal_duration' => $this->goal_duration,
            'tags' => $this->tags ?? [],
            'current_streak' => $this->when($request->input('with_stats'), fn() => $this->getCurrentStreak()),
            'longest_streak' => $this->when($request->input('with_stats'), fn() => $this->getLongestStreak()),
            'completion_rate' => $this->when($request->input('with_stats'), fn() => $this->getCompletionRate()),
            'is_completed_today' => $this->when($request->input('with_today'), fn() => $this->isCompletedToday()),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
