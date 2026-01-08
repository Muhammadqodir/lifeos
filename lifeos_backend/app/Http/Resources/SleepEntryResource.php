<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SleepEntryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'date' => $this->date->format('Y-m-d'),
            'sleep_start' => $this->sleep_start?->toISOString(),
            'sleep_end' => $this->sleep_end?->toISOString(),
            'duration_hours' => $this->getDurationHours(),
            'quality' => $this->quality,
            'note' => $this->note,
            'created_at' => $this->created_at->toISOString(),
            'updated_at' => $this->updated_at->toISOString(),
        ];
    }
}
