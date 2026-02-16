<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Todo\StoreTodoRequest;
use App\Http\Requests\Todo\UpdateTodoRequest;
use App\Http\Requests\Todo\UpdateTodoStatusRequest;
use App\Http\Resources\TodoResource;
use App\Models\Todo;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class TodoController extends Controller
{
    use AuthorizesRequests;
    /**
     * Display a listing of the user's todos with filtering and ordering.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Todo::where('user_id', $request->user()->id)
            ->with('project');

        // Filter by project_id
        if ($request->filled('project_id')) {
            $query->where('project_id', $request->project_id);
        }

        // Filter by status
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // Filter by tag (JSON contains)
        if ($request->filled('tag')) {
            $query->whereJsonContains('tags', strtolower(trim($request->tag)));
        }

        // Filter by planned_date range
        if ($request->filled('planned_from')) {
            $query->where('planned_date', '>=', $request->planned_from);
        }

        if ($request->filled('planned_to')) {
            $query->where('planned_date', '<=', $request->planned_to);
        }

        // Search by title
        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        // Ordering
        $allowedOrderFields = ['planned_date', 'priority', 'urgency', 'energy', 'created_at'];
        $orderBy = $request->get('order_by', 'created_at');
        $orderDirection = $request->get('order_direction', 'desc');

        if (in_array($orderBy, $allowedOrderFields)) {
            $query->orderBy($orderBy, $orderDirection);
        }

        $todos = $query->paginate($request->get('per_page', 15));

        return TodoResource::collection($todos);
    }

    /**
     * Get todo counts by status for a specific project
     */
    public function getCountsByStatus(Request $request): JsonResponse
    {
        $projectId = $request->get('project_id');

        if (!$projectId) {
            return response()->json(['error' => 'project_id is required'], 400);
        }

        $counts = Todo::where('user_id', $request->user()->id)
            ->where('project_id', $projectId)
            ->selectRaw('status, count(*) as count')
            ->groupBy('status')
            ->pluck('count', 'status')
            ->map(fn($count) => (int) $count) // Cast to integer
            ->toArray();

        // Ensure all statuses are present with 0 count if not found
        $allStatuses = ['inbox', 'planned', 'in_progress', 'blocked', 'done'];
        $result = [];

        foreach ($allStatuses as $status) {
            $result[$status] = $counts[$status] ?? 0;
        }

        return response()->json([
            'data' => $result,
        ]);
    }

    /**
     * Store a newly created todo.
     */
    public function store(StoreTodoRequest $request): JsonResponse
    {
        $validated = $request->validated();

        // Auto-set status based on whether planned_date exists
        $validated['status'] = isset($validated['planned_date']) ? 'planned' : 'inbox';

        $todo = Todo::create([
            'user_id' => $request->user()->id,
            ...$validated,
        ]);

        $todo->load('project');

        return response()->json([
            'data' => new TodoResource($todo),
            'message' => 'Todo created successfully.',
        ], 201);
    }

    /**
     * Display the specified todo.
     */
    public function show(Request $request, Todo $todo): JsonResponse
    {
        $this->authorize('view', $todo);

        $todo->load('project');

        return response()->json([
            'data' => new TodoResource($todo),
        ]);
    }

    /**
     * Update the specified todo.
     */
    public function update(UpdateTodoRequest $request, Todo $todo): JsonResponse
    {
        $this->authorize('update', $todo);

        $todo->update($request->validated());

        $todo->load('project');

        return response()->json([
            'data' => new TodoResource($todo->fresh(['project'])),
            'message' => 'Todo updated successfully.',
        ]);
    }

    /**
     * Update the status of the specified todo.
     */
    public function updateStatus(UpdateTodoStatusRequest $request, Todo $todo): JsonResponse
    {
        $this->authorize('update', $todo);

        $updateData = [
            'status' => $request->status,
        ];

        // If planned_date is provided, update it
        if ($request->has('planned_date')) {
            $updateData['planned_date'] = $request->planned_date;
        }

        $todo->update($updateData);

        $todo->load('project');

        return response()->json([
            'data' => new TodoResource($todo->fresh(['project'])),
            'message' => 'Todo status updated successfully.',
        ]);
    }

    /**
     * Remove the specified todo (soft delete).
     */
    public function destroy(Request $request, Todo $todo): JsonResponse
    {
        $this->authorize('delete', $todo);

        $todo->delete();

        return response()->json([
            'message' => 'Todo deleted successfully.',
        ]);
    }
}
