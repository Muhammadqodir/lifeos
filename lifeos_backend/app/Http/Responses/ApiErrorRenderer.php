<?php

namespace App\Http\Responses;

use App\Exceptions\ApiException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Throwable;

/**
 * Renders every API error as one shape:
 *
 *     {"message": "Human readable", "code": "machine_code", "errors": {...}}
 *
 * `errors` is only present for validation failures (field => messages).
 */
final class ApiErrorRenderer
{
    private const CODES = [
        400 => 'bad_request',
        401 => 'unauthenticated',
        403 => 'forbidden',
        404 => 'not_found',
        405 => 'method_not_allowed',
        409 => 'conflict',
        410 => 'gone',
        413 => 'payload_too_large',
        422 => 'unprocessable',
        429 => 'too_many_requests',
        502 => 'upstream_failed',
        503 => 'unavailable',
    ];

    private const MESSAGES = [
        401 => 'Unauthenticated.',
        403 => 'This action is unauthorized.',
        404 => 'Not found.',
        405 => 'Method not allowed.',
        429 => 'Too many requests.',
        500 => 'Server error.',
    ];

    public static function render(Throwable $e): JsonResponse
    {
        if ($e instanceof ValidationException) {
            return self::json(422, $e->getMessage(), 'validation_failed', $e->errors());
        }

        if ($e instanceof AuthenticationException) {
            return self::json(401, self::MESSAGES[401], 'unauthenticated');
        }

        if ($e instanceof HttpExceptionInterface) {
            $status = $e->getStatusCode();
            $code = $e instanceof ApiException
                ? $e->errorCode
                : (self::CODES[$status] ?? 'http_error');

            // Route-model binding misses carry the model class name; don't
            // leak it.
            $message = $e->getPrevious() instanceof ModelNotFoundException
                ? self::MESSAGES[404]
                : ($e->getMessage() ?: (self::MESSAGES[$status] ?? 'Request failed.'));

            return self::json($status, $message, $code, headers: $e->getHeaders());
        }

        $message = config('app.debug') ? $e->getMessage() : self::MESSAGES[500];

        return self::json(500, $message, 'server_error');
    }

    private static function json(
        int $status,
        string $message,
        string $code,
        ?array $errors = null,
        array $headers = [],
    ): JsonResponse {
        $body = ['message' => $message, 'code' => $code];
        if ($errors !== null) {
            $body['errors'] = $errors;
        }

        return new JsonResponse($body, $status, $headers);
    }
}
