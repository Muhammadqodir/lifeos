<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TransactionEntryResource extends JsonResource
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
            'transaction_id' => $this->transaction_id,
            'wallet_id' => $this->wallet_id,
            'wallet' => $this->when($this->relationLoaded('wallet') && $this->wallet,
                new WalletResource($this->wallet)),
            'amount' => (float) $this->amount,
            'currency_id' => $this->currency_id,
            'currency' => $this->when($this->relationLoaded('currency') && $this->currency,
                new CurrencyResource($this->currency)),
            'rate' => $this->rate !== null ? (float) $this->rate : null,
            'note' => $this->note,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
