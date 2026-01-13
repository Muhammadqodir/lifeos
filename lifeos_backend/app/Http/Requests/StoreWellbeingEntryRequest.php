<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreWellbeingEntryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'date' => [
                'required',
                'date',
                'unique:wellbeing_entries,date,NULL,id,user_id,' . auth()->id(),
            ],
            'energy' => ['required', 'integer', 'min:1', 'max:5'],
            'stress' => ['required', 'integer', 'min:1', 'max:5'],
            'note' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'date.unique' => 'You already have a wellbeing entry for this date. Please choose a different date or edit the existing entry.',
        ];
    }
}
