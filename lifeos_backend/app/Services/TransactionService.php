<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\TransactionEntry;
use Illuminate\Support\Facades\DB;

class TransactionService
{
    /**
     * Create a new transaction with entries.
     * Implements idempotent create using client_id.
     *
     * @param string $userId
     * @param array $data
     * @return Transaction
     * @throws \Exception
     */
    public function createTransaction(string $userId, array $data): Transaction
    {
        return DB::transaction(function () use ($userId, $data) {
            // Check for existing transaction with this client_id (idempotency)
            if (isset($data['client_id'])) {
                $existing = Transaction::where('user_id', $userId)
                    ->where('client_id', $data['client_id'])
                    ->with(['entries.wallet', 'entries.currency', 'category'])
                    ->first();

                if ($existing) {
                    // Return existing transaction - idempotent behavior
                    return $existing;
                }
            }

            // Validate wallet ownership for all entries
            if (isset($data['entries'])) {
                $walletIds = collect($data['entries'])->pluck('wallet_id')->unique()->toArray();
                $validWallets = \App\Models\Wallet::whereIn('id', $walletIds)
                    ->where('user_id', $userId)
                    ->count();

                if ($validWallets !== count($walletIds)) {
                    throw new \Exception('One or more wallets do not belong to the authenticated user.');
                }
            }

            // Validate category ownership if category_id is provided
            if (isset($data['category_id']) && $data['category_id'] !== null) {
                $category = \App\Models\TransactionCategory::find($data['category_id']);

                if (!$category) {
                    throw new \Exception('Category not found.');
                }

                // Category must belong to user OR be a system category (user_id = null)
                if ($category->user_id !== null && $category->user_id !== (int)$userId) {
                    throw new \Exception('Category does not belong to the authenticated user.');
                }
            }

            // Create the transaction
            $transaction = Transaction::create([
                'user_id' => $userId,
                'client_id' => $data['client_id'] ?? null,
                'type' => $data['type'],
                'category_id' => $data['category_id'] ?? null,
                'description' => $data['description'] ?? null,
                'occurred_at' => $data['occurred_at'],
            ]);

            // Create entries
            foreach ($data['entries'] as $entryData) {
                TransactionEntry::create([
                    'transaction_id' => $transaction->id,
                    'wallet_id' => $entryData['wallet_id'],
                    'amount' => $entryData['amount'],
                    'currency_id' => $entryData['currency_id'],
                    'rate' => $entryData['rate'] ?? null,
                    'note' => $entryData['note'] ?? null,
                ]);
            }

            // Load relationships
            $transaction->load(['entries.wallet', 'entries.currency', 'category']);

            return $transaction;
        });
    }

    /**
     * Update an existing transaction.
     *
     * @param Transaction $transaction
     * @param array $data
     * @return Transaction
     * @throws \Exception
     */
    public function updateTransaction(Transaction $transaction, array $data): Transaction
    {
        return DB::transaction(function () use ($transaction, $data) {
            // Validate wallet ownership for new entries if provided
            if (isset($data['entries'])) {
                $walletIds = collect($data['entries'])->pluck('wallet_id')->unique()->toArray();
                $validWallets = \App\Models\Wallet::whereIn('id', $walletIds)
                    ->where('user_id', $transaction->user_id)
                    ->count();

                if ($validWallets !== count($walletIds)) {
                    throw new \Exception('One or more wallets do not belong to the transaction owner.');
                }
            }

            // Validate category ownership if being updated
            if (isset($data['category_id']) && $data['category_id'] !== null) {
                $category = \App\Models\TransactionCategory::find($data['category_id']);

                if (!$category) {
                    throw new \Exception('Category not found.');
                }

                // Category must belong to user OR be a system category (user_id = null)
                if ($category->user_id !== null && $category->user_id !== $transaction->user_id) {
                    throw new \Exception('Category does not belong to the transaction owner.');
                }
            }

            // Update transaction fields
            $updateData = [];

            if (isset($data['client_id'])) {
                $updateData['client_id'] = $data['client_id'];
            }

            if (isset($data['type'])) {
                $updateData['type'] = $data['type'];
            }

            if (array_key_exists('category_id', $data)) {
                $updateData['category_id'] = $data['category_id'];
            }

            if (array_key_exists('description', $data)) {
                $updateData['description'] = $data['description'];
            }

            if (isset($data['occurred_at'])) {
                $updateData['occurred_at'] = $data['occurred_at'];
            }

            if (!empty($updateData)) {
                $transaction->update($updateData);
            }

            // If entries are provided, recreate them
            if (isset($data['entries'])) {
                // Delete existing entries
                $transaction->entries()->delete();

                // Create new entries
                foreach ($data['entries'] as $entryData) {
                    TransactionEntry::create([
                        'transaction_id' => $transaction->id,
                        'wallet_id' => $entryData['wallet_id'],
                        'amount' => $entryData['amount'],
                        'currency_id' => $entryData['currency_id'],
                        'rate' => $entryData['rate'] ?? null,
                        'note' => $entryData['note'] ?? null,
                    ]);
                }
            }

            // Refresh and load relationships
            $transaction->refresh();
            $transaction->load(['entries.wallet', 'entries.currency', 'category']);

            return $transaction;
        });
    }
}
