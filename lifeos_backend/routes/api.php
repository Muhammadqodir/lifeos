<?php

use App\Http\Controllers\Api\V1\AnalyticsController;
use App\Http\Controllers\Api\V1\CurrencyController;
use App\Http\Controllers\Api\V1\ExerciseController;
use App\Http\Controllers\Api\V1\ExerciseProgressController;
use App\Http\Controllers\Api\V1\FxRatesController;
use App\Http\Controllers\Api\V1\SleepEntryController;
use App\Http\Controllers\Api\V1\TransactionCategoryController;
use App\Http\Controllers\Api\V1\TransactionController;
use App\Http\Controllers\Api\V1\UserCurrencyController;
use App\Http\Controllers\Api\V1\UserFinanceSettingsController;
use App\Http\Controllers\Api\V1\WalletController;
use App\Http\Controllers\Api\V1\WellbeingEntryController;
use App\Http\Controllers\Api\V1\WorkoutExerciseController;
use App\Http\Controllers\Api\V1\WorkoutSessionController;
use App\Http\Controllers\Api\V1\WorkoutSetController;
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

    // FX Rates (public)
    Route::get('fx/rates', [FxRatesController::class, 'index']);

    // Finance routes (protected)
    Route::middleware('auth:sanctum')->group(function () {
        // User-specific routes
        Route::prefix('user')->group(function () {
            Route::get('currencies', [UserCurrencyController::class, 'index']);
            Route::post('currencies', [UserCurrencyController::class, 'store']);
            Route::delete('currencies/{currency}', [UserCurrencyController::class, 'destroy']);
            Route::get('finance-settings', [UserFinanceSettingsController::class, 'show']);
            Route::patch('finance-settings', [UserFinanceSettingsController::class, 'update']);
        });

        // Currencies (read-only)
        Route::get('currencies', [CurrencyController::class, 'index']);
        Route::get('currencies/{currency}', [CurrencyController::class, 'show']);

        // Wallets
        Route::get('wallets-with-balances', [WalletController::class, 'indexWithBalances']);
        Route::apiResource('wallets', WalletController::class);
        Route::get('wallets/{wallet}/balance', [WalletController::class, 'balance']);

        // Transaction Categories
        Route::apiResource('transaction-categories', TransactionCategoryController::class)->except(['show']);

        // Transactions
        Route::apiResource('transactions', TransactionController::class);

        // Analytics
        Route::get('analytics', [AnalyticsController::class, 'index']);

        // Health routes
        Route::prefix('health')->group(function () {
            // Sleep tracking
            Route::get('sleep', [SleepEntryController::class, 'index']);
            Route::post('sleep', [SleepEntryController::class, 'store']);
            Route::put('sleep/{sleepEntry}', [SleepEntryController::class, 'update']);
            Route::delete('sleep/{sleepEntry}', [SleepEntryController::class, 'destroy']);
            Route::get('sleep/summary', [SleepEntryController::class, 'summary']);

            // Wellbeing tracking
            Route::get('wellbeing', [WellbeingEntryController::class, 'index']);
            Route::post('wellbeing', [WellbeingEntryController::class, 'store']);
            Route::put('wellbeing/{wellbeingEntry}', [WellbeingEntryController::class, 'update']);
            Route::delete('wellbeing/{wellbeingEntry}', [WellbeingEntryController::class, 'destroy']);
            Route::get('wellbeing/summary', [WellbeingEntryController::class, 'summary']);

            // Workout tracking
            Route::get('workout/summary', [WorkoutSessionController::class, 'summary']);
        });

        // Gym routes
        Route::prefix('gym')->group(function () {
            // Workout sessions
            Route::get('workouts', [WorkoutSessionController::class, 'index']);
            Route::post('workouts', [WorkoutSessionController::class, 'store']);
            Route::post('workouts/complete', [WorkoutSessionController::class, 'storeComplete']);
            Route::get('workouts/{workout}', [WorkoutSessionController::class, 'show']);
            Route::put('workouts/{workout}', [WorkoutSessionController::class, 'update']);
            Route::delete('workouts/{workout}', [WorkoutSessionController::class, 'destroy']);

            // Exercises
            Route::get('exercises', [ExerciseController::class, 'index']);
            Route::post('exercises', [ExerciseController::class, 'store']);
            Route::delete('exercises/{exercise}', [ExerciseController::class, 'destroy']);
            Route::get('exercises/{exercise}/progress', [ExerciseProgressController::class, 'show']);

            // Workout exercises
            Route::post('workouts/{workout}/exercises', [WorkoutExerciseController::class, 'store']);
            Route::delete('workout-exercises/{workoutExercise}', [WorkoutExerciseController::class, 'destroy']);

            // Sets
            Route::post('workout-exercises/{workoutExercise}/sets', [WorkoutSetController::class, 'store']);
            Route::put('sets/{set}', [WorkoutSetController::class, 'update']);
            Route::delete('sets/{set}', [WorkoutSetController::class, 'destroy']);
        });
    });
});
