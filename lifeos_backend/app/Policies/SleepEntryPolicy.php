<?php

namespace App\Policies;

use App\Models\SleepEntry;
use App\Models\User;

class SleepEntryPolicy
{
    public function view(User $user, SleepEntry $sleepEntry): bool
    {
        return $user->id === $sleepEntry->user_id;
    }

    public function update(User $user, SleepEntry $sleepEntry): bool
    {
        return $user->id === $sleepEntry->user_id;
    }

    public function delete(User $user, SleepEntry $sleepEntry): bool
    {
        return $user->id === $sleepEntry->user_id;
    }
}
