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
        Schema::create('transaction_entries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('transaction_id')->constrained()->cascadeOnDelete();
            $table->foreignId('wallet_id')->constrained()->cascadeOnDelete();
            $table->decimal('amount', 18, 6);
            $table->foreignId('currency_id')->constrained()->cascadeOnDelete();
            $table->decimal('rate', 18, 8)->nullable();
            $table->string('note')->nullable();
            $table->timestamp('created_at')->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transaction_entries');
    }
};
