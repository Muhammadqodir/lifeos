<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create a test user
        User::create([
            'first_name' => 'Muhammadqodir',
            'last_name' => 'Abduvoitov',
            'father_name' => 'Erkinjon ogli',
            'date_of_birth' => '2001-08-06',
            'email' => 'mqodir777@gmail.com',
            'password' => Hash::make('12345678'),
            'is_active' => true,
        ]);
    }
}
