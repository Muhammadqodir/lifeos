<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_exercises', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained('workout_sessions')->cascadeOnDelete();
            $table->foreignId('exercise_id')->constrained('exercises');
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->index(['session_id', 'sort_order']);
            $table->index('exercise_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_exercises');
    }
};
