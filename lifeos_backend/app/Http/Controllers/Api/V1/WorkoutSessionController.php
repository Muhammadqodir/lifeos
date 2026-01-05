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
}
