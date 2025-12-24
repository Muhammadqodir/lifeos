<?php

use App\Http\Controllers\Api\V1\CurrencyController;
use App\Http\Controllers\Api\V1\TransactionCategoryController;
use App\Http\Controllers\Api\V1\TransactionController;
use App\Http\Controllers\Api\V1\WalletController;
use App\Http\Controllers\Auth\AuthController;
use Illuminate\Support\Facades\Route;

// API v1
Route::prefix('v1')->group(function () {
    // Auth routes
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);

        Route::middleware('auth:sanctum')->group(function () {
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::get('/me', [AuthController::class, 'me']);
        });
    });

    // Finance routes (protected)
    Route::middleware('auth:sanctum')->group(function () {
        // Currencies (read-only)
        Route::get('currencies', [CurrencyController::class, 'index']);
        Route::get('currencies/{currency}', [CurrencyController::class, 'show']);

        // Wallets
        Route::apiResource('wallets', WalletController::class);
        Route::get('wallets/{wallet}/balance', [WalletController::class, 'balance']);

        // Transaction Categories
        Route::apiResource('transaction-categories', TransactionCategoryController::class)->except(['show']);

        // Transactions
        Route::apiResource('transactions', TransactionController::class);
    });
});
