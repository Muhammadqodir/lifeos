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
        Schema::create('user_finance_settings', function (Blueprint $table) {
            $table->id();

            // One-to-one with users
            $table->foreignId('user_id')
                ->unique()
                ->constrained()
                ->cascadeOnDelete();

            // Base currency for the user's financial operations
            $table->foreignId('base_currency_id')
                ->constrained('currencies')
                ->restrictOnDelete(); // Prevent deleting a currency that's set as base

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_finance_settings');
    }
};
