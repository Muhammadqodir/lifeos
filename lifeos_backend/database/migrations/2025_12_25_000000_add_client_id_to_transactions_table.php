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
        Schema::table('transactions', function (Blueprint $table) {
            // Add client_id column after user_id for offline sync idempotency
            $table->string('client_id', 36)->nullable()->after('user_id');

            // Add unique constraint to prevent duplicate transactions from retries
            // This ensures (user_id, client_id) combination is unique
            $table->unique(['user_id', 'client_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            // Drop unique constraint first
            $table->dropUnique(['user_id', 'client_id']);

            // Drop client_id column
            $table->dropColumn('client_id');
        });
    }
};
