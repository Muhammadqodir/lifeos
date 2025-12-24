<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionResource extends JsonResource
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
            'user_id' => $this->user_id,
            'client_id' => $this->client_id,
            'type' => $this->type,
            'category_id' => $this->category_id,
            'category' => new TransactionCategoryResource($this->whenLoaded('category')),
            'description' => $this->description,
            'occurred_at' => $this->occurred_at?->toISOString(),
            'entries' => TransactionEntryResource::collection($this->whenLoaded('entries')),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
