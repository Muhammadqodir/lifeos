<?php

use Illuminate\Foundation\Inspiring;
use App\Models\SyncOperation;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Push results only need to outlive client retries.
Schedule::call(fn () => SyncOperation::where('created_at', '<', now()->subDays(30))->delete())
    ->daily()
    ->name('prune-sync-operations');
