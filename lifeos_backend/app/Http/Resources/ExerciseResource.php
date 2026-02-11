<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ExerciseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => (int) $this->id,
            'name' => $this->name,
            'type' => $this->type,
            'image' => $this->image,
            'muscle_group' => $this->muscle_group,
            'is_system' => (bool) $this->isSystem(),
            'last_session_sets' => $this->when(
                $request->has('include_last_session') && auth()->check(),
                function () {
                    $lastSets = $this->getLastSessionSets(auth()->id());
                    return $lastSets && $lastSets->isNotEmpty()
                        ? WorkoutSetResource::collection($lastSets)
                        : [];
                }
            ),
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
