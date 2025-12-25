<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateFinanceSettingsRequest;
use App\Http\Resources\UserFinanceSettingsResource;

class UserFinanceSettingsController extends Controller
{
    /**
     * Display the authenticated user's finance settings.
     *
     * @return UserFinanceSettingsResource
     */
    public function show()
    {
        $settings = auth()->user()->financeSettings()->with('baseCurrency')->firstOrFail();

        return new UserFinanceSettingsResource($settings);
    }

    /**
     * Update the authenticated user's finance settings.
     *
     * @param UpdateFinanceSettingsRequest $request
     * @return UserFinanceSettingsResource
     */
    public function update(UpdateFinanceSettingsRequest $request)
    {
        $settings = auth()->user()->financeSettings;

        $settings->update([
            'base_currency_id' => $request->validated('base_currency_id'),
        ]);

        $settings->load('baseCurrency');

        return new UserFinanceSettingsResource($settings);
    }
}

