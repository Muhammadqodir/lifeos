<?php

namespace App\Services\FxRates;

class FxRatesDto
{
    /**
     * @param string $origin Currency code (uppercase, e.g., 'USD')
     * @param string $date Date in YYYY-MM-DD format
     * @param array<string, float> $rates Rates map with uppercase currency codes as keys
     * @param string $source Provider source name
     */
    public function __construct(
        public readonly string $origin,
        public readonly string $date,
        public readonly array $rates,
        public readonly string $source,
    ) {
    }

    /**
     * Convert to array for JSON response.
     *
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'origin' => $this->origin,
            'date' => $this->date,
            'rates' => $this->rates,
        ];
    }
}
