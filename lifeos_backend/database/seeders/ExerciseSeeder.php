<?php

namespace Database\Seeders;

use App\Models\Exercise;
use Illuminate\Database\Seeder;

class ExerciseSeeder extends Seeder
{
    public function run(): void
    {
        $systemExercises = [
            ['name' => 'Bench Press', 'muscle_group' => 'Chest'],
            ['name' => 'Incline Bench Press', 'muscle_group' => 'Chest'],
            ['name' => 'Dumbbell Bench Press', 'muscle_group' => 'Chest'],
            ['name' => 'Push-ups', 'muscle_group' => 'Chest'],

            ['name' => 'Squat', 'muscle_group' => 'Legs'],
            ['name' => 'Front Squat', 'muscle_group' => 'Legs'],
            ['name' => 'Leg Press', 'muscle_group' => 'Legs'],
            ['name' => 'Romanian Deadlift', 'muscle_group' => 'Legs'],
            ['name' => 'Lunges', 'muscle_group' => 'Legs'],

            ['name' => 'Deadlift', 'muscle_group' => 'Back'],
            ['name' => 'Pull-up', 'muscle_group' => 'Back'],
            ['name' => 'Chin-up', 'muscle_group' => 'Back'],
            ['name' => 'Barbell Row', 'muscle_group' => 'Back'],
            ['name' => 'Dumbbell Row', 'muscle_group' => 'Back'],
            ['name' => 'Lat Pulldown', 'muscle_group' => 'Back'],

            ['name' => 'Shoulder Press', 'muscle_group' => 'Shoulders'],
            ['name' => 'Overhead Press', 'muscle_group' => 'Shoulders'],
            ['name' => 'Lateral Raise', 'muscle_group' => 'Shoulders'],
            ['name' => 'Front Raise', 'muscle_group' => 'Shoulders'],

            ['name' => 'Bicep Curl', 'muscle_group' => 'Arms'],
            ['name' => 'Hammer Curl', 'muscle_group' => 'Arms'],
            ['name' => 'Tricep Dip', 'muscle_group' => 'Arms'],
            ['name' => 'Tricep Extension', 'muscle_group' => 'Arms'],
            ['name' => 'Close Grip Bench Press', 'muscle_group' => 'Arms'],

            ['name' => 'Plank', 'muscle_group' => 'Core'],
            ['name' => 'Crunches', 'muscle_group' => 'Core'],
            ['name' => 'Russian Twist', 'muscle_group' => 'Core'],
            ['name' => 'Leg Raises', 'muscle_group' => 'Core'],
        ];

        foreach ($systemExercises as $exercise) {
            Exercise::firstOrCreate(
                [
                    'name' => $exercise['name'],
                    'user_id' => null, // System exercise
                ],
                [
                    'muscle_group' => $exercise['muscle_group'],
                ]
            );
        }
    }
}
