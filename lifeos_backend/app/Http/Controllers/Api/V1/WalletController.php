<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreWalletRequest;
use App\Http\Requests\UpdateWalletRequest;
use App\Http\Resources\WalletResource;
use App\Models\Wallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WalletController extends Controller
{
    /**
     * Display a listing of wallets for the authenticated user.
     */
    public function index(): AnonymousResourceCollection
    {
        $wallets = Wallet::where('user_id', auth()->id())
            ->with('currency')
            ->get();

        return WalletResource::collection($wallets);
    }

    /**
     * Store a newly created wallet.
     */
    public function store(StoreWalletRequest $request): WalletResource
    {
        $wallet = Wallet::create([
            'user_id' => auth()->id(),
            ...$request->validated(),
        ]);

        $wallet->load('currency');

        return new WalletResource($wallet);
    }

    /**
     * Display the specified wallet.
     */
    public function show(Wallet $wallet): WalletResource
    {
        // Ensure user owns this wallet
        if ($wallet->user_id !== auth()->id()) {
            abort(404);
        }

        $wallet->load('currency');

        return new WalletResource($wallet);
    }

    /**
     * Update the specified wallet.
     */
    public function update(UpdateWalletRequest $request, Wallet $wallet): WalletResource
    {
        // Ensure user owns this wallet
        if ($wallet->user_id !== auth()->id()) {
            abort(404);
        }

        $wallet->update($request->validated());
        $wallet->load('currency');

        return new WalletResource($wallet);
    }

    /**
     * Remove the specified wallet (set is_active to false).
     */
    public function destroy(Wallet $wallet): JsonResponse
    {
        // Ensure user owns this wallet
        if ($wallet->user_id !== auth()->id()) {
            abort(404);
        }

        $wallet->update(['is_active' => false]);

        return response()->json(null, 204);
    }

    /**
     * Get the balance of a wallet (sum of all transaction entries).
     */
    public function balance(Wallet $wallet): JsonResponse
    {
        // Ensure user owns this wallet
        if ($wallet->user_id !== auth()->id()) {
            abort(404);
        }

        $balance = $wallet->transactionEntries()->sum('amount');

        return response()->json([
            'data' => [
                'wallet_id' => $wallet->id,
                'balance' => number_format($balance, 6, '.', ''),
                'currency_id' => $wallet->currency_id,
            ]
        ]);
    }
}
