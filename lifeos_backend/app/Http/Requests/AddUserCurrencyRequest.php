<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AddUserCurrencyRequest extends FormRequest
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
     */
    public function rules(): array
    {
        return [
            'currency_id' => [
                'required',
                'integer',
                'exists:currencies,id',
                // Ensure user doesn't already have this currency
                Rule::unique('currency_user', 'currency_id')
                    ->where('user_id', auth()->id()),
            ],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'currency_id.unique' => 'You already have this currency in your list.',
            'currency_id.exists' => 'The selected currency does not exist.',
        ];
    }
}
