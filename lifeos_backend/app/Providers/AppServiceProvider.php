<?php

namespace App\Providers;

use App\Listeners\SetupUserFinanceData;
use App\Services\FxRates\FawazJsDelivrFxRateProvider;
use App\Services\FxRates\FxRateProviderInterface;
use Illuminate\Auth\Events\Registered;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Bind FX rate provider
        $this->app->singleton(FxRateProviderInterface::class, FawazJsDelivrFxRateProvider::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Register event listener for user registration
        Event::listen(
            Registered::class,
            SetupUserFinanceData::class,
        );
    }
}
