<?php

namespace App\Policies;

use App\Models\WorkoutExercise;
use App\Models\User;

class WorkoutExercisePolicy
{
    public function delete(User $user, WorkoutExercise $workoutExercise): bool
    {
        return $user->id === $workoutExercise->session->user_id;
    }
}
