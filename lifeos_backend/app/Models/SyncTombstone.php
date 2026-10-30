<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Marks a synced record as deleted so clients drop their local copy.
 * Written by {@see Concerns\Syncable}.
 */
class SyncTombstone extends Model
{
    public $timestamps = false;

    protected $fillable = ['user_id', 'entity', 'uuid', 'deleted_at'];

    protected $casts = ['deleted_at' => 'datetime'];

    public static function record(Model $model): void
    {
        // Shared rows (system categories and exercises) belong to no one.
        if ($model->user_id === null) {
            return;
        }

        static::updateOrCreate(
            ['entity' => $model->getTable(), 'uuid' => $model->uuid],
            ['user_id' => $model->user_id, 'deleted_at' => now()],
        );
    }

    public static function forget(Model $model): void
    {
        static::where('entity', $model->getTable())->where('uuid', $model->uuid)->delete();
    }
}
