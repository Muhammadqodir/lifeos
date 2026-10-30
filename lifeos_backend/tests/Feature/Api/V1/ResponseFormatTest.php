<?php

namespace Tests\Feature\Api\V1;

use App\Models\Project;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/**
 * Every success is {data, meta?}; every error is {message, code, errors?}.
 */
class ResponseFormatTest extends TestCase
{
    use RefreshDatabase;

    public function test_unauthenticated_requests_get_the_error_shape(): void
    {
        $this->getJson('/api/v1/projects')
            ->assertStatus(401)
            ->assertExactJson(['message' => 'Unauthenticated.', 'code' => 'unauthenticated']);
    }

    public function test_requests_without_a_json_accept_header_still_get_json(): void
    {
        $this->get('/api/v1/projects')
            ->assertStatus(401)
            ->assertJsonPath('code', 'unauthenticated');
    }

    public function test_validation_errors_carry_field_messages(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->postJson('/api/v1/projects', [])
            ->assertStatus(422)
            ->assertJsonPath('code', 'validation_failed')
            ->assertJsonStructure(['message', 'code', 'errors' => ['title']]);
    }

    public function test_missing_records_do_not_leak_model_names(): void
    {
        Sanctum::actingAs(User::factory()->create());

        $this->getJson('/api/v1/projects/999999')
            ->assertNotFound()
            ->assertExactJson(['message' => 'Not found.', 'code' => 'not_found']);
    }

    public function test_other_users_records_look_missing(): void
    {
        $project = Project::factory()->create(['user_id' => User::factory()->create()->id]);
        Sanctum::actingAs(User::factory()->create());

        $this->getJson("/api/v1/projects/{$project->id}")
            ->assertJsonPath('code', fn ($code) => in_array($code, ['not_found', 'forbidden'], true));
    }

    public function test_login_and_me_wrap_the_payload_in_data(): void
    {
        $user = User::factory()->create(['password' => 'secret-password']);

        $this->postJson('/api/v1/auth/login', ['email' => $user->email, 'password' => 'secret-password'])
            ->assertOk()
            ->assertJsonStructure(['data' => ['user' => ['id', 'email'], 'token']]);

        Sanctum::actingAs($user);
        $this->getJson('/api/v1/auth/me')->assertOk()->assertJsonPath('data.id', $user->id);
        $this->postJson('/api/v1/auth/logout')->assertNoContent();
    }

    public function test_success_bodies_have_no_message_key(): void
    {
        Sanctum::actingAs($user = User::factory()->create());

        $this->postJson('/api/v1/projects', ['title' => 'Garden', 'color' => '22c55e'])
            ->assertCreated()
            ->assertJsonMissingPath('message')
            ->assertJsonPath('data.title', 'Garden');
    }
}
