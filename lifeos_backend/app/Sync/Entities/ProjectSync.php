<?php

namespace App\Sync\Entities;

use App\Models\Project;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Validation\Rule;

class ProjectSync extends SyncEntity
{
    public function name(): string
    {
        return 'projects';
    }

    public function model(): string
    {
        return Project::class;
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
            'tags' => $record->tags ?? [],
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'title' => [
                $required, 'string', 'min:3', 'max:120',
                Rule::unique('projects', 'title')
                    ->where('user_id', $userId)
                    ->whereNull('deleted_at')
                    ->ignore($record?->id),
            ],
            'description' => 'nullable|string',
            'color' => [$required, 'string', 'regex:/^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$/'],
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
        ];
    }
}
