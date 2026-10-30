<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

/**
 * Local-first sync (see docs/local-first.md):
 * - a client-generated `uuid` on every synced table, which is the record's
 *   id in the sync API (existing rows get one here);
 * - `sync_tombstones`, so clients learn about deletions, including hard
 *   deletes of habit entries;
 * - `sync_operations`, so a retried push is not applied twice.
 */
return new class extends Migration
{
    private const TABLES = ['projects', 'todos', 'habits', 'habit_entries'];

    public function up(): void
    {
        foreach (self::TABLES as $name) {
            Schema::table($name, function (Blueprint $table) {
                $table->uuid('uuid')->nullable()->after('id');
                $table->index(['user_id', 'updated_at']);
            });

            DB::table($name)->whereNull('uuid')->orderBy('id')->chunkById(500, function ($rows) use ($name) {
                foreach ($rows as $row) {
                    DB::table($name)->where('id', $row->id)->update(['uuid' => (string) Str::uuid()]);
                }
            });

            Schema::table($name, function (Blueprint $table) {
                $table->unique('uuid');
            });
        }

        Schema::create('sync_tombstones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('entity', 40);
            $table->uuid('uuid');
            $table->timestamp('deleted_at');

            $table->unique(['entity', 'uuid']);
            $table->index(['user_id', 'deleted_at']);
        });

        Schema::create('sync_operations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->uuid('op_id');
            $table->json('result');
            $table->timestamp('created_at');

            $table->unique(['user_id', 'op_id']);
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_operations');
        Schema::dropIfExists('sync_tombstones');

        foreach (self::TABLES as $name) {
            Schema::table($name, function (Blueprint $table) {
                $table->dropUnique(['uuid']);
                $table->dropIndex(['user_id', 'updated_at']);
                $table->dropColumn('uuid');
            });
        }
    }
};
