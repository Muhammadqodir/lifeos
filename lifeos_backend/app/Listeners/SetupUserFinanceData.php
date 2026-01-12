<?php

namespace App\Listeners;

use App\Models\Currency;
use App\Models\UserFinanceSettings;
use Illuminate\Auth\Events\Registered;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SetupUserFinanceData
{
    /**
     * Create the event listener.
     */
    public function __construct()
    {
        //
    }

    /**
     * Handle the event.
     *
     * Creates finance settings for the new user with USD as default base currency.
     */
    public function handle(Registered $event): void
    {
        $user = $event->user;

        // Check if user already has finance settings (idempotent)
        if ($user->financeSettings()->exists()) {
            Log::info("User {$user->id} already has finance settings. Skipping setup.");
            return;
        }

        DB::transaction(function () use ($user) {
            // Get USD as default base currency
            $usdCurrency = Currency::where('code', 'USD')->first();

            if ($usdCurrency) {
                UserFinanceSettings::create([
                    'user_id' => $user->id,
                    'base_currency_id' => $usdCurrency->id,
                ]);

                Log::info("Finance setup completed for user {$user->id} with USD as base currency.");
            } else {
                Log::warning("USD currency not found. Cannot create finance settings for user {$user->id}.");
            }
        });
    }
}
