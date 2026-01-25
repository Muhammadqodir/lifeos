<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkoutCompletionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (int) $this->id,
            'workout_session_id' => (int) $this->workout_session_id,
            'photo_path' => $this->photo_path,
            'body_weight_kg' => $this->body_weight_kg ? (float) $this->body_weight_kg : null,
            'height_cm' => $this->height_cm ? (float) $this->height_cm : null,
            'biceps_cm' => $this->biceps_cm ? (float) $this->biceps_cm : null,
            'chest_cm' => $this->chest_cm ? (float) $this->chest_cm : null,
            'waist_cm' => $this->waist_cm ? (float) $this->waist_cm : null,
            'thighs_cm' => $this->thighs_cm ? (float) $this->thighs_cm : null,
            'calfs_cm' => $this->calfs_cm ? (float) $this->calfs_cm : null,
            'notes' => $this->notes,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
