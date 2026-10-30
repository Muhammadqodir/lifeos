<?php

namespace App\Exceptions;

use Symfony\Component\HttpKernel\Exception\HttpException;

/**
 * An expected API error with a machine-readable code.
 *
 * Rendered by {@see \App\Http\Responses\ApiErrorRenderer} as
 * `{"message": "...", "code": "..."}`.
 */
class ApiException extends HttpException
{
    public function __construct(
        int $status,
        string $message,
        public readonly string $errorCode,
    ) {
        parent::__construct($status, $message);
    }

    public static function badRequest(string $message, string $code = 'bad_request'): self
    {
        return new self(400, $message, $code);
    }

    public static function forbidden(string $message, string $code = 'forbidden'): self
    {
        return new self(403, $message, $code);
    }

    public static function conflict(string $message, string $code = 'conflict'): self
    {
        return new self(409, $message, $code);
    }

    public static function unprocessable(string $message, string $code = 'unprocessable'): self
    {
        return new self(422, $message, $code);
    }

    public static function upstream(string $message, string $code = 'upstream_failed'): self
    {
        return new self(502, $message, $code);
    }
}
