<?php

namespace App\Policies;

use App\Models\Transaction;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class TransactionPolicy
{
    /**
     * Other users' transactions answer 404 rather than 403, so their IDs
     * can't be probed.
     */
    private function owns(User $user, Transaction $transaction): Response
    {
        return (int) $user->id === (int) $transaction->user_id
            ? Response::allow()
            : Response::denyAsNotFound();
    }

    public function view(User $user, Transaction $transaction): Response
    {
        return $this->owns($user, $transaction);
    }

    public function update(User $user, Transaction $transaction): Response
    {
        return $this->owns($user, $transaction);
    }

    public function delete(User $user, Transaction $transaction): Response
    {
        return $this->owns($user, $transaction);
    }
}
