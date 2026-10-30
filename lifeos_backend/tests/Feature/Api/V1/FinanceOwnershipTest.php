<?php

namespace Tests\Feature\Api\V1;

use App\Models\Currency;
use App\Models\Transaction;
use App\Models\TransactionCategory;
use App\Models\TransactionEntry;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FinanceOwnershipTest extends TestCase
{
    use RefreshDatabase;

    private User $owner;
    private User $stranger;
    private Wallet $wallet;
    private Transaction $transaction;
    private TransactionCategory $category;

    protected function setUp(): void
    {
        parent::setUp();

        $this->owner = User::factory()->create();
        $this->stranger = User::factory()->create();

        $currency = Currency::create([
            'code' => 'USD',
            'name' => 'US Dollar',
            'icon' => '$',
            'color' => '#000000',
            'decimal_places' => 2,
        ]);

        $this->wallet = Wallet::create([
            'user_id' => $this->owner->id,
            'currency_id' => $currency->id,
            'name' => 'Cash',
            'type' => 'cash',
        ]);

        $this->category = TransactionCategory::create([
            'user_id' => $this->owner->id,
            'type' => 'expense',
            'title' => 'Food',
            'icon' => 'food',
            'color' => '#FF0000',
        ]);

        $this->transaction = Transaction::create([
            'user_id' => $this->owner->id,
            'type' => 'expense',
            'category_id' => $this->category->id,
            'description' => 'Lunch',
            'occurred_at' => now(),
        ]);

        TransactionEntry::create([
            'transaction_id' => $this->transaction->id,
            'wallet_id' => $this->wallet->id,
            'currency_id' => $currency->id,
            'amount' => -12.5,
        ]);
    }

    public function test_owner_can_read_and_change_their_wallet(): void
    {
        Sanctum::actingAs($this->owner);

        $this->getJson("/api/v1/wallets/{$this->wallet->id}")->assertOk();
        $this->getJson("/api/v1/wallets/{$this->wallet->id}/balance")
            ->assertOk()
            ->assertJsonPath('data.balance', -12.5);
        $this->putJson("/api/v1/wallets/{$this->wallet->id}", ['name' => 'Pocket'])
            ->assertOk()
            ->assertJsonPath('data.name', 'Pocket');
        $this->deleteJson("/api/v1/wallets/{$this->wallet->id}")->assertNoContent();
    }

    public function test_other_users_wallet_is_not_found(): void
    {
        Sanctum::actingAs($this->stranger);

        $this->getJson("/api/v1/wallets/{$this->wallet->id}")->assertNotFound();
        $this->getJson("/api/v1/wallets/{$this->wallet->id}/balance")->assertNotFound();
        $this->putJson("/api/v1/wallets/{$this->wallet->id}", ['name' => 'Mine'])->assertNotFound();
        $this->deleteJson("/api/v1/wallets/{$this->wallet->id}")->assertNotFound();

        $this->assertDatabaseHas('wallets', [
            'id' => $this->wallet->id,
            'name' => 'Cash',
            'is_active' => true,
        ]);
    }

    public function test_other_users_transaction_is_not_found(): void
    {
        Sanctum::actingAs($this->stranger);

        $this->getJson("/api/v1/transactions/{$this->transaction->id}")->assertNotFound();
        $this->putJson("/api/v1/transactions/{$this->transaction->id}", ['description' => 'x'])
            ->assertNotFound();
        $this->deleteJson("/api/v1/transactions/{$this->transaction->id}")->assertNotFound();

        $this->assertDatabaseHas('transactions', ['id' => $this->transaction->id]);
    }

    public function test_owner_can_view_and_delete_their_transaction(): void
    {
        Sanctum::actingAs($this->owner);

        $this->getJson("/api/v1/transactions/{$this->transaction->id}")
            ->assertOk()
            ->assertJsonPath('data.description', 'Lunch');
        $this->deleteJson("/api/v1/transactions/{$this->transaction->id}")->assertNoContent();
    }

    public function test_categories_can_only_be_changed_by_their_owner(): void
    {
        $system = TransactionCategory::create([
            'user_id' => null,
            'type' => 'expense',
            'title' => 'Transport',
            'icon' => 'bus',
            'color' => '#00FF00',
        ]);

        Sanctum::actingAs($this->stranger);
        $this->putJson("/api/v1/transaction-categories/{$this->category->id}", ['title' => 'x'])
            ->assertForbidden()
            ->assertJsonPath(
                'message',
                'Cannot update system categories or categories belonging to other users.'
            );
        $this->deleteJson("/api/v1/transaction-categories/{$system->id}")->assertForbidden();

        Sanctum::actingAs($this->owner);
        $this->putJson("/api/v1/transaction-categories/{$this->category->id}", ['title' => 'Groceries'])
            ->assertOk();
        $this->deleteJson("/api/v1/transaction-categories/{$system->id}")->assertForbidden();
        $this->deleteJson("/api/v1/transaction-categories/{$this->category->id}")->assertNoContent();
    }
}
