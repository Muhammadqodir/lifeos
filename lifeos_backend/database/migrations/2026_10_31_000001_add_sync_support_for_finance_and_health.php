<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

/**
 * Finance and Health join local-first sync (docs/local-first.md): every
 * synced table gets a uuid, the record's id in the sync API.
 * Transactions reuse their existing client_id where they have one.
 */
return new class extends Migration
{
    private const TABLES = [
        'wallets', 'transaction_categories', 'transactions',
        'sleep_entries', 'wellbeing_entries', 'exercises', 'workout_sessions',
    ];

    public function up(): void
    {
        foreach (self::TABLES as $name) {
            Schema::table($name, function (Blueprint $table) {
                $table->uuid('uuid')->nullable()->after('id');
                $table->index(['user_id', 'updated_at']);
            });

            DB::table($name)->whereNull('uuid')->orderBy('id')->chunkById(500, function ($rows) use ($name) {
                foreach ($rows as $row) {
                    $uuid = $name === 'transactions' && Str::isUuid($row->client_id ?? '')
                        ? $row->client_id
                        : (string) Str::uuid();
                    DB::table($name)->where('id', $row->id)->update(['uuid' => $uuid]);
                }
            });

            Schema::table($name, function (Blueprint $table) {
                $table->unique('uuid');
            });
        }
    }

    public function down(): void
    {
        foreach (self::TABLES as $name) {
            Schema::table($name, function (Blueprint $table) {
                $table->dropUnique(['uuid']);
                $table->dropIndex(['user_id', 'updated_at']);
                $table->dropColumn('uuid');
            });
        }
    }
};
