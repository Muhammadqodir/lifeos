<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TodoResource extends JsonResource
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
            'project_id' => $this->project_id,
            'project' => new ProjectResource($this->whenLoaded('project')),
            'title' => $this->title,
            'comment' => $this->comment,
            'status' => $this->status,
            'priority' => $this->priority,
            'urgency' => $this->urgency,
            'energy' => $this->energy,
            'time_spent_minutes' => $this->time_spent_minutes,
            'planned_date' => $this->planned_date,
            'planned_time' => $this->planned_time,
            'completed_at' => $this->completed_at?->toISOString(),
            'tags' => $this->tags ?? [],
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
