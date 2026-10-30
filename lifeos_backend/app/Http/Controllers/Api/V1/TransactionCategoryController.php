<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCategoryRequest;
use App\Http\Requests\UpdateCategoryRequest;
use App\Http\Resources\TransactionCategoryResource;
use App\Models\TransactionCategory;
use Illuminate\Http\Response;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class TransactionCategoryController extends Controller
{
    /**
     * Display a listing of transaction categories (user + system).
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $userId = $request->user()->id;

        $query = TransactionCategory::query()
            ->where(function ($q) use ($userId) {
                $q->where('user_id', $userId)
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
            ...$request->validated(),
            'user_id' => $request->user()->id,
        ]);

        return new TransactionCategoryResource($category);
    }

    /**
     * Update the specified transaction category.
     */
    public function update(UpdateCategoryRequest $request, TransactionCategory $transaction_category): TransactionCategoryResource
    {
        $this->authorize('update', $transaction_category);

        $transaction_category->update($request->validated());

        return new TransactionCategoryResource($transaction_category);
    }

    /**
     * Remove the specified transaction category.
     */
    public function destroy(Request $request, TransactionCategory $transaction_category): Response
    {
        $this->authorize('delete', $transaction_category);

        $transaction_category->delete();

        return $this->noContent();
    }
}
