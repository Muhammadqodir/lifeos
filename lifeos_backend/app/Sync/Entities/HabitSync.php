<?php

namespace App\Sync\Entities;

use App\Models\Habit;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Validation\Rule;

class HabitSync extends SyncEntity
{
    public function name(): string
    {
        return 'habits';
    }

    public function model(): string
    {
        return Habit::class;
    }

    public function serialize(Model $record): array
    {
        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'title' => $record->title,
            'description' => $record->description,
            'color' => $record->color,
            'icon' => $record->icon,
            'status' => $record->status,
            'frequency' => $record->frequency,
            'frequency_days' => $record->frequency_days ?? [],
            'reminder_time' => $record->reminder_time ? substr($record->reminder_time, 0, 5) : null,
            'goal_duration' => $record->goal_duration,
            'tags' => $record->tags ?? [],
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'title' => [$required, 'string', 'min:3', 'max:120'],
            'description' => 'nullable|string|max:1000',
            'color' => 'nullable|string|regex:/^[0-9A-Fa-f]{6}$/',
            'icon' => 'nullable|string|max:100',
            'status' => ['sometimes', Rule::in(Habit::getAllowedStatuses())],
            'frequency' => [$required, Rule::in(Habit::getAllowedFrequencies())],
            'frequency_days' => 'nullable|array',
            'frequency_days.*' => 'integer|min:0|max:6',
            'reminder_time' => 'nullable|date_format:H:i',
            'goal_duration' => 'nullable|integer|min:1|max:365',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
        ];
    }

    public function defaults(array $attributes): array
    {
        return ['status' => Habit::STATUS_ACTIVE, 'color' => '3b82f6'];
    }
}
