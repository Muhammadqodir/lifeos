<?php

namespace Database\Seeders;

use App\Models\Currency;
use Illuminate\Database\Seeder;

class CurrencySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $currencies = [
            [
                'user_id' => null, // SYSTEM currency
                'code' => 'UZS',
                'name' => 'Uzbek Sum',
                'color' => '#3B82F6', // Soft Emerald
                'icon' => 'uzs',
                'is_active' => true,
            ],
            [
                'user_id' => null, // SYSTEM currency
                'code' => 'USD',
                'name' => 'US Dollar',
                'color' => '#06B6D4', // Soft Indigo
                'icon' => '$',
                'is_active' => true,
            ],
            [
                'user_id' => null, // SYSTEM currency
                'code' => 'RUB',
                'name' => 'Russian Ruble',
                'color' => '#F59E0B', // Soft Amber
                'icon' => '₽',
                'is_active' => true,
            ],
            [
                'user_id' => null, // SYSTEM currency
                'code' => 'EUR',
                'name' => 'Euro',
                'color' => '#8B5CF6', // Soft Purple
                'icon' => '€',
                'is_active' => true,
            ],
        ];

        foreach ($currencies as $currency) {
            Currency::create($currency);
        }
    }
}
