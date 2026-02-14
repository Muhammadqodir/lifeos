<?php

namespace App\Http\Requests;

use App\Models\Habit;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreHabitRequest extends FormRequest
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
        \Log::info('=== STORE HABIT REQUEST ===');
        \Log::info('Raw input:', $this->all());

        return [
            'title' => 'required|string|min:3|max:120',
            'description' => 'nullable|string|max:1000',
            'color' => 'nullable|string|regex:/^[0-9A-Fa-f]{6}$/',
            'icon' => 'nullable|string|max:100',
            'status' => ['nullable', Rule::in(Habit::getAllowedStatuses())],
            'frequency' => ['required', Rule::in(Habit::getAllowedFrequencies())],
            'frequency_days' => 'nullable|array',
            'frequency_days.*' => 'integer|min:0|max:6',
            'reminder_time' => 'nullable|date_format:H:i',
            'goal_duration' => 'nullable|integer|min:1|max:365',
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'title.required' => 'The habit title is required.',
            'title.min' => 'The habit title must be at least 3 characters.',
            'title.max' => 'The habit title must not exceed 120 characters.',
            'frequency.required' => 'The frequency is required.',
            'frequency.in' => 'The selected frequency is invalid.',
            'color.regex' => 'The color must be a valid hex color code without the # symbol.',
            'reminder_time.date_format' => 'The reminder time must be in HH:MM format.',
        ];
    }
}
