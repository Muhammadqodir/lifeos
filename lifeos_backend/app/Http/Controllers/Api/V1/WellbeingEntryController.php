<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreWellbeingEntryRequest;
use App\Http\Requests\UpdateWellbeingEntryRequest;
use App\Http\Resources\WellbeingEntryResource;
use App\Models\WellbeingEntry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class WellbeingEntryController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = WellbeingEntry::where('user_id', auth()->id());

        if ($request->filled('from')) {
            $query->where('date', '>=', $request->from);
        }

        if ($request->filled('to')) {
            $query->where('date', '<=', $request->to);
        }

        $entries = $query->orderBy('date', 'desc')->get();

        return WellbeingEntryResource::collection($entries);
    }

    public function store(StoreWellbeingEntryRequest $request): WellbeingEntryResource
    {
        $entry = WellbeingEntry::create([
            'user_id' => auth()->id(),
            ...$request->validated(),
        ]);

        return new WellbeingEntryResource($entry);
    }

    public function update(UpdateWellbeingEntryRequest $request, WellbeingEntry $wellbeingEntry): WellbeingEntryResource
    {
        $this->authorize('update', $wellbeingEntry);

        $wellbeingEntry->update($request->validated());

        return new WellbeingEntryResource($wellbeingEntry->fresh());
    }

    public function destroy(WellbeingEntry $wellbeingEntry): JsonResponse
    {
        $this->authorize('delete', $wellbeingEntry);

        $wellbeingEntry->delete();

        return response()->json(['message' => 'Wellbeing entry deleted successfully']);
    }

    public function summary(Request $request): JsonResponse
    {
        $query = WellbeingEntry::where('user_id', auth()->id());

        if ($request->filled('from')) {
            $query->where('date', '>=', $request->from);
        }

        if ($request->filled('to')) {
            $query->where('date', '<=', $request->to);
        }

        $entries = $query->get();

        $count = $entries->count();
        $avgEnergy = $entries->avg('energy');
        $avgStress = $entries->avg('stress');

        $pointsByDay = $entries->map(function ($entry) {
            return [
                'date' => $entry->date->format('Y-m-d'),
                'energy' => $entry->energy,
                'stress' => $entry->stress,
            ];
        })->values();

        return response()->json([
            'count' => $count,
            'avg_energy' => $avgEnergy ? round($avgEnergy, 2) : null,
            'avg_stress' => $avgStress ? round($avgStress, 2) : null,
            'points' => $pointsByDay,
        ]);
    }
}
