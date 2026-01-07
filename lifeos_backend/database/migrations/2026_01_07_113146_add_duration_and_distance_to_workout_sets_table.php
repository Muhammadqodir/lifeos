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
        Schema::table('workout_sets', function (Blueprint $table) {
            $table->unsignedInteger('duration_seconds')->nullable()->after('reps');
            $table->decimal('distance_meters', 10, 2)->nullable()->after('duration_seconds');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('workout_sets', function (Blueprint $table) {
            $table->dropColumn(['duration_seconds', 'distance_meters']);
        });
    }
};
