<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AnalyticsResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'total_income' => $this->resource['total_income'],
            'total_expense' => $this->resource['total_expense'],
            'net_amount' => $this->resource['net_amount'],
            'currency_icon' => $this->resource['currency_icon'],
            'date_from' => $this->resource['date_from'],
            'date_to' => $this->resource['date_to'],
            'income_by_category' => $this->resource['income_by_category'],
            'expense_by_category' => $this->resource['expense_by_category'],
        ];
    }
}
