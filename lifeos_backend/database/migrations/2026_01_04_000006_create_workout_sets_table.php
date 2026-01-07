<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_sets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workout_exercise_id')->constrained('workout_exercises')->cascadeOnDelete();
            $table->integer('set_index');
            $table->decimal('weight_kg', 6, 2)->nullable();
            $table->unsignedSmallInteger('reps')->nullable();
            $table->unsignedTinyInteger('rpe')->nullable(); // 1-10
            $table->boolean('is_done')->default(true);
            $table->timestamps();

            $table->index(['workout_exercise_id', 'set_index']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_sets');
    }
};
