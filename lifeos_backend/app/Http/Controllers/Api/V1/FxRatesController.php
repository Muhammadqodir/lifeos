<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\FxRates\FxRateService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class FxRatesController extends Controller
{
    public function __construct(
        private readonly FxRateService $fxRateService
    ) {
    }

    /**
     * Get exchange rates for specified currencies.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function index(Request $request): JsonResponse
    {
        // Validate request
        $validated = $request->validate([
            'origin' => ['required', 'string'],
            'target' => ['required', 'string'],
        ]);

        // Parse comma-separated targets
        $targets = array_filter(
            array_map('trim', explode(',', $validated['target'])),
            fn($t) => !empty($t)
        );

        if (empty($targets)) {
            return response()->json([
                'message' => 'The target field must contain at least one currency code.',
                'errors' => [
                    'target' => ['The target field must contain at least one currency code.']
                ]
            ], 422);
        }

        try {
            $result = $this->fxRateService->getRates(
                $validated['origin'],
                $targets
            );

            return response()->json([
                'data' => $result->toArray(),
                'meta' => [
                    'source' => $result->source,
                ]
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'The given data was invalid.',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to fetch exchange rates.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
