<?php

namespace App\Sync\Entities;

use App\Models\Project;
use App\Models\Todo;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Validation\Rule;

class TodoSync extends SyncEntity
{
    public function name(): string
    {
        return 'todos';
    }

    public function model(): string
    {
        return Todo::class;
    }

    public function with(): array
    {
        return ['project' => fn ($query) => $query->withTrashed()->select('id', 'uuid')];
    }

    public function serialize(Model $record): array
    {
        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'project_id' => $record->project?->uuid,
            'title' => $record->title,
            'comment' => $record->comment,
            'status' => $record->status,
            'priority' => $record->priority,
            'urgency' => $record->urgency,
            'energy' => $record->energy,
            'time_spent_minutes' => $record->time_spent_minutes,
            'planned_date' => $record->planned_date?->format('Y-m-d'),
            'planned_time' => $record->planned_time,
            'completed_at' => self::iso($record->completed_at),
            'tags' => $record->tags ?? [],
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'project_id' => [$required, 'uuid', self::ownedUuid('projects', $userId)],
            'title' => [$required, 'string', 'min:3', 'max:160'],
            'comment' => 'nullable|string',
            'status' => ['sometimes', Rule::in(Todo::getAllowedStatuses())],
            'priority' => [$required, Rule::in(Todo::getAllowedPriorities())],
            'urgency' => [$required, Rule::in(Todo::getAllowedUrgencies())],
            'energy' => [$required, Rule::in(Todo::getAllowedEnergies())],
            'time_spent_minutes' => 'nullable|integer|min:0',
            'planned_date' => 'nullable|date_format:Y-m-d',
            'planned_time' => 'nullable|date_format:H:i:s',
            'completed_at' => 'nullable|date',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
        ];
    }

    public function attributes(array $data, int $userId, ?Model $record): array
    {
        if (array_key_exists('project_id', $data)) {
            $data['project_id'] = Project::where('uuid', $data['project_id'])->value('id');
        }

        return $data;
    }

    public function defaults(array $attributes): array
    {
        return [
            'status' => empty($attributes['planned_date']) ? Todo::STATUS_INBOX : Todo::STATUS_PLANNED,
        ];
    }
}
