<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TransactionEntry extends Model
{

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'transaction_id',
        'wallet_id',
        'amount',
        'currency_id',
        'rate',
        'note',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'amount' => 'decimal:6',
            'rate' => 'decimal:8',
            'created_at' => 'datetime',
        ];
    }

    /**
     * Get the transaction that owns the entry.
     */
    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }

    /**
     * Get the wallet for this entry.
     */
    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class);
    }

    /**
     * Get the currency for this entry.
     */
    public function currency(): BelongsTo
    {
        return $this->belongsTo(Currency::class);
    }
}
