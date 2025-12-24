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
            'wallet' => new WalletResource($this->whenLoaded('wallet')),
            'amount' => $this->amount,
            'currency_id' => $this->currency_id,
            'currency' => new CurrencyResource($this->whenLoaded('currency')),
            'rate' => $this->rate,
            'note' => $this->note,
            'created_at' => $this->created_at?->toISOString(),
        ];
    }
}
