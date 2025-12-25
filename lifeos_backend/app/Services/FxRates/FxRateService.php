<?php

namespace App\Services\FxRates;

use Illuminate\Validation\ValidationException;

class FxRateService
{
    public function __construct(
        private readonly FxRateProviderInterface $provider
    ) {
    }

    /**
     * Get exchange rates for specific target currencies.
     *
     * @param string $origin Origin currency code
     * @param array<string> $targets Array of target currency codes
     * @return FxRatesDto
     * @throws ValidationException
     * @throws \Exception
     */
    public function getRates(string $origin, array $targets): FxRatesDto
    {
        // Normalize to uppercase
        $origin = strtoupper(trim($origin));
        $targets = array_map(fn($t) => strtoupper(trim($t)), $targets);

        // Validate currency code format
        $this->validateCurrencyCode($origin, 'origin');
        foreach ($targets as $target) {
            $this->validateCurrencyCode($target, 'target');
        }

        // Fetch full rates map from provider
        $fullRates = $this->provider->fetch($origin);

        // Filter only requested targets
        $filteredRates = [];
        $missingTargets = [];

        foreach ($targets as $target) {
            if (isset($fullRates->rates[$target])) {
                $filteredRates[$target] = $fullRates->rates[$target];
            } else {
                $missingTargets[] = $target;
            }
        }

        // If any requested target is missing, throw validation error
        if (!empty($missingTargets)) {
            throw ValidationException::withMessages([
                'target' => [
                    'The following target currencies are not available: ' . implode(', ', $missingTargets)
                ]
            ]);
        }

        return new FxRatesDto(
            origin: $fullRates->origin,
            date: $fullRates->date,
            rates: $filteredRates,
            source: $fullRates->source,
        );
    }

    /**
     * Validate currency code format.
     *
     * @param string $code
     * @param string $field
     * @throws ValidationException
     */
    private function validateCurrencyCode(string $code, string $field): void
    {
        if (!preg_match('/^[A-Z]{3}$/', $code)) {
            throw ValidationException::withMessages([
                $field => ["The {$field} must be a valid 3-letter currency code (e.g., USD, EUR)."]
            ]);
        }
    }
}
