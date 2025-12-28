<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\AnalyticsResource;
use App\Models\Transaction;
use App\Models\TransactionCategory;
use App\Models\UserFinanceSettings;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AnalyticsController extends Controller
{
    /**
     * Get analytics data for income and expense by category within a date range.
     */
    public function index(Request $request): AnalyticsResource
    {
        $request->validate([
            'date_from' => 'nullable|date',
            'date_to' => 'nullable|date|after_or_equal:date_from',
            'currency_id' => 'nullable|integer|exists:currencies,id',
        ]);

        $userId = auth()->id();

        // Get user's base currency
        $financeSettings = UserFinanceSettings::with('baseCurrency')
            ->where('user_id', $userId)
            ->first();

        // Determine which currency to use
        $currencyId = $request->currency_id ?? $financeSettings?->base_currency_id;
        $currencyIcon = $financeSettings?->baseCurrency?->icon ?? '$';

        // If currency_id is provided, get the currency icon
        if ($request->filled('currency_id')) {
            $currency = \App\Models\Currency::find($request->currency_id);
            $currencyIcon = $currency?->icon ?? $currencyIcon;
        }

        // Build base query for transactions
        $query = Transaction::where('user_id', $userId)
            ->with(['category', 'entries' => function ($query) use ($currencyId) {
                if ($currencyId) {
                    $query->where('currency_id', $currencyId);
                }
            }]);

        // Apply date filters
        if ($request->filled('date_from')) {
            $query->whereDate('occurred_at', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('occurred_at', '<=', $request->date_to);
        }

        $transactions = $query->get();

        // Separate income and expense transactions
        $incomeTransactions = $transactions->where('type', 'income');
        $expenseTransactions = $transactions->where('type', 'expense');

        // Calculate totals
        $totalIncome = $this->calculateTotal($incomeTransactions);
        $totalExpense = $this->calculateTotal($expenseTransactions);
        $netAmount = $totalIncome - $totalExpense;

        // Group by category
        $incomeByCategory = $this->groupByCategory($incomeTransactions);
        $expenseByCategory = $this->groupByCategory($expenseTransactions);

        return new AnalyticsResource([
            'total_income' => number_format($totalIncome, 2, '.', ''),
            'total_expense' => number_format($totalExpense, 2, '.', ''),
            'net_amount' => number_format($netAmount, 2, '.', ''),
            'currency_icon' => $currencyIcon,
            'date_from' => $request->date_from,
            'date_to' => $request->date_to,
            'income_by_category' => $incomeByCategory,
            'expense_by_category' => $expenseByCategory,
        ]);
    }

    /**
     * Calculate total amount from transactions.
     */
    private function calculateTotal($transactions): float
    {
        return $transactions->sum(function ($transaction) {
            // Sum all entry amounts for the transaction
            return $transaction->entries->sum('amount');
        });
    }

    /**
     * Group transactions by category and calculate summary.
     */
    private function groupByCategory($transactions): array
    {
        $grouped = $transactions->groupBy('category_id');

        return $grouped->map(function ($categoryTransactions, $categoryId) {
            $category = $categoryTransactions->first()->category;
            $totalAmount = $this->calculateTotal($categoryTransactions);

            return [
                'category_id' => $categoryId,
                'category_title' => $category?->title ?? 'Uncategorized',
                'category_icon' => $category?->icon ?? 'default',
                'category_color' => $category?->color ?? '#000000',
                'total_amount' => number_format($totalAmount, 2, '.', ''),
                'transaction_count' => $categoryTransactions->count(),
            ];
        })->values()->toArray();
    }
}
