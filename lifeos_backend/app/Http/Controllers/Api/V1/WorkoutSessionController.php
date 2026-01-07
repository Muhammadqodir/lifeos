<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreWorkoutSessionRequest;
use App\Http\Requests\UpdateWorkoutSessionRequest;
use App\Http\Resources\WorkoutSessionResource;
use App\Models\WorkoutSession;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WorkoutSessionController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = WorkoutSession::where('user_id', auth()->id());

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

    public function show(WorkoutSession $workout): WorkoutSessionResource
    {
        $this->authorize('view', $workout);

        $workout->load(['workoutExercises.exercise', 'workoutExercises.sets']);

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
