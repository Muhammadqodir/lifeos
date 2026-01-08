<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCompleteWorkoutRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'started_at' => ['required', 'date'],
            'ended_at' => ['required', 'date', 'after:started_at'],
            'note' => ['nullable', 'string'],

            // Exercises array
            'exercises' => ['required', 'array', 'min:1'],
            'exercises.*.exercise_id' => ['required', 'exists:exercises,id'],
            'exercises.*.order_index' => ['required', 'integer', 'min:0'],
            'exercises.*.note' => ['nullable', 'string'],

            // Sets for each exercise
            'exercises.*.sets' => ['required', 'array', 'min:1'],
            'exercises.*.sets.*.set_index' => ['required', 'integer', 'min:0'],
            'exercises.*.sets.*.weight_kg' => ['nullable', 'numeric', 'min:0'],
            'exercises.*.sets.*.reps' => ['nullable', 'integer', 'min:1', 'max:500'],
            'exercises.*.sets.*.duration_seconds' => ['nullable', 'integer', 'min:1'],
            'exercises.*.sets.*.distance_meters' => ['nullable', 'numeric', 'min:0'],
            'exercises.*.sets.*.rpe' => ['nullable', 'integer', 'min:1', 'max:10'],
            'exercises.*.sets.*.is_done' => ['sometimes', 'boolean'],
        ];
    }
}
