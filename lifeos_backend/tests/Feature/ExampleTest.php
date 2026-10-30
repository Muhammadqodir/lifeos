<?php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        // The backend is API-only; the framework health route is the smoke check.
        $response = $this->get('/up');

        $response->assertStatus(200);
    }
}
