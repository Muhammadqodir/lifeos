<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCategoryRequest;
use App\Http\Requests\UpdateCategoryRequest;
use App\Http\Resources\TransactionCategoryResource;
use App\Models\TransactionCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class TransactionCategoryController extends Controller
{
    /**
     * Display a listing of transaction categories (user + system).
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = TransactionCategory::query()
            ->where(function ($q) {
                $q->where('user_id', auth()->id())
                  ->orWhereNull('user_id'); // System categories
            });

        // Filter by type if provided
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $categories = $query->get();

        return TransactionCategoryResource::collection($categories);
    }

    /**
     * Store a newly created transaction category.
     */
    public function store(StoreCategoryRequest $request): TransactionCategoryResource
    {
        $category = TransactionCategory::create([
            'user_id' => auth()->id(),
            ...$request->validated(),
        ]);

        return new TransactionCategoryResource($category);
    }

    /**
     * Update the specified transaction category.
     */
    public function update(UpdateCategoryRequest $request, TransactionCategory $category): TransactionCategoryResource
    {
        // Only allow updating user's own categories (not system categories)
        if ($category->user_id !== auth()->id()) {
            abort(403, 'Cannot update system categories or categories belonging to other users.');
        }

        $category->update($request->validated());

        return new TransactionCategoryResource($category);
    }

    /**
     * Remove the specified transaction category.
     */
    public function destroy(TransactionCategory $category): JsonResponse
    {
        // Only allow deleting user's own categories (not system categories)
        if ($category->user_id !== auth()->id()) {
            abort(403, 'Cannot delete system categories or categories belonging to other users.');
        }

        $category->delete();

        return response()->json(null, 204);
    }
}
