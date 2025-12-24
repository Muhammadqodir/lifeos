<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Seed currencies
        $this->call(CurrencySeeder::class);

        // Seed transaction categories
        $this->call(TransactionCategorySeeder::class);

        // Seed users
        $this->call(UserSeeder::class);
    }
}
