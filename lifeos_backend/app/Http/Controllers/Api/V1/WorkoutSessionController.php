<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCompleteWorkoutRequest;
use App\Http\Requests\StoreWorkoutSessionRequest;
use App\Http\Requests\UpdateWorkoutSessionRequest;
use App\Http\Resources\WorkoutSessionResource;
use App\Models\WorkoutSession;
use App\Services\WorkoutService;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WorkoutSessionController extends Controller
{
    use AuthorizesRequests;

    public function __construct(private readonly WorkoutService $workouts)
    {
    }

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
        $session = $this->workouts->recordCompleted(auth()->id(), $request->validated());

        return new WorkoutSessionResource($session);
    }

    /**
     * Store a complete workout with completion data (photo, measurements)
     */
    public function storeCompleteWithPhoto(Request $request): WorkoutSessionResource
    {
        $request->validate([
            'workout_data' => 'required|json',
            'photo' => 'nullable|image|max:10240', // max 10MB
        ]);

        $validated = validator(json_decode($request->workout_data, true), [
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

        $session = $this->workouts->recordCompleted(
            auth()->id(),
            $validated,
            $request->file('photo'),
        );

        return new WorkoutSessionResource($session);
    }

    /**
     * Attach or replace the progress photo. The local-first client syncs the
     * workout first and uploads the photo afterwards.
     */
    public function updatePhoto(Request $request, WorkoutSession $workout): WorkoutSessionResource
    {
        $this->authorize('update', $workout);
        $request->validate(['photo' => 'required|image|max:10240']);

        $path = $request->file('photo')->store('workout_photos/'.$workout->user_id, 'public');
        $completion = $workout->completion()->firstOrNew([]);
        if ($completion->photo_path) {
            Storage::disk('public')->delete($completion->photo_path);
        }
        $completion->photo_path = $path;
        $completion->save();
        $workout->touch();

        return new WorkoutSessionResource($workout->load(['workoutExercises.exercise', 'workoutExercises.sets', 'completion']));
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

    public function destroy(WorkoutSession $workout): Response
    {
        $this->authorize('delete', $workout);

        $workout->delete();

        return $this->noContent();

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
        $currentStreak = $this->workouts->currentStreak(auth()->id());

        return $this->ok([
            'count' => $sessions->count(),
            'current_streak' => $currentStreak,
            'sessions' => $sessionPoints,
        ]);
    }
}
