<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCompleteWorkoutRequest;
use App\Http\Requests\StoreWorkoutSessionRequest;
use App\Http\Requests\UpdateWorkoutSessionRequest;
use App\Http\Resources\WorkoutSessionResource;
use App\Models\WorkoutCompletion;
use App\Models\WorkoutSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class WorkoutSessionController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = WorkoutSession::where('user_id', auth()->id())
            ->with(['workoutExercises.exercise', 'workoutExercises.sets', 'completion']);

        if ($request->filled('from')) {
            $query->where('started_at', '>=', $request->from);
        }

        if ($request->filled('to')) {
            $query->where('started_at', '<=', $request->to);
        }

        $sessions = $query->orderBy('started_at', 'desc')
            ->paginate(20);

        return WorkoutSessionResource::collection($sessions);
    }

    public function store(StoreWorkoutSessionRequest $request): WorkoutSessionResource
    {
        $session = WorkoutSession::create([
            'user_id' => auth()->id(),
            ...$request->validated(),
        ]);

        return new WorkoutSessionResource($session);
    }

    /**
     * Store a complete workout with exercises and sets in one request
     */
    public function storeComplete(StoreCompleteWorkoutRequest $request): WorkoutSessionResource
    {
        DB::beginTransaction();

        try {
            // Create workout session
            $session = WorkoutSession::create([
                'user_id' => auth()->id(),
                'started_at' => $request->started_at,
                'ended_at' => $request->ended_at,
                'note' => $request->note,
            ]);

            // Create exercises and sets
            foreach ($request->exercises as $exerciseData) {
                $workoutExercise = $session->workoutExercises()->create([
                    'exercise_id' => $exerciseData['exercise_id'],
                    'order_index' => $exerciseData['order_index'],
                    'note' => $exerciseData['note'] ?? null,
                ]);

                // Create sets for this exercise
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

            DB::commit();

            // Load relationships and return
            $session->load(['workoutExercises.exercise', 'workoutExercises.sets']);

            return new WorkoutSessionResource($session);
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Store a complete workout with completion data (photo, measurements)
     */
    public function storeCompleteWithPhoto(Request $request): WorkoutSessionResource
    {
        // Validate the request
        $request->validate([
            'workout_data' => 'required|json',
            'photo' => 'nullable|image|max:10240', // max 10MB
        ]);

        $workoutData = json_decode($request->workout_data, true);

        // Validate workout data structure
        $validated = validator($workoutData, [
            'started_at' => 'required|date',
            'ended_at' => 'required|date|after:started_at',
            'note' => 'nullable|string',
            'exercises' => 'required|array|min:1',
            'exercises.*.exercise_id' => 'required|exists:exercises,id',
            'exercises.*.order_index' => 'required|integer',
            'exercises.*.note' => 'nullable|string',
            'exercises.*.sets' => 'required|array|min:1',
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
        ])->validate();

        DB::beginTransaction();

        try {
            // Create workout session
            $session = WorkoutSession::create([
                'user_id' => auth()->id(),
                'started_at' => $validated['started_at'],
                'ended_at' => $validated['ended_at'],
                'note' => $validated['note'] ?? null,
            ]);

            // Create exercises and sets
            foreach ($validated['exercises'] as $exerciseData) {
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

            // Handle photo upload
            $photoPath = null;
            if ($request->hasFile('photo')) {
                $photoPath = $request->file('photo')->store(
                    'workout_photos/' . auth()->id(),
                    'public'
                );
            }

            // Create completion data
            if (isset($validated['completion'])) {
                WorkoutCompletion::create([
                    'workout_session_id' => $session->id,
                    'photo_path' => $photoPath,
                    'body_weight_kg' => $validated['completion']['body_weight_kg'] ?? null,
                    'height_cm' => $validated['completion']['height_cm'] ?? null,
                    'biceps_cm' => $validated['completion']['biceps_cm'] ?? null,
                    'chest_cm' => $validated['completion']['chest_cm'] ?? null,
                    'waist_cm' => $validated['completion']['waist_cm'] ?? null,
                    'thighs_cm' => $validated['completion']['thighs_cm'] ?? null,
                    'calfs_cm' => $validated['completion']['calfs_cm'] ?? null,
                    'notes' => $validated['completion']['notes'] ?? null,
                ]);
            }

            DB::commit();

            // Load relationships and return
            $session->load(['workoutExercises.exercise', 'workoutExercises.sets', 'completion']);

            return new WorkoutSessionResource($session);
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function show(WorkoutSession $workout): WorkoutSessionResource
    {
        $this->authorize('view', $workout);

        $workout->load(['workoutExercises.exercise', 'workoutExercises.sets', 'completion']);

        return new WorkoutSessionResource($workout);
    }

    public function update(UpdateWorkoutSessionRequest $request, WorkoutSession $workout): WorkoutSessionResource
    {
        $this->authorize('update', $workout);

        $workout->update($request->validated());

        return new WorkoutSessionResource($workout->fresh());
    }

    public function destroy(WorkoutSession $workout): JsonResponse
    {
        $this->authorize('delete', $workout);

        $workout->delete();

        return response()->json(['message' => 'Workout session deleted successfully']);
    }

    public function summary(Request $request): JsonResponse
    {
        $query = WorkoutSession::where('user_id', auth()->id());

        if ($request->filled('from')) {
            $query->where('started_at', '>=', $request->from.' 00:00:00');
        }

        if ($request->filled('to')) {
            $query->where('started_at', '<=', $request->to.' 23:59:59');
        }

        // Get all sessions in the date range
        $sessions = $query->orderBy('started_at', 'asc')->get();

        // Group by date to determine which days have sessions
        $sessionsByDate = $sessions->groupBy(function ($session) {
            return $session->started_at->format('Y-m-d');
        });

        // Build the response with has_session flag for each day
        $sessionPoints = $sessionsByDate->map(function ($daySessions, $date) {
            return [
                'date' => $date,
                'has_session' => true,
            ];
        })->values();

        // Calculate current streak (consecutive days from today backwards)
        $currentStreak = $this->calculateCurrentStreak();

        return response()->json([
            'count' => $sessions->count(),
            'current_streak' => $currentStreak,
            'sessions' => $sessionPoints,
        ]);
    }

    private function calculateCurrentStreak(): int
    {
        $streak = 0;
        $currentDate = now()->startOfDay();

        // Check if there's a workout today or yesterday (to account for streak continuation)
        $hasWorkoutToday = WorkoutSession::where('user_id', auth()->id())
            ->whereDate('started_at', $currentDate)
            ->exists();

        $hasWorkoutYesterday = WorkoutSession::where('user_id', auth()->id())
            ->whereDate('started_at', $currentDate->copy()->subDay())
            ->exists();

        // If no workout today or yesterday, streak is 0
        if (!$hasWorkoutToday && !$hasWorkoutYesterday) {
            return 0;
        }

        // Start counting from today or yesterday based on which has a workout
        $checkDate = $hasWorkoutToday ? $currentDate : $currentDate->copy()->subDay();

        // Count consecutive days backwards
        while (true) {
            $hasWorkout = WorkoutSession::where('user_id', auth()->id())
                ->whereDate('started_at', $checkDate)
                ->exists();

            if ($hasWorkout) {
                $streak++;
                $checkDate = $checkDate->copy()->subDay();
            } else {
                break;
            }
        }

        return $streak;
    }
}
