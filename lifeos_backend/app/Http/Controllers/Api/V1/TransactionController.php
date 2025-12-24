<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransactionRequest;
use App\Http\Requests\UpdateTransactionRequest;
use App\Http\Resources\TransactionResource;
use App\Models\Transaction;
use App\Services\TransactionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class TransactionController extends Controller
{
    protected TransactionService $transactionService;

    public function __construct(TransactionService $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    /**
     * Display a paginated listing of transactions with filters.
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $perPage = min((int) $request->get('per_page', 20), 100);

        $query = Transaction::where('user_id', auth()->id())
            ->with(['entries.wallet', 'entries.currency', 'category']);

        // Filter by type
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        // Filter by wallet_id (transactions having an entry in that wallet)
        if ($request->has('wallet_id')) {
            $query->whereHas('entries', function ($q) use ($request) {
                $q->where('wallet_id', $request->wallet_id);
            });
        }

        // Filter by category_id
        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        // Filter by date range (occurred_at)
        if ($request->has('date_from')) {
            $query->where('occurred_at', '>=', $request->date_from);
        }

        if ($request->has('date_to')) {
            $query->where('occurred_at', '<=', $request->date_to);
        }

        // Search in description
        if ($request->has('q')) {
            $query->where('description', 'like', '%' . $request->q . '%');
        }

        // Order by occurred_at descending
        $query->orderBy('occurred_at', 'desc');

        $transactions = $query->paginate($perPage);

        return TransactionResource::collection($transactions);
    }

    /**
     * Store a newly created transaction.
     */
    public function store(StoreTransactionRequest $request): TransactionResource
    {
        $transaction = $this->transactionService->createTransaction(
            auth()->id(),
            $request->validated()
        );

        return new TransactionResource($transaction);
    }

    /**
     * Display the specified transaction.
     */
    public function show(Transaction $transaction): TransactionResource
    {
        // Ensure user owns this transaction
        if ($transaction->user_id !== auth()->id()) {
            abort(404);
        }

        $transaction->load(['entries.wallet', 'entries.currency', 'category']);

        return new TransactionResource($transaction);
    }

    /**
     * Update the specified transaction.
     */
    public function update(UpdateTransactionRequest $request, Transaction $transaction): TransactionResource
    {
        // Ensure user owns this transaction
        if ($transaction->user_id !== auth()->id()) {
            abort(404);
        }

        $transaction = $this->transactionService->updateTransaction(
            $transaction,
            $request->validated()
        );

        return new TransactionResource($transaction);
    }

    /**
     * Remove the specified transaction.
     */
    public function destroy(Transaction $transaction): JsonResponse
    {
        // Ensure user owns this transaction
        if ($transaction->user_id !== auth()->id()) {
            abort(404);
        }

        $transaction->delete();

        return response()->json(null, 204);
    }
}
