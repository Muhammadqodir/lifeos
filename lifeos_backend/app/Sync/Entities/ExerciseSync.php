<?php

namespace App\Sync\Entities;

use App\Models\Exercise;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class ExerciseSync extends SyncEntity
{
    public function name(): string
    {
        return 'exercises';
    }

    public function model(): string
    {
        return Exercise::class;
    }

    /** The user's own exercises plus the built-in ones. */
    public function query(int $userId): Builder
    {
        return Exercise::query()->accessibleBy($userId);
    }

    public function serialize(Model $record): array
    {
        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'name' => $record->name,
            'type' => $record->type,
            'image' => $record->image,
            'muscle_group' => $record->muscle_group,
            'is_system' => $record->isSystem(),
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'name' => [$required, 'string', 'max:120'],
            'type' => [$required, 'string', 'in:strength,distance,time'],
            'muscle_group' => ['nullable', 'string', 'max:255'],
        ];
    }
}
