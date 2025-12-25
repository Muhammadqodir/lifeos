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
     * Clones system currencies for the new user and creates finance settings.
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
            // Step 1: Clone all system currencies for this user
            $systemCurrencies = Currency::system()->get();

            $userCurrencies = [];
            foreach ($systemCurrencies as $systemCurrency) {
                $userCurrencies[] = Currency::create([
                    'user_id' => $user->id,
                    'code' => $systemCurrency->code,
                    'name' => $systemCurrency->name,
                    'color' => $systemCurrency->color,
                    'icon' => $systemCurrency->icon,
                    'is_active' => true,
                ]);
            }

            // Step 2: Create user finance settings with first currency as base
            if (count($userCurrencies) > 0) {
                UserFinanceSettings::create([
                    'user_id' => $user->id,
                    'base_currency_id' => $userCurrencies[0]->id,
                ]);

                Log::info("Finance setup completed for user {$user->id}: cloned " . count($userCurrencies) . " currencies.");
            } else {
                Log::warning("No system currencies found to clone for user {$user->id}.");
            }
        });
    }
}
