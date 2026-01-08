<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\AddUserCurrencyRequest;
use App\Http\Resources\CurrencyResource;
use App\Models\Currency;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserCurrencyController extends Controller
{
    /**
     * Display a listing of the authenticated user's owned currencies.
     *
     * @return \Illuminate\Http\Resources\Json\AnonymousResourceCollection
     */
    public function index()
    {
        $currencies = auth()->user()->currencies()
            ->orderBy('code')
            ->get();

        return CurrencyResource::collection($currencies);
    }

    /**
     * Add a currency to the authenticated user's currency list.
     *
     * @param AddUserCurrencyRequest $request
     * @return CurrencyResource
     */
    public function store(AddUserCurrencyRequest $request): CurrencyResource
    {
        $currency = Currency::findOrFail($request->validated('currency_id'));

        auth()->user()->currencies()->attach($currency->id);

        return new CurrencyResource($currency);
    }

    /**
     * Remove a currency from the authenticated user's currency list.
     *
     * @param Currency $currency
     * @return JsonResponse
     */
    public function destroy(Request $request, Currency $currency): JsonResponse
    {
        $user = $request->user();

        // Prevent removing base currency
        $settings = $user->financeSettings;
        if ($settings && $settings->base_currency_id === $currency->id) {
            return response()->json([
                'message' => 'Cannot remove your base currency. Please set a different base currency first.',
            ], 422);
        }

        // Find and delete the user's currency record
        $userCurrency = $user->currencies()->where('id', $currency->id)->first();

        if ($userCurrency) {
            $userCurrency->delete();
        }

        return response()->json(null, 204);
    }
}

