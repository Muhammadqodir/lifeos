<?php

namespace App\Services\FxRates;

interface FxRateProviderInterface
{
    /**
     * Fetch exchange rates for the given origin currency.
     *
     * @param string $originCode Currency code (e.g., 'USD')
     * @return FxRatesDto
     * @throws \Exception
     */
    public function fetch(string $originCode): FxRatesDto;
}
