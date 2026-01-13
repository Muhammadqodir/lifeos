<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSleepEntryRequest extends FormRequest
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
                'unique:sleep_entries,date,NULL,id,user_id,' . auth()->id(),
            ],
            'sleep_start' => ['nullable', 'date'],
            'sleep_end' => ['nullable', 'date', 'after:sleep_start'],
            'quality' => ['required', 'integer', 'min:1', 'max:5'],
            'note' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'date.unique' => 'You already have a sleep entry for this date. Please choose a different date or edit the existing entry.',
        ];
    }
}
