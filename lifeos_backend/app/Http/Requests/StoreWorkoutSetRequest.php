<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreWorkoutSetRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'set_index' => ['required', 'integer', 'min:0'],
            'weight_kg' => ['nullable', 'numeric', 'min:0'],
            'reps' => ['nullable', 'integer', 'min:1', 'max:500'],
            'duration_seconds' => ['nullable', 'integer', 'min:1'],
            'distance_meters' => ['nullable', 'numeric', 'min:0'],
            'rpe' => ['nullable', 'integer', 'min:1', 'max:10'],
            'is_done' => ['sometimes', 'boolean'],
        ];
    }
}
