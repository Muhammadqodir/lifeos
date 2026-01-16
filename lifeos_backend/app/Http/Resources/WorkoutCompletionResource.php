<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkoutCompletionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'workout_session_id' => $this->workout_session_id,
            'photo_path' => $this->photo_path,
            'body_weight_kg' => $this->body_weight_kg,
            'height_cm' => $this->height_cm,
            'biceps_cm' => $this->biceps_cm,
            'chest_cm' => $this->chest_cm,
            'waist_cm' => $this->waist_cm,
            'thighs_cm' => $this->thighs_cm,
            'calfs_cm' => $this->calfs_cm,
            'notes' => $this->notes,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
