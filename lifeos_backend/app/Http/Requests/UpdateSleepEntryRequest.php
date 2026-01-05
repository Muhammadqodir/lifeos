<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSleepEntryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'date' => ['sometimes', 'date'],
            'sleep_start' => ['nullable', 'date'],
            'sleep_end' => ['nullable', 'date', 'after:sleep_start'],
            'quality' => ['sometimes', 'integer', 'min:1', 'max:5'],
            'note' => ['nullable', 'string'],
        ];
    }
}
