<?php

namespace Tests\Feature\Api\V1;

use App\Models\Currency;
use App\Models\Transaction;
use App\Models\TransactionCategory;
use App\Models\TransactionEntry;
use App\Models\User;
use App\Models\UserFinanceSettings;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AnalyticsControllerTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Currency $currency;
    private Wallet $wallet;
    private TransactionCategory $incomeCategory;
    private TransactionCategory $expenseCategory;

    protected function setUp(): void
    {
        parent::setUp();

        // Create user
        $this->user = User::factory()->create();

        // Create currency
        $this->currency = Currency::create([
            'code' => 'USD',
            'name' => 'US Dollar',
            'icon' => '$',
            'color' => '#000000',
            'decimal_places' => 2,
        ]);

        // Create user finance settings
        UserFinanceSettings::create([
            'user_id' => $this->user->id,
            'base_currency_id' => $this->currency->id,
        ]);

        // Create wallet
        $this->wallet = Wallet::create([
            'user_id' => $this->user->id,
            'currency_id' => $this->currency->id,
            'name' => 'Test Wallet',
            'type' => 'cash',
            'balance' => 0,
        ]);

        // Create categories
        $this->incomeCategory = TransactionCategory::create([
            'user_id' => $this->user->id,
            'type' => 'income',
            'title' => 'Salary',
            'icon' => 'salary-icon',
            'color' => '#00FF00',
        ]);

        $this->expenseCategory = TransactionCategory::create([
            'user_id' => $this->user->id,
            'type' => 'expense',
            'title' => 'Food',
            'icon' => 'food-icon',
            'color' => '#FF0000',
        ]);
    }

    /** @test */
    public function it_returns_analytics_data_with_income_and_expense()
    {
        // Create income transaction
        $incomeTransaction = Transaction::create([
            'user_id' => $this->user->id,
            'type' => 'income',
            'category_id' => $this->incomeCategory->id,
            'description' => 'Test income',
            'occurred_at' => now(),
        ]);

        TransactionEntry::create([
            'transaction_id' => $incomeTransaction->id,
            'wallet_id' => $this->wallet->id,
            'currency_id' => $this->currency->id,
            'amount' => 5000.00,
        ]);

        // Create expense transaction
        $expenseTransaction = Transaction::create([
            'user_id' => $this->user->id,
            'type' => 'expense',
            'category_id' => $this->expenseCategory->id,
            'description' => 'Test expense',
            'occurred_at' => now(),
        ]);

        TransactionEntry::create([
            'transaction_id' => $expenseTransaction->id,
            'wallet_id' => $this->wallet->id,
            'currency_id' => $this->currency->id,
            'amount' => 1500.00,
        ]);

        // Make request
        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/analytics');

        // Assert response
        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    'total_income',
                    'total_expense',
                    'net_amount',
                    'currency_icon',
                    'date_from',
                    'date_to',
                    'income_by_category' => [
                        '*' => [
                            'category_id',
                            'category_title',
                            'category_icon',
                            'category_color',
                            'total_amount',
                            'transaction_count',
                        ],
                    ],
                    'expense_by_category' => [
                        '*' => [
                            'category_id',
                            'category_title',
                            'category_icon',
                            'category_color',
                            'total_amount',
                            'transaction_count',
                        ],
                    ],
                ],
            ]);

        $data = $response->json('data');

        // Assert totals
        $this->assertEquals('5000.00', $data['total_income']);
        $this->assertEquals('1500.00', $data['total_expense']);
        $this->assertEquals('3500.00', $data['net_amount']);
        $this->assertEquals('$', $data['currency_icon']);

        // Assert income by category
        $this->assertCount(1, $data['income_by_category']);
        $this->assertEquals($this->incomeCategory->id, $data['income_by_category'][0]['category_id']);
        $this->assertEquals('Salary', $data['income_by_category'][0]['category_title']);
        $this->assertEquals('salary-icon', $data['income_by_category'][0]['category_icon']);
        $this->assertEquals('#00FF00', $data['income_by_category'][0]['category_color']);
        $this->assertEquals('5000.00', $data['income_by_category'][0]['total_amount']);
        $this->assertEquals(1, $data['income_by_category'][0]['transaction_count']);

        // Assert expense by category
        $this->assertCount(1, $data['expense_by_category']);
        $this->assertEquals($this->expenseCategory->id, $data['expense_by_category'][0]['category_id']);
        $this->assertEquals('Food', $data['expense_by_category'][0]['category_title']);
        $this->assertEquals('food-icon', $data['expense_by_category'][0]['category_icon']);
        $this->assertEquals('#FF0000', $data['expense_by_category'][0]['category_color']);
        $this->assertEquals('1500.00', $data['expense_by_category'][0]['total_amount']);
        $this->assertEquals(1, $data['expense_by_category'][0]['transaction_count']);
    }

    /** @test */
    public function it_filters_analytics_by_date_range()
    {
        // Create transaction in date range
        $transactionInRange = Transaction::create([
            'user_id' => $this->user->id,
            'type' => 'income',
            'category_id' => $this->incomeCategory->id,
            'description' => 'In range',
            'occurred_at' => '2024-01-15',
        ]);

        TransactionEntry::create([
            'transaction_id' => $transactionInRange->id,
            'wallet_id' => $this->wallet->id,
            'currency_id' => $this->currency->id,
            'amount' => 1000.00,
        ]);

        // Create transaction outside date range
        $transactionOutsideRange = Transaction::create([
            'user_id' => $this->user->id,
            'type' => 'income',
            'category_id' => $this->incomeCategory->id,
            'description' => 'Outside range',
            'occurred_at' => '2024-02-15',
        ]);

        TransactionEntry::create([
            'transaction_id' => $transactionOutsideRange->id,
            'wallet_id' => $this->wallet->id,
            'currency_id' => $this->currency->id,
            'amount' => 2000.00,
        ]);

        // Make request with date filter
        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/analytics?date_from=2024-01-01&date_to=2024-01-31');

        // Assert response
        $response->assertOk();

        $data = $response->json('data');

        // Should only include transaction in range
        $this->assertEquals('1000.00', $data['total_income']);
        $this->assertEquals('0.00', $data['total_expense']);
    }

    /** @test */
    public function it_requires_authentication()
    {
        $response = $this->getJson('/api/v1/analytics');

        $response->assertUnauthorized();
    }

    /** @test */
    public function it_validates_date_parameters()
    {
        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/analytics?date_from=invalid-date');

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['date_from']);
    }

    /** @test */
    public function it_handles_multiple_transactions_in_same_category()
    {
        // Create two income transactions in same category
        for ($i = 0; $i < 2; $i++) {
            $transaction = Transaction::create([
                'user_id' => $this->user->id,
                'type' => 'income',
                'category_id' => $this->incomeCategory->id,
                'description' => "Income {$i}",
                'occurred_at' => now(),
            ]);

            TransactionEntry::create([
                'transaction_id' => $transaction->id,
                'wallet_id' => $this->wallet->id,
                'currency_id' => $this->currency->id,
                'amount' => 1000.00,
            ]);
        }

        // Make request
        $response = $this->actingAs($this->user, 'sanctum')
            ->getJson('/api/v1/analytics');

        // Assert response
        $response->assertOk();

        $data = $response->json('data');

        // Should aggregate both transactions
        $this->assertEquals('2000.00', $data['total_income']);
        $this->assertCount(1, $data['income_by_category']);
        $this->assertEquals('2000.00', $data['income_by_category'][0]['total_amount']);
        $this->assertEquals(2, $data['income_by_category'][0]['transaction_count']);
    }
}
