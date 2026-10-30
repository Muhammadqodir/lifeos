<?php

namespace App\Sync;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

/**
 * How one table is exposed to the sync API.
 *
 * On the wire a record's `id` is its uuid, and foreign keys are the
 * parent's uuid, so clients can create related records offline.
 */
abstract class SyncEntity
{
    /** Name on the wire; also the table name. */
    abstract public function name(): string;

    /** @return class-string<Model> */
    abstract public function model(): string;

    /** Wire representation of a stored record. */
    abstract public function serialize(Model $record): array;

    /**
     * Validation rules for a create (all fields) or an update (only the
     * fields sent).
     */
    abstract public function rules(int $userId, bool $creating, ?Model $record): array;

    /** Relations needed by serialize(). */
    public function with(): array
    {
        return [];
    }

    /**
     * Turns validated wire data into model attributes (uuids to ids, etc.).
     */
    public function attributes(array $data, int $userId, ?Model $record): array
    {
        return $data;
    }

    /** Fields applied when a record is created without them. */
    public function defaults(array $attributes): array
    {
        return [];
    }

    /**
     * Gives the entity a chance to resolve a create against an existing
     * record with a different uuid (e.g. one habit entry per day).
     */
    public function existingFor(array $attributes, int $userId): ?Model
    {
        return null;
    }

    /** Records the user can see (pull) and refer to. */
    public function query(int $userId): Builder
    {
        return ($this->model())::query()->where('user_id', $userId);
    }

    /**
     * Stores a create or update. Aggregates (a transaction with its
     * entries, a workout with its sets) override this to write children.
     */
    public function persist(Model $record, array $attributes, array $validated, bool $creating): void
    {
        $record->fill($attributes)->save();
    }

    /** Handles a `delete` operation. */
    public function remove(Model $record): void
    {
        $record->delete();
    }

    protected static function iso(mixed $value): ?string
    {
        return $value ? Carbon::parse($value)->toISOString() : null;
    }

    /** Validation rule: a uuid of a live record of $table owned by the user. */
    protected static function ownedUuid(string $table, int $userId): \Illuminate\Validation\Rules\Exists
    {
        return \Illuminate\Validation\Rule::exists($table, 'uuid')
            ->where('user_id', $userId)
            ->whereNull('deleted_at');
    }
}
