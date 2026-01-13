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
        Schema::create('workout_completions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workout_session_id')->constrained('workout_sessions')->cascadeOnDelete();
            $table->string('photo_path')->nullable();
            $table->decimal('body_weight_kg', 5, 2)->nullable();
            $table->decimal('height_cm', 5, 2)->nullable();
            $table->decimal('biceps_cm', 5, 2)->nullable();
            $table->decimal('chest_cm', 5, 2)->nullable();
            $table->decimal('waist_cm', 5, 2)->nullable();
            $table->decimal('thighs_cm', 5, 2)->nullable();
            $table->decimal('calfs_cm', 5, 2)->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index('workout_session_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('workout_completions');
    }
};
