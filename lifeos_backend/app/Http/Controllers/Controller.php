<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

/**
 * Every successful API response is `{"data": ..., "meta": {...}}`
 * (`meta` only when there is some); deletes return 204 with no body.
 * Errors are rendered by {@see \App\Http\Responses\ApiErrorRenderer}.
 *
 * API resources already produce this shape, so return them directly and use
 * these helpers for everything else.
 */
abstract class Controller
{
    use AuthorizesRequests;

    protected function ok(mixed $data, array $meta = [], int $status = 200): JsonResponse
    {
        $body = ['data' => $data];
        if ($meta !== []) {
            $body['meta'] = $meta;
        }

        return response()->json($body, $status);
    }

    protected function created(mixed $data): JsonResponse
    {
        return $this->ok($data, status: 201);
    }

    protected function noContent(): Response
    {
        return response()->noContent();
    }
}
