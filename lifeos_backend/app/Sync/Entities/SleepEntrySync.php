<?php

namespace App\Sync\Entities;

use App\Models\SleepEntry;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Model;

class SleepEntrySync extends SyncEntity
{
    public function name(): string
    {
        return 'sleep_entries';
    }

    public function model(): string
    {
        return SleepEntry::class;
    }

    public function serialize(Model $record): array
    {
        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'date' => $record->date->format('Y-m-d'),
            'sleep_start' => self::iso($record->sleep_start),
            'sleep_end' => self::iso($record->sleep_end),
            'quality' => (int) $record->quality,
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
            'sleep_start' => ['nullable', 'date'],
            'sleep_end' => ['nullable', 'date', 'after:sleep_start'],
            'quality' => [$required, 'integer', 'min:1', 'max:5'],
            'note' => ['nullable', 'string'],
        ];
    }

    /** One entry per night: a second one for the same date replaces it. */
    public function existingFor(array $attributes, int $userId): ?Model
    {
        return SleepEntry::where('user_id', $userId)->whereDate('date', $attributes['date'])->first();
    }
}
