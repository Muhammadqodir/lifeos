<?php

namespace Database\Seeders;

use App\Models\TransactionCategory;
use Illuminate\Database\Seeder;

class TransactionCategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // System categories (user_id = null)
        $systemCategories = [
            // Income categories
            [
                'user_id' => null,
                'title' => 'Salary',
                'icon' => '💰',
                'color' => '#10B981', // Soft Emerald
                'type' => 'income',
            ],
            [
                'user_id' => null,
                'title' => 'Freelance',
                'icon' => '💼',
                'color' => '#6366F1', // Soft Indigo
                'type' => 'income',
            ],
            [
                'user_id' => null,
                'title' => 'Investment',
                'icon' => '📈',
                'color' => '#8B5CF6', // Soft Purple
                'type' => 'income',
            ],
            [
                'user_id' => null,
                'title' => 'Gift',
                'icon' => '🎁',
                'color' => '#EC4899', // Soft Pink
                'type' => 'income',
            ],
            [
                'user_id' => null,
                'title' => 'Other Income',
                'icon' => '💵',
                'color' => '#14B8A6', // Soft Teal
                'type' => 'income',
            ],

            // Expense categories
            [
                'user_id' => null,
                'title' => 'Food & Dining',
                'icon' => '🍔',
                'color' => '#F59E0B', // Soft Amber
                'type' => 'expense',
            ],
            [
                'user_id' => null,
                'title' => 'Transportation',
                'icon' => '🚗',
                'color' => '#3B82F6', // Soft Blue
                'type' => 'expense',
            ],
            [
                'user_id' => null,
                'title' => 'Shopping',
                'icon' => '🛍️',
                'color' => '#EC4899', // Soft Pink
                'type' => 'expense',
            ],
            [
                'user_id' => null,
                'title' => 'Entertainment',
                'icon' => '🎬',
                'color' => '#8B5CF6', // Soft Purple
                'type' => 'expense',
            ],
            [
                'user_id' => null,
                'title' => 'Bills & Utilities',
                'icon' => '📱',
                'color' => '#EF4444', // Soft Red
                'type' => 'expense',
            ],
            [
                'user_id' => null,
                'title' => 'Healthcare',
                'icon' => '⚕️',
                'color' => '#06B6D4', // Soft Cyan
                'type' => 'expense',
            ],
            [
                'user_id' => null,
                'title' => 'Education',
                'icon' => '📚',
                'color' => '#6366F1', // Soft Indigo
                'type' => 'expense',
            ],
            [
                'user_id' => null,
                'title' => 'Travel',
                'icon' => '✈️',
                'color' => '#14B8A6', // Soft Teal
                'type' => 'expense',
            ],
            [
                'user_id' => null,
                'title' => 'Housing',
                'icon' => '🏠',
                'color' => '#F97316', // Soft Orange
                'type' => 'expense',
            ],
            [
                'user_id' => null,
                'title' => 'Other Expense',
                'icon' => '💸',
                'color' => '#64748B', // Soft Slate
                'type' => 'expense',
            ],
        ];

        foreach ($systemCategories as $category) {
            TransactionCategory::create($category);
        }
    }
}
