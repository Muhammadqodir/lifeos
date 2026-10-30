<?php

namespace App\Sync\Entities;

use App\Models\WellbeingEntry;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Model;

class WellbeingEntrySync extends SyncEntity
{
    public function name(): string
    {
        return 'wellbeing_entries';
    }

    public function model(): string
    {
        return WellbeingEntry::class;
    }

    public function serialize(Model $record): array
    {
        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'date' => $record->date->format('Y-m-d'),
            'energy' => (int) $record->energy,
            'stress' => (int) $record->stress,
            'note' => $record->note,
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'date' => [$required, 'date_format:Y-m-d'],
            'energy' => [$required, 'integer', 'min:1', 'max:5'],
            'stress' => [$required, 'integer', 'min:1', 'max:5'],
            'note' => ['nullable', 'string'],
        ];
    }

    /** One entry per day: a second one for the same date replaces it. */
    public function existingFor(array $attributes, int $userId): ?Model
    {
        return WellbeingEntry::where('user_id', $userId)->whereDate('date', $attributes['date'])->first();
    }
}
