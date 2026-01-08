<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreWorkoutSetRequest;
use App\Http\Requests\UpdateWorkoutSetRequest;
use App\Http\Resources\WorkoutSetResource;
use App\Models\WorkoutExercise;
use App\Models\WorkoutSet;
use Illuminate\Http\JsonResponse;

class WorkoutSetController extends Controller
{
    public function store(StoreWorkoutSetRequest $request, WorkoutExercise $workoutExercise): WorkoutSetResource
    {
        $this->authorize('update', $workoutExercise->session);

        $set = WorkoutSet::create([
            'workout_exercise_id' => $workoutExercise->id,
            ...$request->validated(),
        ]);

        return new WorkoutSetResource($set);
    }

    public function update(UpdateWorkoutSetRequest $request, WorkoutSet $set): WorkoutSetResource
    {
        $this->authorize('update', $set);

        $set->update($request->validated());

        return new WorkoutSetResource($set->fresh());
    }

    public function destroy(WorkoutSet $set): JsonResponse
    {
        $this->authorize('delete', $set);

        $set->delete();

        return response()->json(['message' => 'Workout set deleted successfully']);
    }
}
