<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('todos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            $table->string('title', 160);
            $table->text('comment')->nullable();

            // ENUM fields
            $table->enum('status', ['inbox', 'planned', 'in_progress', 'blocked', 'done'])->default('inbox');
            $table->enum('priority', ['low', 'middle', 'high'])->default('middle');
            $table->enum('urgency', ['low', 'middle', 'high'])->default('middle');
            $table->enum('energy', ['easy', 'medium', 'hard'])->default('medium');

            $table->unsignedInteger('time_spent_minutes')->nullable();
            $table->dateTime('planned_date_time')->nullable();
            $table->dateTime('completed_at')->nullable();
            $table->json('tags')->nullable();

            $table->timestamps();
            $table->softDeletes();

            // Indexes for filtering and ordering
            $table->index('user_id');
            $table->index('project_id');
            $table->index('status');
            $table->index('planned_date_time');
            $table->index('completed_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('todos');
    }
};
