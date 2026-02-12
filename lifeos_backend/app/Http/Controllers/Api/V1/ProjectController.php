<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Project\StoreProjectRequest;
use App\Http\Requests\Project\UpdateProjectRequest;
use App\Http\Resources\ProjectResource;
use App\Models\Project;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class ProjectController extends Controller
{
    use AuthorizesRequests;
    /**
     * Display a listing of the user's projects.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Project::where('user_id', $request->user()->id)
            ->withCount([
                'todos as pending_todos_count' => function ($query) {
                    $query->where('status', '!=', 'done');
                },
                'todos as completed_todos_count' => function ($query) {
                    $query->where('status', 'done');
                },
            ]);

        // Search by title
        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%');
        }

        $projects = $query->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 15));

        return ProjectResource::collection($projects);
    }

    /**
     * Store a newly created project.
     */
    public function store(StoreProjectRequest $request): JsonResponse
    {
        $data = [
            'user_id' => $request->user()->id,
            'title' => $request->title,
            'color' => $request->color,
        ];

        // Handle optional fields
        if ($request->filled('description')) {
            $data['description'] = $request->description;
        }

        if ($request->filled('tags')) {
            $data['tags'] = $request->tags;
        }

        // Handle file upload for icon
        if ($request->hasFile('icon')) {
            $iconPath = $request->file('icon')->store('project-icons', 'public');
            $data['icon'] = $iconPath;
        }

        $project = Project::create($data);

        // Load the todos counts for the response
        $project->loadCount([
            'todos as pending_todos_count' => function ($query) {
                $query->where('status', '!=', 'done');
            },
            'todos as completed_todos_count' => function ($query) {
                $query->where('status', 'done');
            },
        ]);

        return response()->json([
            'data' => new ProjectResource($project),
            'message' => 'Project created successfully.',
        ], 201);
    }

    /**
     * Display the specified project.
     */
    public function show(Request $request, Project $project): JsonResponse
    {
        $this->authorize('view', $project);

        $project->loadCount([
            'todos as pending_todos_count' => function ($query) {
                $query->where('status', '!=', 'done');
            },
            'todos as completed_todos_count' => function ($query) {
                $query->where('status', 'done');
            },
        ]);

        return response()->json([
            'data' => new ProjectResource($project),
        ]);
    }

    /**
     * Update the specified project.
     */
    public function update(UpdateProjectRequest $request, Project $project): JsonResponse
    {
        $this->authorize('update', $project);

        $project->update($request->validated());

        return response()->json([
            'data' => new ProjectResource($project->fresh()),
            'message' => 'Project updated successfully.',
        ]);
    }

    /**
     * Remove the specified project (soft delete).
     */
    public function destroy(Request $request, Project $project): JsonResponse
    {
        $this->authorize('delete', $project);

        $project->delete();

        return response()->json([
            'message' => 'Project deleted successfully.',
        ]);
    }
}
