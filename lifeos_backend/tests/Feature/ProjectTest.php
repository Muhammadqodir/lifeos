<?php

namespace Tests\Feature;

use App\Models\Project;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProjectTest extends TestCase
{
    use RefreshDatabase;

    protected User $user;
    protected User $otherUser;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
        $this->otherUser = User::factory()->create();
    }

    public function test_user_can_list_their_projects(): void
    {
        Sanctum::actingAs($this->user);

        Project::factory()->count(3)->create(['user_id' => $this->user->id]);
        Project::factory()->count(2)->create(['user_id' => $this->otherUser->id]);

        $response = $this->getJson('/api/v1/projects');

        $response->assertOk()
            ->assertJsonCount(3, 'data');
    }

    public function test_user_can_search_projects_by_title(): void
    {
        Sanctum::actingAs($this->user);

        Project::factory()->create([
            'user_id' => $this->user->id,
            'title' => 'Work Project',
        ]);
        Project::factory()->create([
            'user_id' => $this->user->id,
            'title' => 'Personal Goals',
        ]);

        $response = $this->getJson('/api/v1/projects?search=Work');

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.title', 'Work Project');
    }

    public function test_user_can_create_project(): void
    {
        Sanctum::actingAs($this->user);

        $data = [
            'title' => 'New Project',
            'description' => 'Project description',
            'color' => '#FF5733',
            'icon' => 'icon.png',
            'tags' => ['work', 'important'],
        ];

        $response = $this->postJson('/api/v1/projects', $data);

        $response->assertCreated()
            ->assertJsonPath('data.title', 'New Project')
            ->assertJsonPath('data.color', '#FF5733')
            ->assertJsonPath('data.tags', ['work', 'important']);

        $this->assertDatabaseHas('projects', [
            'user_id' => $this->user->id,
            'title' => 'New Project',
            'color' => '#FF5733',
        ]);
    }

    public function test_project_title_must_be_unique_per_user(): void
    {
        Sanctum::actingAs($this->user);

        Project::factory()->create([
            'user_id' => $this->user->id,
            'title' => 'Existing Project',
        ]);

        $data = [
            'title' => 'Existing Project',
            'color' => '#FF5733',
        ];

        $response = $this->postJson('/api/v1/projects', $data);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['title']);
    }

    public function test_different_users_can_have_same_project_title(): void
    {
        Project::factory()->create([
            'user_id' => $this->otherUser->id,
            'title' => 'Shared Title',
        ]);

        Sanctum::actingAs($this->user);

        $data = [
            'title' => 'Shared Title',
            'color' => '#FF5733',
        ];

        $response = $this->postJson('/api/v1/projects', $data);

        $response->assertCreated();
    }

    public function test_project_validates_color_format(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/projects', [
            'title' => 'Test',
            'color' => 'invalid-color',
        ]);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['color']);
    }

    public function test_project_validates_title_length(): void
    {
        Sanctum::actingAs($this->user);

        // Too short
        $response = $this->postJson('/api/v1/projects', [
            'title' => 'AB',
            'color' => '#FF5733',
        ]);
        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['title']);

        // Too long
        $response = $this->postJson('/api/v1/projects', [
            'title' => str_repeat('A', 121),
            'color' => '#FF5733',
        ]);
        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['title']);
    }

    public function test_user_can_view_project_details(): void
    {
        Sanctum::actingAs($this->user);

        $project = Project::factory()->create(['user_id' => $this->user->id]);

        $response = $this->getJson("/api/v1/projects/{$project->id}");

        $response->assertOk()
            ->assertJsonPath('data.id', $project->id)
            ->assertJsonPath('data.title', $project->title);
    }

    public function test_user_cannot_view_other_users_project(): void
    {
        Sanctum::actingAs($this->user);

        $project = Project::factory()->create(['user_id' => $this->otherUser->id]);

        $response = $this->getJson("/api/v1/projects/{$project->id}");

        $response->assertForbidden();
    }

    public function test_user_can_update_project(): void
    {
        Sanctum::actingAs($this->user);

        $project = Project::factory()->create(['user_id' => $this->user->id]);

        $response = $this->putJson("/api/v1/projects/{$project->id}", [
            'title' => 'Updated Title',
            'color' => '#00FF00',
        ]);

        $response->assertOk()
            ->assertJsonPath('data.title', 'Updated Title')
            ->assertJsonPath('data.color', '#00FF00');

        $this->assertDatabaseHas('projects', [
            'id' => $project->id,
            'title' => 'Updated Title',
        ]);
    }

    public function test_user_cannot_update_other_users_project(): void
    {
        Sanctum::actingAs($this->user);

        $project = Project::factory()->create(['user_id' => $this->otherUser->id]);

        $response = $this->putJson("/api/v1/projects/{$project->id}", [
            'title' => 'Hacked Title',
        ]);

        $response->assertForbidden();
    }

    public function test_user_can_delete_project(): void
    {
        Sanctum::actingAs($this->user);

        $project = Project::factory()->create(['user_id' => $this->user->id]);

        $response = $this->deleteJson("/api/v1/projects/{$project->id}");

        $response->assertOk();

        $this->assertSoftDeleted('projects', [
            'id' => $project->id,
        ]);
    }

    public function test_user_cannot_delete_other_users_project(): void
    {
        Sanctum::actingAs($this->user);

        $project = Project::factory()->create(['user_id' => $this->otherUser->id]);

        $response = $this->deleteJson("/api/v1/projects/{$project->id}");

        $response->assertForbidden();
    }

    public function test_tags_are_normalized_on_save(): void
    {
        Sanctum::actingAs($this->user);

        $response = $this->postJson('/api/v1/projects', [
            'title' => 'Test Project',
            'color' => '#FF5733',
            'tags' => ['  Work  ', 'IMPORTANT', 'urgent  '],
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.tags', ['work', 'important', 'urgent']);
    }

    public function test_unauthenticated_user_cannot_access_projects(): void
    {
        $response = $this->getJson('/api/v1/projects');

        $response->assertUnauthorized();
    }
}
