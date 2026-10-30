<?php

namespace App\Sync;

use App\Models\SyncOperation;
use App\Models\SyncTombstone;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\QueryException;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

/**
 * Pull: every record changed since a cursor, plus deletions.
 * Push: apply a client's queued operations one by one.
 *
 * See docs/local-first.md for the protocol.
 */
class SyncService
{
    public const MAX_OPS = 200;

    public function __construct(private readonly SyncRegistry $registry)
    {
    }

    /**
     * @return array{cursor: string, full: bool, changes: array<string, list<array>>, deleted: array<string, list<string>>}
     */
    public function pull(int $userId, ?Carbon $since): array
    {
        // Taken before reading, and compared with >=, so a write landing
        // while this runs is sent again next time rather than missed.
        $cursor = Carbon::now()->startOfSecond();
        $since = $since?->copy()->setTimezone(config('app.timezone'));

        $changes = [];
        $deleted = [];
        foreach ($this->registry->all() as $name => $entity) {
            $query = $entity->query($userId)->with($entity->with());
            if ($since) {
                $query->where('updated_at', '>=', $since);
            }
            $changes[$name] = $query->orderBy('id')->get()
                ->map(fn (Model $record) => $entity->serialize($record))
                ->all();

            $deleted[$name] = $since
                ? SyncTombstone::where('user_id', $userId)
                    ->where('entity', $name)
                    ->where('deleted_at', '>=', $since)
                    ->pluck('uuid')
                    ->all()
                : [];
        }

        return [
            'cursor' => $cursor->toISOString(),
            'full' => $since === null,
            'changes' => $changes,
            'deleted' => $deleted,
        ];
    }

    /**
     * @param  list<array{op_id: string, entity: string, id: string, type: string, data?: array}>  $ops
     * @return list<array>
     */
    public function push(int $userId, array $ops): array
    {
        return array_map(fn (array $op) => $this->applyOnce($userId, $op), $ops);
    }

    private function applyOnce(int $userId, array $op): array
    {
        $previous = SyncOperation::where('user_id', $userId)->where('op_id', $op['op_id'])->first();
        if ($previous) {
            return $previous->result;
        }

        try {
            $record = DB::transaction(fn () => $this->apply($userId, $op));
            $result = ['op_id' => $op['op_id'], 'status' => 'applied', 'record' => $record];
        } catch (SyncRejection $e) {
            $result = $this->rejected($userId, $op, $e->errorCode, $e->getMessage(), $e->errors);
        } catch (ValidationException $e) {
            $result = $this->rejected($userId, $op, 'validation_failed', $e->getMessage(), $e->errors());
        } catch (QueryException $e) {
            // Unique keys the validator cannot see, e.g. a project title
            // still held by a deleted project.
            if (($e->errorInfo[0] ?? null) !== '23000') {
                throw $e;
            }
            $result = $this->rejected($userId, $op, 'conflict', 'This conflicts with an existing item.');
        }

        SyncOperation::create(['user_id' => $userId, 'op_id' => $op['op_id'], 'result' => $result]);

        return $result;
    }

    /** @return array|null The stored record after the operation. */
    private function apply(int $userId, array $op): ?array
    {
        $entity = $this->registry->get($op['entity']);
        $record = $this->find($entity, $op['id']);

        if ($record && (int) $record->user_id !== $userId) {
            throw new SyncRejection('forbidden', 'This item belongs to someone else.');
        }
        $trashed = $record && in_array(SoftDeletes::class, class_uses_recursive($record), true) && $record->trashed();

        if ($op['type'] === 'delete') {
            if ($record && ! $trashed) {
                $entity->remove($record);
            }

            return null;
        }

        if ($trashed || ($record === null && $op['type'] === 'update')) {
            throw new SyncRejection('gone', 'This item was deleted.');
        }

        $creating = $record === null;
        $validated = Validator::make($op['data'] ?? [], $entity->rules($userId, $creating, $record))->validate();
        $attributes = $entity->attributes($validated, $userId, $record);

        if ($creating) {
            foreach ($entity->defaults($attributes) as $key => $value) {
                $attributes[$key] ??= $value;
            }
            $record = $entity->existingFor($attributes, $userId);
            if ($record === null) {
                $record = new ($entity->model());
                $record->forceFill(['uuid' => $op['id'], 'user_id' => $userId]);
            }
        }

        $entity->persist($record, $attributes, $validated, $creating);

        return $entity->serialize($record->fresh($entity->with()));
    }

    private function find(SyncEntity $entity, string $uuid): ?Model
    {
        $query = ($entity->model())::query();
        if (in_array(SoftDeletes::class, class_uses_recursive($entity->model()), true)) {
            $query->withTrashed();
        }

        return $query->where('uuid', $uuid)->first();
    }

    /**
     * A rejection carries the server's current copy (or null when there is
     * none), so the client can drop its change and show the real state.
     */
    private function rejected(int $userId, array $op, string $code, string $message, ?array $errors = null): array
    {
        $entity = $this->registry->get($op['entity']);
        $current = $entity->query($userId)->with($entity->with())->where('uuid', $op['id'])->first();

        return array_filter([
            'op_id' => $op['op_id'],
            'status' => 'rejected',
            'code' => $code,
            'message' => $message,
            'errors' => $errors,
            'record' => $current ? $entity->serialize($current) : null,
        ], fn ($value, $key) => $value !== null || $key === 'record', ARRAY_FILTER_USE_BOTH);
    }
}
