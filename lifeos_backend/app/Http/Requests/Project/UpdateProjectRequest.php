<?php

namespace App\Http\Requests\Project;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProjectRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true; // Authorization handled by policy
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $projectId = $this->route('project');

        return [
            'title' => [
                'sometimes',
                'required',
                'string',
                'min:3',
                'max:120',
                // Unique per user, excluding current project
                Rule::unique('projects', 'title')
                    ->where('user_id', $this->user()->id)
                    ->ignore($projectId)
                    ->whereNull('deleted_at'),
            ],
            'description' => 'nullable|string',
            'color' => [
                'sometimes',
                'required',
                'string',
                'regex:/^#[0-9A-Fa-f]{6}$/', // Hex color format #RRGGBB
            ],
            'icon' => 'nullable|string|max:255',
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
