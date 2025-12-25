<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Currency extends Model
{

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'code',
        'name',
        'color',
        'icon',
        'is_active',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    /**
     * Get the user that owns this currency (null for system currencies).
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Check if this is a system currency (not user-owned).
     */
    public function isSystem(): bool
    {
        return $this->user_id === null;
    }

    /**
     * Scope a query to only include system currencies.
     */
    public function scopeSystem($query)
    {
        return $query->whereNull('user_id');
    }

    /**
     * Scope a query to only include user-owned currencies.
     */
    public function scopeUserOwned($query, ?int $userId = null)
    {
        $query = $query->whereNotNull('user_id');

        if ($userId !== null) {
            $query->where('user_id', $userId);
        }

        return $query;
    }

    /**
     * Get the wallets that use this currency.
     */
    public function wallets(): HasMany
    {
        return $this->hasMany(Wallet::class);
    }

    /**
     * Get the transaction entries that use this currency.
     */
    public function transactionEntries(): HasMany
    {
        return $this->hasMany(TransactionEntry::class);
    }
}
