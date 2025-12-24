<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\CurrencyResource;
use App\Models\Currency;

class CurrencyController extends Controller
{
    /**
     * Display a listing of currencies.
     */
    public function index()
    {
        $currencies = Currency::all();

        return CurrencyResource::collection($currencies);
    }

    /**
     * Display the specified currency.
     */
    public function show(Currency $currency)
    {
        return new CurrencyResource($currency);
    }
}
