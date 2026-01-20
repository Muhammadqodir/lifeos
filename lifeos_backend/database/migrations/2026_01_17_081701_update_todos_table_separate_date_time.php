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
        Schema::table('todos', function (Blueprint $table) {
            // Add new separate date and time columns
            $table->date('planned_date')->nullable()->after('energy');
            $table->time('planned_time')->nullable()->after('planned_date');

            // Drop the old combined column
            $table->dropColumn('planned_date_time');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('todos', function (Blueprint $table) {
            // Restore the combined column
            $table->dateTime('planned_date_time')->nullable()->after('energy');

            // Drop the separate columns
            $table->dropColumn(['planned_date', 'planned_time']);
        });
    }
};
