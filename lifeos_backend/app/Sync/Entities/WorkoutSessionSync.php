<?php

namespace App\Sync\Entities;

use App\Models\Exercise;
use App\Models\WorkoutCompletion;
use App\Models\WorkoutSession;
use App\Sync\SyncEntity;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Validation\Rule;

/**
 * A workout with its exercises, sets and completion (measurements),
 * synced as one record. The progress photo is uploaded separately
 * (POST /gym/workouts/{id}/photo).
 */
class WorkoutSessionSync extends SyncEntity
{
    private const MEASUREMENTS = [
        'body_weight_kg', 'height_cm', 'biceps_cm', 'chest_cm',
        'waist_cm', 'thighs_cm', 'calfs_cm', 'notes',
    ];

    public function name(): string
    {
        return 'workout_sessions';
    }

    public function model(): string
    {
        return WorkoutSession::class;
    }

    public function with(): array
    {
        return ['workoutExercises.exercise:id,uuid', 'workoutExercises.sets', 'completion'];
    }

    public function serialize(Model $record): array
    {
        $completion = $record->completion;

        return [
            'id' => $record->uuid,
            'server_id' => $record->id,
            'started_at' => self::iso($record->started_at),
            'ended_at' => self::iso($record->ended_at),
            'note' => $record->note,
            'exercises' => $record->workoutExercises->sortBy('sort_order')->map(fn ($we) => [
                'exercise_id' => $we->exercise?->uuid,
                'order_index' => (int) $we->sort_order,
                'sets' => $we->sets->sortBy('set_index')->map(fn ($set) => [
                    'set_index' => (int) $set->set_index,
                    'weight_kg' => $set->weight_kg === null ? null : (float) $set->weight_kg,
                    'reps' => $set->reps,
                    'duration_seconds' => $set->duration_seconds,
                    'distance_meters' => $set->distance_meters === null ? null : (float) $set->distance_meters,
                    'rpe' => $set->rpe,
                    'is_done' => (bool) $set->is_done,
                ])->values()->all(),
            ])->values()->all(),
            'completion' => $completion ? [
                'photo_path' => $completion->photo_path,
                ...collect(self::MEASUREMENTS)->mapWithKeys(fn ($field) => [
                    $field => $field === 'notes' || $completion->{$field} === null
                        ? $completion->{$field}
                        : (float) $completion->{$field},
                ])->all(),
            ] : null,
            'created_at' => self::iso($record->created_at),
            'updated_at' => self::iso($record->updated_at),
        ];
    }

    public function rules(int $userId, bool $creating, ?Model $record): array
    {
        $required = $creating ? 'required' : 'sometimes';

        return [
            'started_at' => [$required, 'date'],
            'ended_at' => [$required, 'date', 'after_or_equal:started_at'],
            'note' => 'nullable|string',
            'exercises' => [$required, 'array'],
            'exercises.*.exercise_id' => [
                'required', 'uuid',
                Rule::exists('exercises', 'uuid')
                    ->where(fn ($q) => $q->where('user_id', $userId)->orWhereNull('user_id')),
            ],
            'exercises.*.order_index' => 'required|integer',
            'exercises.*.sets' => 'present|array',
            'exercises.*.sets.*.set_index' => 'required|integer',
            'exercises.*.sets.*.weight_kg' => 'nullable|numeric',
            'exercises.*.sets.*.reps' => 'nullable|integer',
            'exercises.*.sets.*.duration_seconds' => 'nullable|integer',
            'exercises.*.sets.*.distance_meters' => 'nullable|numeric',
            'exercises.*.sets.*.rpe' => 'nullable|integer|min:1|max:10',
            'exercises.*.sets.*.is_done' => 'nullable|boolean',
            'completion' => 'nullable|array',
            'completion.body_weight_kg' => 'nullable|numeric',
            'completion.height_cm' => 'nullable|numeric',
            'completion.biceps_cm' => 'nullable|numeric',
            'completion.chest_cm' => 'nullable|numeric',
            'completion.waist_cm' => 'nullable|numeric',
            'completion.thighs_cm' => 'nullable|numeric',
            'completion.calfs_cm' => 'nullable|numeric',
            'completion.notes' => 'nullable|string',
        ];
    }

    public function attributes(array $data, int $userId, ?Model $record): array
    {
        unset($data['exercises'], $data['completion']);

        return $data;
    }

    public function persist(Model $record, array $attributes, array $validated, bool $creating): void
    {
        $record->fill($attributes)->save();
        $changedChildren = false;

        if (array_key_exists('exercises', $validated)) {
            $exerciseIds = Exercise::whereIn('uuid', collect($validated['exercises'])->pluck('exercise_id'))
                ->pluck('id', 'uuid');
            $record->workoutExercises()->delete();
            foreach ($validated['exercises'] as $exercise) {
                $workoutExercise = $record->workoutExercises()->create([
                    'exercise_id' => $exerciseIds[$exercise['exercise_id']],
                    'sort_order' => $exercise['order_index'],
                ]);
                foreach ($exercise['sets'] as $set) {
                    $workoutExercise->sets()->create([
                        'set_index' => $set['set_index'],
                        'weight_kg' => $set['weight_kg'] ?? null,
                        'reps' => $set['reps'] ?? null,
                        'duration_seconds' => $set['duration_seconds'] ?? null,
                        'distance_meters' => $set['distance_meters'] ?? null,
                        'rpe' => $set['rpe'] ?? null,
                        'is_done' => $set['is_done'] ?? true,
                    ]);
                }
            }
            $changedChildren = true;
        }

        if (array_key_exists('completion', $validated)) {
            if ($validated['completion'] === null) {
                $record->completion()->delete();
            } else {
                WorkoutCompletion::updateOrCreate(
                    ['workout_session_id' => $record->id],
                    collect($validated['completion'])->only(self::MEASUREMENTS)->all(),
                );
            }
            $changedChildren = true;
        }

        if ($changedChildren) {
            $record->touch();
        }
    }
}
