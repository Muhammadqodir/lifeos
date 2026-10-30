<?php

namespace App\Sync;

use App\Sync\Entities\HabitEntrySync;
use App\Sync\Entities\HabitSync;
use App\Sync\Entities\ProjectSync;
use App\Sync\Entities\TodoSync;

/**
 * The synced entities, parents before children.
 */
final class SyncRegistry
{
    /** @var array<string, SyncEntity> */
    private array $entities = [];

    public function __construct()
    {
        foreach ([new ProjectSync, new TodoSync, new HabitSync, new HabitEntrySync] as $entity) {
            $this->entities[$entity->name()] = $entity;
        }
    }

    /** @return array<string, SyncEntity> */
    public function all(): array
    {
        return $this->entities;
    }

    public function get(string $name): ?SyncEntity
    {
        return $this->entities[$name] ?? null;
    }

    /** @return list<string> */
    public function names(): array
    {
        return array_keys($this->entities);
    }
}
