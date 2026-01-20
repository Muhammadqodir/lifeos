<?php

namespace App\Http\Requests\Todo;

use App\Models\Todo;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreTodoRequest extends FormRequest
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
            'project_id' => [
                'required',
                'integer',
                // Project must exist and belong to the user
                Rule::exists('projects', 'id')
                    ->where('user_id', $this->user()->id)
                    ->whereNull('deleted_at'),
            ],
            'title' => 'required|string|min:3|max:160',
            'comment' => 'nullable|string',
            'status' => [
                'nullable',
                Rule::in(Todo::getAllowedStatuses()),
            ],
            'priority' => [
                'required',
                Rule::in(Todo::getAllowedPriorities()),
            ],
            'urgency' => [
                'required',
                Rule::in(Todo::getAllowedUrgencies()),
            ],
            'energy' => [
                'required',
                Rule::in(Todo::getAllowedEnergies()),
            ],
            'time_spent_minutes' => 'nullable|integer|min:0',
            'planned_date' => 'nullable|date|date_format:Y-m-d',
            'planned_time' => 'nullable|date_format:H:i:s',
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
            'project_id.exists' => 'The selected project does not exist or does not belong to you.',
        ];
    }
}
