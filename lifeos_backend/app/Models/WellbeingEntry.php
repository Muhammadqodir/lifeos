<?php

namespace App\Models;

use App\Models\Concerns\Syncable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WellbeingEntry extends Model
{
    use HasFactory, Syncable;
    protected $fillable = [
        'user_id',
        'date',
        'energy',
        'stress',
        'note',
    ];

    protected $casts = [
        'date' => 'date',
        'energy' => 'integer',
        'stress' => 'integer',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
