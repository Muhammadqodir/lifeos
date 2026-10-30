<?php

namespace App\Models\Concerns;

use App\Models\SyncTombstone;
use Illuminate\Support\Str;

/**
 * A model the sync API serves (see App\Sync).
 *
 * Gives every row a `uuid` (clients usually choose it) and keeps
 * `sync_tombstones` in step, whichever endpoint creates or deletes the row.
 */
trait Syncable
{
    public static function bootSyncable(): void
    {
        static::creating(function ($model) {
            $model->uuid ??= (string) Str::uuid();
        });

        static::created(fn ($model) => SyncTombstone::forget($model));
        static::deleted(fn ($model) => SyncTombstone::record($model));

        if (method_exists(static::class, 'restored')) {
            static::restored(fn ($model) => SyncTombstone::forget($model));
        }
    }
}
