<?php

namespace App\Http\Controllers;

use App\Exceptions\ApiException;
use App\Http\Requests\StoreHabitEntryRequest;
use App\Http\Resources\HabitEntryResource;
use App\Models\Habit;
use App\Models\HabitEntry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class HabitEntryController extends Controller
{
    /**
     * Display a listing of habit entries.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = HabitEntry::where('user_id', auth()->id());

        // Filter by habit
        if ($request->filled('habit_id')) {
            $query->where('habit_id', $request->habit_id);
        }

        // Filter by date range
        if ($request->filled('from')) {
            $query->where('date', '>=', $request->from);
        }

        if ($request->filled('to')) {
            $query->where('date', '<=', $request->to);
        }

        $entries = $query->with('habit')
            ->orderBy('date', 'desc')
            ->get();

        return HabitEntryResource::collection($entries);
    }

    /**
     * Store a newly created habit entry.
     */
    public function store(StoreHabitEntryRequest $request, Habit $habit): HabitEntryResource
    {
        $this->authorize('view', $habit);

        // Check if entry already exists for this date
        $existingEntry = HabitEntry::where('habit_id', $habit->id)
            ->where('date', $request->date)
            ->first();

        if ($existingEntry) {
            throw ApiException::conflict('Entry already exists for this date', 'habit_entry_exists');
        }

        $entry = HabitEntry::create([
            'habit_id' => $habit->id,
            'user_id' => auth()->id(),
            'date' => $request->date,
            'completed_at' => $request->completed_at ?? now(),
            'note' => $request->note,
        ]);

        return new HabitEntryResource($entry->load('habit'));
    }

    /**
     * Display the specified habit entry.
     */
    public function show(HabitEntry $habitEntry): HabitEntryResource
    {
        $this->authorize('view', $habitEntry->habit);

        return new HabitEntryResource($habitEntry->load('habit'));
    }

    /**
     * Remove the specified habit entry.
     */
    public function destroy(HabitEntry $habitEntry): Response
    {
        $this->authorize('delete', $habitEntry->habit);

        $habitEntry->delete();

        return $this->noContent();
    }

    /**
     * Get entries for a specific date range (for calendar view).
     */
    public function calendar(Request $request): JsonResponse
    {
        $request->validate([
            'from' => 'required|date|date_format:Y-m-d',
            'to' => 'required|date|date_format:Y-m-d',
        ]);

        $entries = HabitEntry::where('user_id', auth()->id())
            ->whereBetween('date', [$request->from, $request->to])
            ->with('habit')
            ->orderBy('date', 'desc')
            ->get();

        $groupedByDate = $entries->groupBy(function ($entry) {
            return $entry->date->format('Y-m-d');
        });

        return $this->ok([
            'entries_by_date' => $groupedByDate,
        ]);
    }
}
