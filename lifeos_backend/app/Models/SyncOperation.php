<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Result of a pushed operation, kept so a retry gets the same answer instead
 * of applying the change again. Pruned after 30 days (routes/console.php).
 */
class SyncOperation extends Model
{
    public const UPDATED_AT = null;

    protected $fillable = ['user_id', 'op_id', 'result'];

    protected $casts = ['result' => 'array'];
}
