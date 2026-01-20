<?php

namespace Tests\Feature;

use App\Models\Project;
use App\Models\Todo;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TodoTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected User $otherUser;
    protected Project $project;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
        $this->otherUser = User::factory()->create();
        $this->project = Project::factory()->create(['user_id' => $this->user->id]);
    }

    public function test_user_can_list_their_todos(): void
    {
        Sanctum::actingAs($this->user);

        Todo::factory()->count(3)->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
        ]);
        Todo::factory()->count(2)->create(['user_id' => $this->otherUser->id]);

        $response = $this->getJson('/api/v1/todos');

        $response->assertOk()
            ->assertJsonCount(3, 'data');
    }

    public function test_user_can_filter_todos_by_project(): void
    {
        Sanctum::actingAs($this->user);

        $project2 = Project::factory()->create(['user_id' => $this->user->id]);

        Todo::factory()->count(2)->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
        ]);
        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $project2->id,
        ]);

        $response = $this->getJson("/api/v1/todos?project_id={$this->project->id}");

        $response->assertOk()
            ->assertJsonCount(2, 'data');
    }

    public function test_user_can_filter_todos_by_status(): void
    {
        Sanctum::actingAs($this->user);

        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'status' => 'planned',
        ]);
        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'status' => 'done',
        ]);

        $response = $this->getJson('/api/v1/todos?status=planned');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.status', 'planned');
    }

    public function test_user_can_filter_todos_by_tag(): void
    {
        Sanctum::actingAs($this->user);

        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'tags' => ['urgent', 'work'],
        ]);
        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'tags' => ['personal'],
        ]);

        $response = $this->getJson('/api/v1/todos?tag=urgent');

        $response->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_user_can_filter_todos_by_planned_date_range(): void
    {
        Sanctum::actingAs($this->user);

        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'planned_date_time' => '2026-01-15 10:00:00',
        ]);
        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'planned_date_time' => '2026-01-20 10:00:00',
        ]);

        $response = $this->getJson('/api/v1/todos?planned_from=2026-01-18&planned_to=2026-01-22');

        $response->assertOk()
            ->assertJsonCount(1, 'data');
    }

    public function test_user_can_search_todos_by_title(): void
    {
        Sanctum::actingAs($this->user);

        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'title' => 'Fix bug in auth',
        ]);
        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'title' => 'Write documentation',
        ]);

        $response = $this->getJson('/api/v1/todos?search=bug');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Fix bug in auth');
    }

    public function test_user_can_order_todos_by_priority(): void
    {
        Sanctum::actingAs($this->user);

        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'title' => 'Low priority',
            'priority' => 'low',
        ]);
        Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'title' => 'High priority',
            'priority' => 'high',
        ]);

        $response = $this->getJson('/api/v1/todos?order_by=priority&order_direction=desc');

        $response->assertOk()
            ->assertJsonPath('data.0.priority', 'low');
    }

    public function test_user_can_create_todo(): void
    {
        Sanctum::actingAs($this->user);

        $data = [
            'project_id' => $this->project->id,
            'title' => 'New Task',
            'comment' => 'Task details',
            'status' => 'planned',
            'priority' => 'high',
            'urgency' => 'high',
            'energy' => 'medium',
            'time_spent_minutes' => 30,
            'planned_date_time' => '2026-01-20 10:00:00',
            'tags' => ['work', 'urgent'],
        ];

        $response = $this->postJson('/api/v1/todos', $data);

        $response->assertCreated()
            ->assertJsonPath('data.title', 'New Task')
            ->assertJsonPath('data.status', 'planned')
            ->assertJsonPath('data.priority', 'high');

        $this->assertDatabaseHas('todos', [
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'title' => 'New Task',
        ]);
    }

    public function test_todo_validates_enum_fields(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/todos', [
            'project_id' => $this->project->id,
            'title' => 'Test',
            'status' => 'invalid_status',
            'priority' => 'high',
            'urgency' => 'high',
            'energy' => 'medium',
        ]);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['status']);
    }

    public function test_user_cannot_create_todo_in_other_users_project(): void
    {
        Sanctum::actingAs($this->user);

        $otherProject = Project::factory()->create(['user_id' => $this->otherUser->id]);

        $response = $this->postJson('/api/v1/todos', [
            'project_id' => $otherProject->id,
            'title' => 'Unauthorized Task',
            'status' => 'planned',
            'priority' => 'high',
            'urgency' => 'high',
            'energy' => 'medium',
        ]);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['project_id']);
    }

    public function test_completed_at_is_set_automatically_when_status_is_done(): void
    {
        Sanctum::actingAs($this->user);

        $todo = Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'status' => 'planned',
            'completed_at' => null,
        ]);

        $response = $this->putJson("/api/v1/todos/{$todo->id}", [
            'status' => 'done',
        ]);

        $response->assertOk();

        $todo->refresh();
        $this->assertNotNull($todo->completed_at);
    }

    public function test_completed_at_is_cleared_when_status_is_not_done(): void
    {
        Sanctum::actingAs($this->user);

        $todo = Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'status' => 'done',
        ]);

        $this->assertNotNull($todo->completed_at);

        $response = $this->putJson("/api/v1/todos/{$todo->id}", [
            'status' => 'planned',
        ]);

        $response->assertOk();

        $todo->refresh();
        $this->assertNull($todo->completed_at);
    }

    public function test_user_can_update_todo_status_via_patch_endpoint(): void
    {
        Sanctum::actingAs($this->user);

        $todo = Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
            'status' => 'planned',
        ]);

        $response = $this->patchJson("/api/v1/todos/{$todo->id}/status", [
            'status' => 'in_progress',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.status', 'in_progress');

        $this->assertDatabaseHas('todos', [
            'id' => $todo->id,
            'status' => 'in_progress',
        ]);
    }

    public function test_user_can_view_todo_details(): void
    {
        Sanctum::actingAs($this->user);

        $todo = Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
        ]);

        $response = $this->getJson("/api/v1/todos/{$todo->id}");

        $response->assertOk()
            ->assertJsonPath('data.id', $todo->id)
            ->assertJsonPath('data.title', $todo->title);
    }

    public function test_user_cannot_view_other_users_todo(): void
    {
        Sanctum::actingAs($this->user);

        $todo = Todo::factory()->create(['user_id' => $this->otherUser->id]);

        $response = $this->getJson("/api/v1/todos/{$todo->id}");

        $response->assertForbidden();
    }

    public function test_user_can_update_todo(): void
    {
        Sanctum::actingAs($this->user);

        $todo = Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
        ]);

        $response = $this->putJson("/api/v1/todos/{$todo->id}", [
            'title' => 'Updated Task',
            'priority' => 'low',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.title', 'Updated Task')
            ->assertJsonPath('data.priority', 'low');
    }

    public function test_user_cannot_update_other_users_todo(): void
    {
        Sanctum::actingAs($this->user);

        $todo = Todo::factory()->create(['user_id' => $this->otherUser->id]);

        $response = $this->putJson("/api/v1/todos/{$todo->id}", [
            'title' => 'Hacked Task',
        ]);

        $response->assertForbidden();
    }

    public function test_user_can_delete_todo(): void
    {
        Sanctum::actingAs($this->user);

        $todo = Todo::factory()->create([
            'user_id' => $this->user->id,
            'project_id' => $this->project->id,
        ]);

        $response = $this->deleteJson("/api/v1/todos/{$todo->id}");

        $response->assertOk();

        $this->assertSoftDeleted('todos', [
            'id' => $todo->id,
        ]);
    }

    public function test_user_cannot_delete_other_users_todo(): void
    {
        Sanctum::actingAs($this->user);

        $todo = Todo::factory()->create(['user_id' => $this->otherUser->id]);

        $response = $this->deleteJson("/api/v1/todos/{$todo->id}");

        $response->assertForbidden();
    }

    public function test_tags_are_normalized_on_save(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/todos', [
            'project_id' => $this->project->id,
            'title' => 'Test Todo',
            'status' => 'planned',
            'priority' => 'high',
            'urgency' => 'high',
            'energy' => 'medium',
            'tags' => ['  Work  ', 'URGENT', 'important  '],
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.tags', ['work', 'urgent', 'important']);
    }

    public function test_unauthenticated_user_cannot_access_todos(): void
    {
        $response = $this->getJson('/api/v1/todos');

        $response->assertUnauthorized();
    }
}
