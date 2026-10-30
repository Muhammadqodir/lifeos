<?php

namespace App\Sync\Entities;

use App\Models\Wallet;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Model;

class WalletSync extends SyncEntity
{
    public function name(): string
    {
        return 'wallets';
    }

    public function model(): string
    {
        return Wallet::class;
    }

    public function serialize(Model $record): array
    {
        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'name' => $record->name,
            'currency_id' => (int) $record->currency_id,
            'type' => $record->type,
            'is_active' => (bool) $record->is_active,
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'name' => [$required, 'string', 'max:255'],
            'currency_id' => [$required, 'integer', 'exists:currencies,id'],
            'type' => [$required, 'in:card,bank_account,cash,other'],
            'is_active' => ['sometimes', 'boolean'],
        ];
    }

    /** Wallets are archived, never deleted: their transactions stay. */
    public function remove(Model $record): void
    {
        $record->update(['is_active' => false]);
    }
}
