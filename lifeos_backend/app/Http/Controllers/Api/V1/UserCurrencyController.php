<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\CurrencyResource;
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
}

