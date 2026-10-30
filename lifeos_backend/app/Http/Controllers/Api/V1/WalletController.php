<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreWalletRequest;
use App\Http\Requests\UpdateWalletRequest;
use App\Http\Resources\WalletResource;
use App\Models\Wallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WalletController extends Controller
{
    /**
     * Display a listing of wallets for the authenticated user.
     */
    public function index(): AnonymousResourceCollection
    {
        $query = Wallet::where('user_id', auth()->id())->where('is_active', true)
            ->with('currency');

        // Include balances if requested
        if (request()->has('with_balances') && request()->boolean('with_balances')) {
            $query->withSum('transactionEntries as balance', 'amount');
        }

        $wallets = $query->get();

        return WalletResource::collection($wallets);
    }

    /**
     * Display a listing of wallets with their balances.
     */
    public function indexWithBalances(): AnonymousResourceCollection
    {
        $wallets = Wallet::where('user_id', auth()->id())->where('is_active', true)
            ->with('currency')
            ->withSum('transactionEntries as balance', 'amount')
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
        $this->authorize('view', $wallet);

        $wallet->load('currency');

        return new WalletResource($wallet);
    }

    /**
     * Update the specified wallet.
     */
    public function update(UpdateWalletRequest $request, Wallet $wallet): WalletResource
    {
        $this->authorize('update', $wallet);

        $wallet->update($request->validated());
        $wallet->load('currency');

        return new WalletResource($wallet);
    }

    /**
     * Remove the specified wallet (set is_active to false).
     */
    public function destroy(Wallet $wallet): Response
    {
        $this->authorize('delete', $wallet);

        $wallet->update(['is_active' => false]);

        return $this->noContent();
    }

    /**
     * Get the balance of a wallet (sum of all transaction entries).
     */
    public function balance(Wallet $wallet): JsonResponse
    {
        $this->authorize('view', $wallet);

        $balance = $wallet->transactionEntries()->sum('amount');

        return $this->ok([
            'wallet_id' => $wallet->id,
            'balance' => (float) $balance,
            'currency_id' => $wallet->currency_id,
        ]);
    }
}
