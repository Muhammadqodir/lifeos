<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Sync\SyncRegistry;
use App\Sync\SyncService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Validation\Rule;

/**
 * Sync API for the local-first client (docs/local-first.md).
 */
class SyncController extends Controller
{
    public function __construct(
        private readonly SyncService $sync,
        private readonly SyncRegistry $registry,
    ) {
    }

    /**
     * GET /v1/sync/pull?cursor=… — everything changed since the cursor; all
     * records when there is none.
     */
    public function pull(Request $request): JsonResponse
    {
        $request->validate(['cursor' => 'nullable|date']);

        $since = $request->filled('cursor') ? Carbon::parse($request->input('cursor')) : null;

        return $this->ok($this->sync->pull($request->user()->id, $since));
    }

    /**
     * POST /v1/sync/push — apply queued operations in order. Each one is
     * applied or rejected on its own; the request only fails when its shape
     * is wrong.
     */
    public function push(Request $request): JsonResponse
    {
        $request->validate([
            'ops' => ['required', 'array', 'max:'.SyncService::MAX_OPS],
            'ops.*.op_id' => ['required', 'uuid'],
            'ops.*.entity' => ['required', Rule::in($this->registry->names())],
            'ops.*.id' => ['required', 'uuid'],
            'ops.*.type' => ['required', Rule::in(['create', 'update', 'delete'])],
            'ops.*.data' => ['nullable', 'array'],
        ]);

        $results = $this->sync->push($request->user()->id, array_values($request->input('ops')));

        return $this->ok(['results' => $results]);
    }
}
