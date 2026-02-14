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
        Schema::create('habits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title', 120);
            $table->text('description')->nullable();
            $table->string('color', 7)->default('3b82f6'); // Hex color without #
            $table->string('icon')->nullable();
            $table->enum('status', ['active', 'archived'])->default('active');
            $table->enum('frequency', ['daily', 'weekly', 'monthly'])->default('daily');
            $table->json('frequency_days')->nullable(); // For weekly/monthly: [1,2,3] for Mon, Tue, Wed
            $table->time('reminder_time')->nullable();
            $table->unsignedInteger('goal_duration')->nullable(); // In days (e.g., 30, 60, 90)
            $table->json('tags')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index('user_id');
            $table->index(['user_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('habits');
    }
};
