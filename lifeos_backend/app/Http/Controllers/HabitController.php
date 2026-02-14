<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreHabitRequest;
use App\Http\Requests\UpdateHabitRequest;
use App\Http\Resources\HabitResource;
use App\Models\Habit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Carbon;

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
        \Log::info('=== CREATE HABIT DEBUG ===');
        \Log::info('Request all data:', $request->all());
        \Log::info('Validated data:', $request->validated());

        $habit = Habit::create([
            'user_id' => auth()->id(),
            ...$request->validated(),
        ]);

        \Log::info('Created habit:', $habit->toArray());
        \Log::info('Raw attributes:', $habit->getAttributes());

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
    public function destroy(Habit $habit): JsonResponse
    {
        $this->authorize('delete', $habit);

        $habit->delete();

        return response()->json([
            'message' => 'Habit deleted successfully',
        ]);
    }

    /**
     * Get statistics for a specific habit.
     */
    public function stats(Request $request, Habit $habit): JsonResponse
    {
        $this->authorize('view', $habit);

        $days = $request->input('days', 30);

        $stats = [
            'current_streak' => $habit->getCurrentStreak(),
            'longest_streak' => $habit->getLongestStreak(),
            'completion_rate' => $habit->getCompletionRate($days),
            'is_completed_today' => $habit->isCompletedToday(),
            'total_entries' => $habit->entries()->count(),
        ];

        // Get entries for the last N days for charting
        $startDate = Carbon::today()->subDays($days - 1);
        $endDate = Carbon::today();

        $entries = $habit->getEntriesInRange($startDate, $endDate);

        $stats['entries_by_date'] = $entries->mapWithKeys(function ($entry) {
            return [$entry->date->format('Y-m-d') => true];
        });

        return response()->json($stats);
    }

    /**
     * Get all habits with today's completion status.
     */
    public function todayStatus(): AnonymousResourceCollection
    {
        $habits = Habit::where('user_id', auth()->id())
            ->where('status', Habit::STATUS_ACTIVE)
            ->orderBy('created_at', 'desc')
            ->get();

        return HabitResource::collection($habits)
            ->additional(['meta' => ['with_today' => true]]);
    }
}
