<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ExerciseResource;
use App\Models\Exercise;
use App\Models\WorkoutSet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ExerciseProgressController extends Controller
{
    public function show(Request $request, Exercise $exercise): JsonResponse
    {
        // Get all sets for this exercise by this user within date range
        $query = WorkoutSet::select([
                'workout_sets.*',
                DB::raw('DATE(workout_sessions.started_at) as workout_date')
            ])
            ->join('workout_exercises', 'workout_sets.workout_exercise_id', '=', 'workout_exercises.id')
            ->join('workout_sessions', 'workout_exercises.session_id', '=', 'workout_sessions.id')
            ->where('workout_exercises.exercise_id', $exercise->id)
            ->where('workout_sessions.user_id', auth()->id())
            ->where('workout_sets.is_done', true);

        if ($request->filled('from')) {
            $query->where('workout_sessions.started_at', '>=', $request->from);
        }

        if ($request->filled('to')) {
            $query->where('workout_sessions.started_at', '<=', $request->to);
        }

        $sets = $query->get();

        // Group by date and calculate metrics
        $pointsByDate = $sets->groupBy('workout_date')->map(function ($dateSets, $date) {
            $volume = $dateSets->sum(fn($set) => $set->weight_kg * $set->reps);
            $bestSetWeight = $dateSets->max('weight_kg');
            $bestE1RM = $dateSets->max(fn($set) => $set->getEstimated1RM());

            return [
                'date' => $date,
                'volume' => round($volume, 2),
                'best_set_weight' => (float) $bestSetWeight,
                'best_e1rm' => round($bestE1RM, 2),
            ];
        })->sortBy('date')->values();

        return response()->json([
            'exercise' => new ExerciseResource($exercise),
            'points' => $pointsByDate,
        ]);
    }
}
