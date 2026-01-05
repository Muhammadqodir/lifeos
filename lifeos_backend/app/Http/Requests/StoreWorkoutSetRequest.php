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
            'weight_kg' => ['required', 'numeric', 'min:0'],
            'reps' => ['required', 'integer', 'min:1', 'max:200'],
            'rpe' => ['nullable', 'integer', 'min:1', 'max:10'],
            'is_done' => ['sometimes', 'boolean'],
        ];
    }
}
