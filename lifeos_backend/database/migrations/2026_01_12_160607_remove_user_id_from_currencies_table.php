<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Check if user_id column exists before trying to drop it
        if (!Schema::hasColumn('currencies', 'user_id')) {
            return; // Already removed, nothing to do
        }

        // First, delete all user-owned currencies (keep only system currencies)
        DB::table('currencies')->whereNotNull('user_id')->delete();

        Schema::table('currencies', function (Blueprint $table) {
            // Drop foreign key first
            $table->dropForeign(['user_id']);

            // Drop composite unique index
            $table->dropUnique(['user_id', 'code']);

            // Drop columns
            $table->dropColumn(['user_id', 'is_active']);

            // Restore original unique constraint on code
            $table->unique('code');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('currencies', function (Blueprint $table) {
            // Drop the unique constraint on 'code' alone
            $table->dropUnique(['code']);

            // Add user_id column (nullable = system currency)
            $table->foreignId('user_id')
                ->nullable()
                ->after('id')
                ->constrained()
                ->cascadeOnDelete();

            // Add is_active flag for user-owned currencies
            $table->boolean('is_active')
                ->default(true)
                ->after('icon');

            // Add unique constraint on (user_id, code)
            $table->unique(['user_id', 'code']);
        });
    }
};
