<?php

namespace Tests\Feature\Api\V1;

use App\Models\Currency;
use App\Models\Exercise;
use App\Models\SleepEntry;
use App\Models\TransactionCategory;
use App\Models\User;
use App\Models\Wallet;
use App\Models\WorkoutSession;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FinanceHealthSyncTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    private Currency $usd;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
        $this->usd = Currency::create(['code' => 'USD', 'name' => 'US Dollar', 'color' => '22c55e', 'icon' => '$']);
        Sanctum::actingAs($this->user);
    }

    private function push(array ...$ops)
    {
        return $this->postJson('/api/v1/sync/push', ['ops' => array_map(
            fn ($op) => ['op_id' => (string) Str::uuid(), 'data' => [], ...$op],
            $ops,
        )])->assertOk();
    }

    public function test_a_transaction_created_offline_with_its_wallet_and_category(): void
    {
        $walletId = (string) Str::uuid();
        $categoryId = (string) Str::uuid();
        $transactionId = (string) Str::uuid();

        $this->push(
            ['entity' => 'wallets', 'type' => 'create', 'id' => $walletId, 'data' => ['name' => 'Cash', 'currency_id' => $this->usd->id, 'type' => 'cash']],
            ['entity' => 'transaction_categories', 'type' => 'create', 'id' => $categoryId, 'data' => ['title' => 'Food', 'icon' => 'food', 'color' => 'f97316', 'type' => 'expense']],
            ['entity' => 'transactions', 'type' => 'create', 'id' => $transactionId, 'data' => [
                'type' => 'expense', 'category_id' => $categoryId, 'occurred_at' => '2026-10-30T12:00:00Z',
                'entries' => [['wallet_id' => $walletId, 'amount' => -12.5, 'currency_id' => $this->usd->id]],
            ]],
        )
            ->assertJsonPath('data.results.2.status', 'applied')
            ->assertJsonPath('data.results.2.record.category_id', $categoryId)
            ->assertJsonPath('data.results.2.record.entries.0.wallet_id', $walletId)
            ->assertJsonPath('data.results.2.record.entries.0.amount', -12.5);

        $this->assertEquals(-12.5, (float) Wallet::where('uuid', $walletId)->first()->transactionEntries()->sum('amount'));
    }

    public function test_replacing_entries_bumps_the_transaction_for_other_devices(): void
    {
        $wallet = Wallet::create(['user_id' => $this->user->id, 'name' => 'Card', 'currency_id' => $this->usd->id, 'type' => 'card']);
        $id = (string) Str::uuid();
        $entries = fn ($amount) => [['wallet_id' => $wallet->uuid, 'amount' => $amount, 'currency_id' => $this->usd->id]];
        $this->push(['entity' => 'transactions', 'type' => 'create', 'id' => $id, 'data' => ['type' => 'income', 'occurred_at' => '2026-10-30T12:00:00Z', 'entries' => $entries(100)]]);
        $cursor = $this->getJson('/api/v1/sync/pull')->json('data.cursor');

        $this->push(['entity' => 'transactions', 'type' => 'update', 'id' => $id, 'data' => ['entries' => $entries(150)]]);

        $this->getJson('/api/v1/sync/pull?cursor='.urlencode($cursor))
            ->assertJsonPath('data.changes.transactions.0.entries.0.amount', 150);
    }

    public function test_deleting_a_wallet_archives_it(): void
    {
        $wallet = Wallet::create(['user_id' => $this->user->id, 'name' => 'Card', 'currency_id' => $this->usd->id, 'type' => 'card']);

        $this->push(['entity' => 'wallets', 'type' => 'delete', 'id' => $wallet->uuid]);

        $this->assertFalse((bool) $wallet->fresh()->is_active);
    }

    public function test_shared_categories_are_pulled_but_cannot_be_changed(): void
    {
        $shared = TransactionCategory::create(['user_id' => null, 'title' => 'Salary', 'icon' => 'cash', 'color' => '22c55e', 'type' => 'income']);

        $this->getJson('/api/v1/sync/pull')
            ->assertJsonPath('data.changes.transaction_categories.0.id', $shared->uuid)
            ->assertJsonPath('data.changes.transaction_categories.0.is_system', true);
        $this->push(['entity' => 'transaction_categories', 'type' => 'update', 'id' => $shared->uuid, 'data' => ['title' => 'Mine']])
            ->assertJsonPath('data.results.0.code', 'forbidden');
    }

    public function test_a_second_sleep_entry_for_the_same_night_replaces_the_first(): void
    {
        $existing = SleepEntry::create(['user_id' => $this->user->id, 'date' => '2026-10-29', 'quality' => 2]);

        $this->push(['entity' => 'sleep_entries', 'type' => 'create', 'id' => (string) Str::uuid(), 'data' => ['date' => '2026-10-29', 'quality' => 4]])
            ->assertJsonPath('data.results.0.record.id', $existing->uuid)
            ->assertJsonPath('data.results.0.record.quality', 4);
        $this->assertSame(1, SleepEntry::count());
    }

    public function test_a_workout_syncs_with_its_exercises_sets_and_measurements(): void
    {
        $bench = Exercise::create(['user_id' => null, 'name' => 'Bench press', 'type' => 'strength']);
        $customId = (string) Str::uuid();
        $workoutId = (string) Str::uuid();

        $this->push(
            ['entity' => 'exercises', 'type' => 'create', 'id' => $customId, 'data' => ['name' => 'Kettlebell swing', 'type' => 'strength']],
            ['entity' => 'workout_sessions', 'type' => 'create', 'id' => $workoutId, 'data' => [
                'started_at' => '2026-10-30T07:00:00Z', 'ended_at' => '2026-10-30T08:00:00Z',
                'exercises' => [
                    ['exercise_id' => $bench->uuid, 'order_index' => 0, 'sets' => [['set_index' => 0, 'weight_kg' => 60, 'reps' => 8]]],
                    ['exercise_id' => $customId, 'order_index' => 1, 'sets' => [['set_index' => 0, 'weight_kg' => 16, 'reps' => 20]]],
                ],
                'completion' => ['body_weight_kg' => 80.5],
            ]],
        )
            ->assertJsonPath('data.results.1.status', 'applied')
            ->assertJsonPath('data.results.1.record.exercises.1.exercise_id', $customId)
            ->assertJsonPath('data.results.1.record.exercises.1.order_index', 1)
            ->assertJsonPath('data.results.1.record.exercises.0.sets.0.weight_kg', 60)
            ->assertJsonPath('data.results.1.record.completion.body_weight_kg', 80.5);
    }

    public function test_the_progress_photo_is_uploaded_after_the_workout_syncs(): void
    {
        Storage::fake('public');
        $workout = WorkoutSession::create(['user_id' => $this->user->id, 'started_at' => now()->subHour(), 'ended_at' => now()]);

        $this->post("/api/v1/gym/workouts/{$workout->id}/photo", [
            'photo' => UploadedFile::fake()->image('me.jpg'),
        ], ['Accept' => 'application/json'])->assertOk();

        Storage::disk('public')->assertExists($workout->fresh()->completion->photo_path);
    }

    public function test_completing_a_workout_through_the_rest_api_keeps_exercise_order(): void
    {
        $bench = Exercise::create(['user_id' => null, 'name' => 'Bench press', 'type' => 'strength']);

        $this->postJson('/api/v1/gym/workouts/complete', [
            'started_at' => '2026-10-30 07:00:00', 'ended_at' => '2026-10-30 08:00:00',
            'exercises' => [['exercise_id' => $bench->id, 'order_index' => 3, 'sets' => [['set_index' => 0, 'reps' => 5]]]],
        ])->assertCreated()->assertJsonPath('data.exercises.0.order_index', 3);
    }
}
