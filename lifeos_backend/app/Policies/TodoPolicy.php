<?php

namespace App\Policies;

use App\Models\Todo;
use App\Models\User;

class TodoPolicy
{
    /**
     * Determine whether the user can view any todos.
     */
    public function viewAny(User $user): bool
    {
        return true; // Users can view their own todos
    }

    /**
     * Determine whether the user can view the todo.
     */
    public function view(User $user, Todo $todo): bool
    {
        return $user->id === $todo->user_id;
    }

    /**
     * Determine whether the user can create todos.
     */
    public function create(User $user): bool
    {
        return true; // Any authenticated user can create todos
    }

    /**
     * Determine whether the user can update the todo.
     */
    public function update(User $user, Todo $todo): bool
    {
        return $user->id === $todo->user_id;
    }

    /**
     * Determine whether the user can delete the todo.
     */
    public function delete(User $user, Todo $todo): bool
    {
        return $user->id === $todo->user_id;
    }

    /**
     * Determine whether the user can restore the todo.
     */
    public function restore(User $user, Todo $todo): bool
    {
        return $user->id === $todo->user_id;
    }

    /**
     * Determine whether the user can permanently delete the todo.
     */
    public function forceDelete(User $user, Todo $todo): bool
    {
        return $user->id === $todo->user_id;
    }
}
