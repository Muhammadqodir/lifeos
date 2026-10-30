<?php

namespace App\Sync;

use RuntimeException;

/** An operation the server refuses; reported per operation, not per request. */
class SyncRejection extends RuntimeException
{
    public function __construct(
        public readonly string $errorCode,
        string $message,
        public readonly ?array $errors = null,
    ) {
        parent::__construct($message);
    }
}
