<?php

namespace App\Sync\Entities;

use App\Models\Transaction;
use App\Models\TransactionCategory;
use App\Models\Wallet;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Validation\Rule;

/**
 * A transaction and its entries, synced as one record. Entries are
 * replaced as a whole when an update carries them.
 */
class TransactionSync extends SyncEntity
{
    public function name(): string
    {
        return 'transactions';
    }

    public function model(): string
    {
        return Transaction::class;
    }

    public function with(): array
    {
        return [
            'category:id,uuid',
            'entries.wallet:id,uuid',
        ];
    }

    public function serialize(Model $record): array
    {
        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'type' => $record->type,
            'category_id' => $record->category?->uuid,
            'description' => $record->description,
            'occurred_at' => self::iso($record->occurred_at),
            'entries' => $record->entries->map(fn ($entry) => [
                'wallet_id' => $entry->wallet?->uuid,
                'amount' => (float) $entry->amount,
                'currency_id' => (int) $entry->currency_id,
                'rate' => $entry->rate === null ? null : (float) $entry->rate,
                'note' => $entry->note,
            ])->values()->all(),
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'type' => [$required, 'in:income,expense,transfer,exchange'],
            'category_id' => [
                'nullable', 'uuid',
                Rule::exists('transaction_categories', 'uuid')
                    ->where(fn ($q) => $q->where('user_id', $userId)->orWhereNull('user_id')),
            ],
            'description' => 'nullable|string|max:255',
            'occurred_at' => [$required, 'date'],
            'entries' => [$required, 'array', 'min:1'],
            'entries.*.wallet_id' => [
                'required', 'uuid',
                Rule::exists('wallets', 'uuid')->where('user_id', $userId),
            ],
            'entries.*.amount' => 'required|numeric',
            'entries.*.currency_id' => 'required|integer|exists:currencies,id',
            'entries.*.rate' => 'nullable|numeric',
            'entries.*.note' => 'nullable|string|max:255',
        ];
    }

    public function attributes(array $data, int $userId, ?Model $record): array
    {
        if (array_key_exists('category_id', $data)) {
            $data['category_id'] = $data['category_id'] === null
                ? null
                : TransactionCategory::where('uuid', $data['category_id'])->value('id');
        }
        unset($data['entries']);

        return $data;
    }

    public function persist(Model $record, array $attributes, array $validated, bool $creating): void
    {
        if ($creating) {
            // Keeps the REST API's idempotency key in step.
            $record->client_id = $record->uuid;
        }
        $record->fill($attributes)->save();

        if (array_key_exists('entries', $validated)) {
            $wallets = Wallet::whereIn('uuid', collect($validated['entries'])->pluck('wallet_id'))
                ->pluck('id', 'uuid');
            $record->entries()->delete();
            foreach ($validated['entries'] as $entry) {
                $record->entries()->create([
                    'wallet_id' => $wallets[$entry['wallet_id']],
                    'amount' => $entry['amount'],
                    'currency_id' => $entry['currency_id'],
                    'rate' => $entry['rate'] ?? null,
                    'note' => $entry['note'] ?? null,
                ]);
            }
            // Other devices see the new entries on their next pull.
            $record->touch();
        }
    }
}
