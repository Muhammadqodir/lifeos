<?php

namespace App\Services;

use App\Models\WorkoutCompletion;
use App\Models\WorkoutSession;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Workout business rules: recording a finished workout and the training
 * streak.
 */
class WorkoutService
{
    /**
     * Store a finished workout with its exercises, sets and optional
     * completion data (body measurements and a progress photo) in one
     * transaction.
     *
     * @param  array{started_at: string, ended_at: string, note?: ?string, exercises: array, completion?: ?array}  $data
     */
    public function recordCompleted(int $userId, array $data, ?UploadedFile $photo = null): WorkoutSession
    {
        $photoPath = $photo?->store('workout_photos/'.$userId, 'public');

        $session = DB::transaction(function () use ($userId, $data, $photoPath) {
            $session = WorkoutSession::create([
                'user_id' => $userId,
                'started_at' => $data['started_at'],
                'ended_at' => $data['ended_at'],
                'note' => $data['note'] ?? null,
            ]);

            foreach ($data['exercises'] as $exerciseData) {
                $workoutExercise = $session->workoutExercises()->create([
                    'exercise_id' => $exerciseData['exercise_id'],
                    'order_index' => $exerciseData['order_index'],
                    'note' => $exerciseData['note'] ?? null,
                ]);

                foreach ($exerciseData['sets'] as $setData) {
                    $workoutExercise->sets()->create([
                        'set_index' => $setData['set_index'],
                        'weight_kg' => $setData['weight_kg'] ?? null,
                        'reps' => $setData['reps'] ?? null,
                        'duration_seconds' => $setData['duration_seconds'] ?? null,
                        'distance_meters' => $setData['distance_meters'] ?? null,
                        'rpe' => $setData['rpe'] ?? null,
                        'is_done' => $setData['is_done'] ?? true,
                    ]);
                }
            }

            if (isset($data['completion'])) {
                $completion = $data['completion'];
                WorkoutCompletion::create([
                    'workout_session_id' => $session->id,
                    'photo_path' => $photoPath,
                    'body_weight_kg' => $completion['body_weight_kg'] ?? null,
                    'height_cm' => $completion['height_cm'] ?? null,
                    'biceps_cm' => $completion['biceps_cm'] ?? null,
                    'chest_cm' => $completion['chest_cm'] ?? null,
                    'waist_cm' => $completion['waist_cm'] ?? null,
                    'thighs_cm' => $completion['thighs_cm'] ?? null,
                    'calfs_cm' => $completion['calfs_cm'] ?? null,
                    'notes' => $completion['notes'] ?? null,
                ]);
            }

            return $session;
        });

        return $session->load(['workoutExercises.exercise', 'workoutExercises.sets', 'completion']);
    }

    /**
     * Consecutive days with at least one workout, counting back from today,
     * or from yesterday when today has none yet.
     */
    public function currentStreak(int $userId, ?Carbon $today = null): int
    {
        $today = ($today ?? Carbon::today())->copy()->startOfDay();

        // One query: distinct workout days, newest first, until the first gap.
        $days = WorkoutSession::where('user_id', $userId)
            ->where('started_at', '<', $today->copy()->addDay())
            ->orderBy('started_at', 'desc')
            ->pluck('started_at')
            ->map(fn ($startedAt) => Carbon::parse($startedAt)->toDateString())
            ->unique()
            ->values();

        $expected = $today->copy();
        if ($days->first() !== $expected->toDateString()) {
            $expected->subDay();
        }

        $streak = 0;
        foreach ($days as $day) {
            if ($day !== $expected->toDateString()) {
                break;
            }
            $streak++;
            $expected->subDay();
        }

        return $streak;
    }
}
