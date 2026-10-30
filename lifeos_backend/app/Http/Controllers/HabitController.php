<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreHabitRequest;
use App\Http\Requests\UpdateHabitRequest;
use App\Http\Resources\HabitResource;
use App\Models\Habit;
use App\Services\HabitStatsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class HabitController extends Controller
{
    /**
     * Display a listing of habits.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Habit::where('user_id', auth()->id());

        // Filter by status
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        } else {
            // By default, only show active habits
            $query->where('status', Habit::STATUS_ACTIVE);
        }

        // Filter by frequency
        if ($request->filled('frequency')) {
            $query->where('frequency', $request->frequency);
        }

        // Search by title
        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        $habits = $query->orderBy('created_at', 'desc')->get();

        return HabitResource::collection($habits);
    }

    /**
     * Store a newly created habit.
     */
    public function store(StoreHabitRequest $request): HabitResource
    {
        $habit = Habit::create([
            'user_id' => auth()->id(),
            ...$request->validated(),
        ]);

        return new HabitResource($habit);
    }

    /**
     * Display the specified habit.
     */
    public function show(Habit $habit): HabitResource
    {
        $this->authorize('view', $habit);

        return new HabitResource($habit);
    }

    /**
     * Update the specified habit.
     */
    public function update(UpdateHabitRequest $request, Habit $habit): HabitResource
    {
        $this->authorize('update', $habit);

        $habit->update($request->validated());

        return new HabitResource($habit->fresh());
    }

    /**
     * Remove the specified habit.
     */
    public function destroy(Habit $habit): Response
    {
        $this->authorize('delete', $habit);

        $habit->delete();

        return $this->noContent();
    }

    /**
     * Get statistics for a specific habit.
     */
    public function stats(Request $request, Habit $habit, HabitStatsService $stats): JsonResponse
    {
        $this->authorize('view', $habit);

        $days = max(1, min((int) $request->input('days', 30), 366));

        return $this->ok($stats->stats($habit, $days));
    }

    /**
     * Get all habits with today's completion status.
     */
    public function todayStatus(): AnonymousResourceCollection
    {
        $habits = Habit::where('user_id', auth()->id())
            ->where('status', Habit::STATUS_ACTIVE)
            ->withCompletedToday()
            ->orderBy('created_at', 'desc')
            ->get();

        return HabitResource::collection($habits)
            ->additional(['meta' => ['with_today' => true]]);
    }
}
