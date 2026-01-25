<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkoutSetResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (int) $this->id,
            'workout_exercise_id' => (int) $this->workout_exercise_id,
            'set_index' => (int) $this->set_index,
            'weight_kg' => $this->weight_kg ? (float) $this->weight_kg : null,
            'reps' => $this->reps ? (int) $this->reps : null,
            'duration_seconds' => $this->duration_seconds ? (int) $this->duration_seconds : null,
            'distance_meters' => $this->distance_meters ? (float) $this->distance_meters : null,
            'rpe' => $this->rpe ? (int) $this->rpe : null,
            'is_done' => (bool) $this->is_done,
            'estimated_1rm' => $this->getEstimated1RM(),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
