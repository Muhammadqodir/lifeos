<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkoutSessionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'started_at' => $this->started_at->toISOString(),
            'ended_at' => $this->ended_at->toISOString(),
            'note' => $this->note,
            'exercises' => WorkoutExerciseResource::collection($this->whenLoaded('workoutExercises')),
            'completion' => new WorkoutCompletionResource($this->whenLoaded('completion')),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
