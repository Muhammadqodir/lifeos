<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreWorkoutExerciseRequest;
use App\Http\Resources\WorkoutExerciseResource;
use App\Models\WorkoutExercise;
use App\Models\WorkoutSession;
use Illuminate\Http\JsonResponse;

class WorkoutExerciseController extends Controller
{
    public function store(StoreWorkoutExerciseRequest $request, WorkoutSession $workout): WorkoutExerciseResource
    {
        $this->authorize('update', $workout);

        $workoutExercise = WorkoutExercise::create([
            'session_id' => $workout->id,
            'exercise_id' => $request->exercise_id,
            'sort_order' => $request->sort_order ?? 0,
        ]);

        $workoutExercise->load(['exercise', 'sets']);

        return new WorkoutExerciseResource($workoutExercise);
    }

    public function destroy(WorkoutExercise $workoutExercise): JsonResponse
    {
        $this->authorize('delete', $workoutExercise);

        $workoutExercise->delete();

        return response()->json(['message' => 'Workout exercise deleted successfully']);
    }
}
