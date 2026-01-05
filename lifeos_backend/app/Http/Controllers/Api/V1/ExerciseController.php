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
        $exercise = Exercise::create([
            'user_id' => auth()->id(),
            ...$request->validated(),
        ]);

        return new ExerciseResource($exercise);
    }
}
