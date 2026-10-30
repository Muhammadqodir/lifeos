<?php

namespace App\Sync;

use App\Sync\Entities\HabitEntrySync;
use App\Sync\Entities\HabitSync;
use App\Sync\Entities\ProjectSync;
use App\Sync\Entities\TodoSync;
use App\Sync\Entities\ExerciseSync;
use App\Sync\Entities\SleepEntrySync;
use App\Sync\Entities\TransactionCategorySync;
use App\Sync\Entities\TransactionSync;
use App\Sync\Entities\WalletSync;
use App\Sync\Entities\WellbeingEntrySync;
use App\Sync\Entities\WorkoutSessionSync;

/**
 * The synced entities, parents before children.
 */
final class SyncRegistry
{
    /** @var array<string, SyncEntity> */
    private array $entities = [];

    public function __construct()
    {
        $entities = [
            new ProjectSync, new TodoSync, new HabitSync, new HabitEntrySync,
            new WalletSync, new TransactionCategorySync, new TransactionSync,
            new SleepEntrySync, new WellbeingEntrySync,
            new ExerciseSync, new WorkoutSessionSync,
        ];
        foreach ($entities as $entity) {
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
