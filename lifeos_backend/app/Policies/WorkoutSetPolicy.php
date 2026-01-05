<?php

namespace App\Policies;

use App\Models\WorkoutSet;
use App\Models\User;

class WorkoutSetPolicy
{
    public function update(User $user, WorkoutSet $workoutSet): bool
    {
        return $user->id === $workoutSet->workoutExercise->session->user_id;
    }

    public function delete(User $user, WorkoutSet $workoutSet): bool
    {
        return $user->id === $workoutSet->workoutExercise->session->user_id;
    }
}
