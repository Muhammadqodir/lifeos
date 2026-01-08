<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSleepEntryRequest;
use App\Http\Requests\UpdateSleepEntryRequest;
use App\Http\Resources\SleepEntryResource;
use App\Models\SleepEntry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\DB;

class SleepEntryController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = SleepEntry::where('user_id', auth()->id());

        if ($request->filled('from')) {
            $query->where('date', '>=', $request->from);
        }

        if ($request->filled('to')) {
            $query->where('date', '<=', $request->to);
        }

        $entries = $query->orderBy('date', 'desc')->get();

        return SleepEntryResource::collection($entries);
    }

    public function store(StoreSleepEntryRequest $request): SleepEntryResource
    {
        $entry = SleepEntry::create([
            'user_id' => auth()->id(),
            ...$request->validated(),
        ]);

        return new SleepEntryResource($entry);
    }

    public function update(UpdateSleepEntryRequest $request, SleepEntry $sleepEntry): SleepEntryResource
    {
        $this->authorize('update', $sleepEntry);

        $sleepEntry->update($request->validated());

        return new SleepEntryResource($sleepEntry->fresh());
    }

    public function destroy(SleepEntry $sleepEntry): JsonResponse
    {
        $this->authorize('delete', $sleepEntry);

        $sleepEntry->delete();

        return response()->json(['message' => 'Sleep entry deleted successfully']);
    }

    public function summary(Request $request): JsonResponse
    {
        $query = SleepEntry::where('user_id', auth()->id());

        if ($request->filled('from')) {
            $query->where('date', '>=', $request->from);
        }

        if ($request->filled('to')) {
            $query->where('date', '<=', $request->to);
        }

        $entries = $query->get();

        $count = $entries->count();

        // Filter entries with both start and end times for duration calculation
        $entriesWithDuration = $entries->filter(fn($e) => $e->sleep_start && $e->sleep_end);

        $avgDuration = $entriesWithDuration->avg(fn($e) => $e->getDurationHours());
        $avgQuality = $entries->avg('quality');

        $pointsByDay = $entries->map(function ($entry) {
            return [
                'date' => $entry->date->format('Y-m-d'),
                'duration_hours' => $entry->getDurationHours(),
                'quality' => $entry->quality,
            ];
        })->values();

        return response()->json([
            'count' => $count,
            'avg_duration_hours' => $avgDuration ? round($avgDuration, 2) : null,
            'avg_quality' => $avgQuality ? round($avgQuality, 2) : null,
            'points' => $pointsByDay,
        ]);
    }
}
