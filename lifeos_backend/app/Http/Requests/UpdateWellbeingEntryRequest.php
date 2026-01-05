<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateWellbeingEntryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'date' => ['sometimes', 'date'],
            'energy' => ['sometimes', 'integer', 'min:1', 'max:5'],
            'stress' => ['sometimes', 'integer', 'min:1', 'max:5'],
            'note' => ['nullable', 'string'],
        ];
    }
}
