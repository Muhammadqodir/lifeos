<?php

namespace App\Http\Requests\Project;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreProjectRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true; // Authorization handled by middleware
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'title' => [
                'required',
                'string',
                'min:3',
                'max:120',
                // Unique per user (case-insensitive)
                Rule::unique('projects', 'title')
                    ->where('user_id', $this->user()->id)
                    ->whereNull('deleted_at'),
            ],
            'description' => 'nullable|string',
            'color' => [
                'required',
                'string',
                'regex:/^[0-9A-Fa-f]{6,8}$/', // Hex color format RRGGBB or AARRGGBB
            ],
            'icon' => 'nullable|image|mimes:jpeg,jpg,png,gif,webp|max:2048', // 2MB max
            'tags' => 'nullable|array',
            'tags.*' => 'string|max:50',
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'title.unique' => 'You already have a project with this title.',
            'color.regex' => 'The color must be in hex format (e.g., #FF5733).',
        ];
    }
}
