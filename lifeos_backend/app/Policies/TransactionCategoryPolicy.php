<?php

namespace App\Policies;

use App\Models\TransactionCategory;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class TransactionCategoryPolicy
{
    /**
     * System categories (no user_id) are shared and read-only.
     */
    private function owns(User $user, TransactionCategory $category, string $verb): Response
    {
        return $category->user_id !== null && (int) $user->id === (int) $category->user_id
            ? Response::allow()
            : Response::deny("Cannot {$verb} system categories or categories belonging to other users.");
    }

    public function update(User $user, TransactionCategory $category): Response
    {
        return $this->owns($user, $category, 'update');
    }

    public function delete(User $user, TransactionCategory $category): Response
    {
        return $this->owns($user, $category, 'delete');
    }
}
