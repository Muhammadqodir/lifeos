<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Currency extends Model
{

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'code',
        'name',
        'color',
        'icon',
    ];

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
