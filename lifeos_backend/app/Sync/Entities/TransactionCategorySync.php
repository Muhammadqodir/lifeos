<?php

namespace App\Sync\Entities;

use App\Models\TransactionCategory;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class TransactionCategorySync extends SyncEntity
{
    public function name(): string
    {
        return 'transaction_categories';
    }

    public function model(): string
    {
        return TransactionCategory::class;
    }

    /** The user's categories plus the shared defaults (user_id null). */
    public function query(int $userId): Builder
    {
        return TransactionCategory::query()
            ->where(fn ($q) => $q->where('user_id', $userId)->orWhereNull('user_id'));
    }

    public function serialize(Model $record): array
    {
        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'title' => $record->title,
            'icon' => $record->icon,
            'color' => $record->color,
            'type' => $record->type,
            'is_system' => $record->user_id === null,
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'title' => [$required, 'string', 'max:255'],
            'icon' => [$required, 'string', 'max:255'],
            'color' => [$required, 'string', 'max:255'],
            'type' => [$required, 'in:income,expense'],
        ];
    }
}
