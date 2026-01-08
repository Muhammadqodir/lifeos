<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreExerciseRequest;
use App\Http\Resources\ExerciseResource;
use App\Models\Exercise;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ExerciseController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Exercise::accessibleBy(auth()->id());

        if ($request->filled('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }

        $exercises = $query->orderBy('name')->get();

        return ExerciseResource::collection($exercises);
    }

    public function store(StoreExerciseRequest $request): ExerciseResource
    {
        $data = [
            'user_id' => auth()->id(),
            'name' => $request->name,
            'type' => $request->type,
            'muscle_group' => $request->muscle_group,
        ];

        // Handle image upload
        if ($request->hasFile('image')) {
            $path = $request->file('image')->store('exercises', 'public');
            $data['image'] = '/storage/' . $path;
        }

        $exercise = Exercise::create($data);

        return new ExerciseResource($exercise);
    }

    public function destroy(Exercise $exercise)
    {
        // Only allow deleting user's own custom exercises
        if ($exercise->user_id !== auth()->id()) {
            return response()->json([
                'message' => 'Unauthorized to delete this exercise',
            ], 403);
        }

        if ($exercise->is_system) {
            return response()->json([
                'message' => 'Cannot delete system exercises',
            ], 403);
        }

        $exercise->delete();

        return response()->json([
            'message' => 'Exercise deleted successfully',
        ]);
    }
}
