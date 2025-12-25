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
        Schema::table('currencies', function (Blueprint $table) {
            // Drop the old unique constraint on 'code' alone
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
            // This allows: system USD (user_id=NULL, code=USD) + user USD (user_id=1, code=USD)
            $table->unique(['user_id', 'code']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('currencies', function (Blueprint $table) {
            // Drop composite unique index
            $table->dropUnique(['user_id', 'code']);

            // Drop foreign key and columns
            $table->dropForeign(['user_id']);
            $table->dropColumn(['user_id', 'is_active']);

            // Restore original unique constraint on code
            $table->unique('code');
        });
    }
};
