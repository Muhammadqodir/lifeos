<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkoutSetResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'workout_exercise_id' => $this->workout_exercise_id,
            'set_index' => $this->set_index,
            'weight_kg' => $this->weight_kg ? (float) $this->weight_kg : null,
            'reps' => $this->reps,
            'duration_seconds' => $this->duration_seconds,
            'distance_meters' => $this->distance_meters ? (float) $this->distance_meters : null,
            'rpe' => $this->rpe,
            'is_done' => $this->is_done,
            'estimated_1rm' => $this->getEstimated1RM(),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
