<?php

namespace App\Sync\Entities;

use App\Models\Habit;
use App\Models\HabitEntry;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

class HabitEntrySync extends SyncEntity
{
    public function name(): string
    {
        return 'habit_entries';
    }

    public function model(): string
    {
        return HabitEntry::class;
    }

    public function with(): array
    {
        return ['habit' => fn ($query) => $query->withTrashed()->select('id', 'uuid')];
    }

    public function serialize(Model $record): array
    {
        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'habit_id' => $record->habit?->uuid,
            'date' => $record->date->format('Y-m-d'),
            'completed_at' => self::iso($record->completed_at),
            'note' => $record->note,
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'habit_id' => [$required, 'uuid', self::ownedUuid('habits', $userId)],
            // The client sends its local date, which can be a day ahead of
            // the server's (UTC) today.
            'date' => [$required, 'date_format:Y-m-d', 'before_or_equal:tomorrow'],
            'completed_at' => 'nullable|date',
            'note' => 'nullable|string|max:500',
        ];
    }

    public function attributes(array $data, int $userId, ?Model $record): array
    {
        if (array_key_exists('habit_id', $data)) {
            $data['habit_id'] = Habit::where('uuid', $data['habit_id'])->value('id');
        }
        if (array_key_exists('completed_at', $data) && $data['completed_at'] !== null) {
            $data['completed_at'] = Carbon::parse($data['completed_at']);
        }

        return $data;
    }

    public function defaults(array $attributes): array
    {
        return ['completed_at' => now()];
    }

    /** One entry per habit and day: a second device's entry merges into it. */
    public function existingFor(array $attributes, int $userId): ?Model
    {
        if (empty($attributes['habit_id']) || empty($attributes['date'])) {
            return null;
        }

        return HabitEntry::where('habit_id', $attributes['habit_id'])
            ->whereDate('date', $attributes['date'])
            ->first();
    }
}
