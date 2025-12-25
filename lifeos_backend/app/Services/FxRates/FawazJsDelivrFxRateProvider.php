<?php

namespace App\Services\FxRates;

use Illuminate\Support\Facades\Http;

class FawazJsDelivrFxRateProvider implements FxRateProviderInterface
{
    private const BASE_URL = 'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies';
    private const TIMEOUT_SECONDS = 10;

    /**
     * Fetch exchange rates for the given origin currency.
     *
     * @param string $originCode Currency code (e.g., 'USD')
     * @return FxRatesDto
     * @throws \Exception
     */
    public function fetch(string $originCode): FxRatesDto
    {
        $originLower = strtolower($originCode);
        $url = self::BASE_URL . "/{$originLower}.json";

        try {
            $response = Http::timeout(self::TIMEOUT_SECONDS)
                ->get($url);

            if (!$response->successful()) {
                throw new \Exception(
                    "Failed to fetch exchange rates for {$originCode}. HTTP status: {$response->status()}"
                );
            }

            $data = $response->json();

            if (!isset($data['date']) || !isset($data[$originLower])) {
                throw new \Exception(
                    "Invalid response structure from FX provider for {$originCode}"
                );
            }

            // Normalize rates to uppercase keys
            $rates = [];
            foreach ($data[$originLower] as $currency => $rate) {
                $rates[strtoupper($currency)] = (float) $rate;
            }

            return new FxRatesDto(
                origin: strtoupper($originCode),
                date: $data['date'],
                rates: $rates,
                source: 'fawaz_jsdelivr',
            );
        } catch (\Illuminate\Http\Client\ConnectionException $e) {
            throw new \Exception(
                "Connection timeout or network error while fetching rates for {$originCode}: {$e->getMessage()}",
                0,
                $e
            );
        } catch (\Exception $e) {
            if (str_contains($e->getMessage(), 'Failed to fetch') || str_contains($e->getMessage(), 'Invalid response')) {
                throw $e;
            }

            throw new \Exception(
                "Unexpected error while fetching rates for {$originCode}: {$e->getMessage()}",
                0,
                $e
            );
        }
    }
}
