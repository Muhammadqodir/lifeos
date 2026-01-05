<?php

namespace App\Policies;

use App\Models\WellbeingEntry;
use App\Models\User;

class WellbeingEntryPolicy
{
    public function view(User $user, WellbeingEntry $wellbeingEntry): bool
    {
        return $user->id === $wellbeingEntry->user_id;
    }

    public function update(User $user, WellbeingEntry $wellbeingEntry): bool
    {
        return $user->id === $wellbeingEntry->user_id;
    }

    public function delete(User $user, WellbeingEntry $wellbeingEntry): bool
    {
        return $user->id === $wellbeingEntry->user_id;
    }
}
