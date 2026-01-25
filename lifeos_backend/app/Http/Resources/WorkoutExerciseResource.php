<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkoutExerciseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (int) $this->id,
            'exercise_id' => (int) $this->exercise_id,
            'exercise' => new ExerciseResource($this->whenLoaded('exercise')),
            'order_index' => (int) $this->sort_order,
            'sets' => WorkoutSetResource::collection($this->whenLoaded('sets')),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
