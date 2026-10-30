<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Wallet;
use Illuminate\Auth\Access\Response;

class WalletPolicy
{
    /**
     * Other users' wallets answer 404 rather than 403, so their IDs can't
     * be probed.
     */
    private function owns(User $user, Wallet $wallet): Response
    {
        return (int) $user->id === (int) $wallet->user_id
            ? Response::allow()
            : Response::denyAsNotFound();
    }

    public function view(User $user, Wallet $wallet): Response
    {
        return $this->owns($user, $wallet);
    }

    public function update(User $user, Wallet $wallet): Response
    {
        return $this->owns($user, $wallet);
    }

    public function delete(User $user, Wallet $wallet): Response
    {
        return $this->owns($user, $wallet);
    }
}
