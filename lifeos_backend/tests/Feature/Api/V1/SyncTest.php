<?php

namespace Tests\Feature\Api\V1;

use App\Models\Habit;
use App\Models\HabitEntry;
use App\Models\Project;
use App\Models\Todo;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SyncTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
        Sanctum::actingAs($this->user);
    }

    private function op(string $entity, string $type, string $id, array $data = []): array
    {
        return ['op_id' => (string) Str::uuid(), 'entity' => $entity, 'type' => $type, 'id' => $id, 'data' => $data];
    }

    private function push(array ...$ops)
    {
        return $this->postJson('/api/v1/sync/push', ['ops' => $ops])->assertOk();
    }

    private function todoData(string $projectId, array $overrides = []): array
    {
        return [
            'project_id' => $projectId,
            'title' => 'Water the plants',
            'priority' => 'middle',
            'urgency' => 'low',
            'energy' => 'easy',
            ...$overrides,
        ];
    }

    public function test_first_pull_returns_everything_with_uuids(): void
    {
        $project = Project::factory()->create(['user_id' => $this->user->id]);
        Todo::factory()->create(['user_id' => $this->user->id, 'project_id' => $project->id]);
        Project::factory()->create(['user_id' => User::factory()->create()->id]);

        $response = $this->getJson('/api/v1/sync/pull')->assertOk();

        $response->assertJsonPath('data.full', true)
            ->assertJsonCount(1, 'data.changes.projects')
            ->assertJsonPath('data.changes.projects.0.id', $project->uuid)
            ->assertJsonPath('data.changes.todos.0.project_id', $project->uuid)
            ->assertJsonStructure(['data' => ['cursor', 'deleted' => ['projects', 'todos', 'habits', 'habit_entries']]]);
    }

    public function test_records_created_offline_reference_each_other_by_uuid(): void
    {
        $projectId = (string) Str::uuid();
        $todoId = (string) Str::uuid();

        $response = $this->push(
            $this->op('projects', 'create', $projectId, ['title' => 'Garden', 'color' => '22c55e']),
            $this->op('todos', 'create', $todoId, $this->todoData($projectId, ['planned_date' => '2026-03-10'])),
        );

        $response->assertJsonPath('data.results.0.status', 'applied')
            ->assertJsonPath('data.results.1.status', 'applied')
            ->assertJsonPath('data.results.1.record.id', $todoId)
            ->assertJsonPath('data.results.1.record.status', 'planned');
        $this->assertSame(Project::where('uuid', $projectId)->value('id'), Todo::where('uuid', $todoId)->value('project_id'));
    }

    public function test_a_retried_operation_is_not_applied_twice(): void
    {
        $project = Project::factory()->create(['user_id' => $this->user->id, 'title' => 'Garden']);
        $op = $this->op('projects', 'update', $project->uuid, ['title' => 'Garden v2']);

        $this->push($op);
        $project->update(['title' => 'Renamed elsewhere']);
        $this->push($op)->assertJsonPath('data.results.0.status', 'applied');

        $this->assertSame('Renamed elsewhere', $project->fresh()->title);
    }

    public function test_updates_only_touch_the_fields_sent(): void
    {
        $project = Project::factory()->create(['user_id' => $this->user->id]);
        $todo = Todo::factory()->create(['user_id' => $this->user->id, 'project_id' => $project->id, 'title' => 'Original']);

        $this->push($this->op('todos', 'update', $todo->uuid, ['status' => 'done']))
            ->assertJsonPath('data.results.0.record.title', 'Original')
            ->assertJsonPath('data.results.0.record.status', 'done');

        $this->assertNotNull($todo->fresh()->completed_at);
    }

    public function test_deletes_reach_other_devices_as_tombstones(): void
    {
        $project = Project::factory()->create(['user_id' => $this->user->id]);
        $todo = Todo::factory()->create(['user_id' => $this->user->id, 'project_id' => $project->id]);
        $cursor = $this->getJson('/api/v1/sync/pull')->json('data.cursor');

        // Deleting the project takes its todo with it.
        $this->push($this->op('projects', 'delete', $project->uuid));

        $this->getJson('/api/v1/sync/pull?cursor='.urlencode($cursor))
            ->assertJsonPath('data.full', false)
            ->assertJsonPath('data.deleted.projects', [$project->uuid])
            ->assertJsonPath('data.deleted.todos', [$todo->uuid]);
        $this->assertSoftDeleted($todo);
    }

    public function test_editing_a_deleted_record_is_rejected_as_gone(): void
    {
        $project = Project::factory()->create(['user_id' => $this->user->id]);
        $project->delete();

        $this->push($this->op('projects', 'update', $project->uuid, ['title' => 'Back again']))
            ->assertJsonPath('data.results.0.status', 'rejected')
            ->assertJsonPath('data.results.0.code', 'gone')
            ->assertJsonPath('data.results.0.record', null);
    }

    public function test_invalid_data_is_rejected_with_the_current_record(): void
    {
        $project = Project::factory()->create(['user_id' => $this->user->id, 'title' => 'Garden']);

        $this->push($this->op('projects', 'update', $project->uuid, ['title' => 'x']))
            ->assertJsonPath('data.results.0.code', 'validation_failed')
            ->assertJsonStructure(['data' => ['results' => [['errors' => ['title']]]]])
            ->assertJsonPath('data.results.0.record.title', 'Garden');
    }

    public function test_one_bad_operation_does_not_block_the_rest(): void
    {
        $projectId = (string) Str::uuid();

        $this->push(
            $this->op('todos', 'create', (string) Str::uuid(), $this->todoData((string) Str::uuid())),
            $this->op('projects', 'create', $projectId, ['title' => 'Garden', 'color' => '22c55e']),
        )
            ->assertJsonPath('data.results.0.status', 'rejected')
            ->assertJsonPath('data.results.1.status', 'applied');
    }

    public function test_someone_elses_record_cannot_be_changed(): void
    {
        $project = Project::factory()->create(['user_id' => User::factory()->create()->id, 'title' => 'Theirs']);

        $this->push($this->op('projects', 'update', $project->uuid, ['title' => 'Mine now']))
            ->assertJsonPath('data.results.0.code', 'forbidden')
            ->assertJsonPath('data.results.0.record', null);
        $this->assertSame('Theirs', $project->fresh()->title);
    }

    public function test_two_devices_completing_a_habit_on_the_same_day_share_one_entry(): void
    {
        $habit = Habit::create(['user_id' => $this->user->id, 'title' => 'Read', 'frequency' => 'daily']);
        $existing = HabitEntry::create([
            'habit_id' => $habit->id, 'user_id' => $this->user->id,
            'date' => '2026-03-10', 'completed_at' => '2026-03-10 07:00:00',
        ]);

        $this->push($this->op('habit_entries', 'create', (string) Str::uuid(), [
            'habit_id' => $habit->uuid, 'date' => '2026-03-10',
        ]))
            ->assertJsonPath('data.results.0.status', 'applied')
            ->assertJsonPath('data.results.0.record.id', $existing->uuid);

        $this->assertSame(1, HabitEntry::count());
    }

    public function test_unchecking_a_habit_hard_deletes_the_entry_and_leaves_a_tombstone(): void
    {
        $habit = Habit::create(['user_id' => $this->user->id, 'title' => 'Read', 'frequency' => 'daily']);
        $entryId = (string) Str::uuid();
        $this->push($this->op('habit_entries', 'create', $entryId, ['habit_id' => $habit->uuid, 'date' => Carbon::today()->toDateString()]));
        $cursor = $this->getJson('/api/v1/sync/pull')->json('data.cursor');

        $this->push($this->op('habit_entries', 'delete', $entryId));
        $this->getJson('/api/v1/sync/pull?cursor='.urlencode($cursor))
            ->assertJsonPath('data.deleted.habit_entries', [$entryId]);

        // Checking it again with the same id brings it back.
        $this->push($this->op('habit_entries', 'create', $entryId, ['habit_id' => $habit->uuid, 'date' => Carbon::today()->toDateString()]))
            ->assertJsonPath('data.results.0.status', 'applied');
        $this->getJson('/api/v1/sync/pull?cursor='.urlencode($cursor))
            ->assertJsonPath('data.deleted.habit_entries', [])
            ->assertJsonPath('data.changes.habit_entries.0.id', $entryId);
    }

    public function test_changes_made_through_the_rest_api_show_up_in_the_next_pull(): void
    {
        $cursor = $this->getJson('/api/v1/sync/pull')->json('data.cursor');

        $this->postJson('/api/v1/projects', ['title' => 'Made on the web', 'color' => '22c55e'])->assertCreated();

        $this->getJson('/api/v1/sync/pull?cursor='.urlencode($cursor))
            ->assertJsonPath('data.changes.projects.0.title', 'Made on the web');
    }

    public function test_malformed_pushes_fail_as_a_whole(): void
    {
        $this->postJson('/api/v1/sync/push', ['ops' => [['entity' => 'wallets', 'type' => 'create']]])
            ->assertStatus(422)
            ->assertJsonPath('code', 'validation_failed');
    }
}
