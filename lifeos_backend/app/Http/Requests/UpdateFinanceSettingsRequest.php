<?php

namespace App\Http\Requests;

use App\Models\Currency;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateFinanceSettingsRequest extends FormRequest
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
            'base_currency_id' => [
                'required',
                'integer',
                Rule::exists('currencies', 'id')->where(function ($query) {
                    // Only allow selecting from user's own currencies
                    $query->where('user_id', auth()->id());
                }),
            ],
        ];
    }

    /**
     * Get custom error messages.
     */
    public function messages(): array
    {
        return [
            'base_currency_id.exists' => 'The selected base currency must be one of your own currencies.',
        ];
    }
}
