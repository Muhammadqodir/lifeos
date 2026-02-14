<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreHabitEntryRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'date' => 'required|date|date_format:Y-m-d|before_or_equal:today',
            'completed_at' => 'nullable|date|date_format:Y-m-d H:i:s',
            'note' => 'nullable|string|max:500',
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'date.required' => 'The date is required.',
            'date.date_format' => 'The date must be in Y-m-d format.',
            'date.before_or_equal' => 'The date cannot be in the future.',
            'completed_at.date_format' => 'The completed at time must be in Y-m-d H:i:s format.',
        ];
    }
}
