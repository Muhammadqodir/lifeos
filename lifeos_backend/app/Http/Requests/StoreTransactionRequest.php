<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class StoreTransactionRequest extends FormRequest
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
            'client_id' => ['required', 'uuid'],
            'type' => ['required', 'in:income,expense,transfer,exchange'],
            'category_id' => ['nullable', 'integer', 'exists:transaction_categories,id'],
            'description' => ['nullable', 'string', 'max:1000'],
            'occurred_at' => ['required', 'date'],
            'entries' => ['required', 'array', 'min:1'],
            'entries.*.wallet_id' => ['required', 'integer', 'exists:wallets,id'],
            'entries.*.amount' => ['required', 'numeric'],
            'entries.*.currency_id' => ['required', 'integer', 'exists:currencies,id'],
            'entries.*.rate' => ['nullable', 'numeric', 'min:0'],
            'entries.*.note' => ['nullable', 'string', 'max:1000'],
        ];
    }

    /**
     * Configure the validator instance.
     */
    public function after(): array
    {
        return [
            function (Validator $validator) {
                $type = $this->input('type');
                $entries = $this->input('entries', []);
                $categoryId = $this->input('category_id');

                // Validate category_id based on type
                if (in_array($type, ['income', 'expense']) && !$categoryId) {
                    $validator->errors()->add('category_id', 'Category is required for income and expense transactions.');
                }

                if (in_array($type, ['transfer', 'exchange']) && $categoryId) {
                    $validator->errors()->add('category_id', 'Category must be null for transfer and exchange transactions.');
                }

                // Validate entries count and amounts based on type
                if ($type === 'income') {
                    if (count($entries) !== 1) {
                        $validator->errors()->add('entries', 'Income transactions must have exactly 1 entry.');
                    } elseif ($entries[0]['amount'] <= 0) {
                        $validator->errors()->add('entries.0.amount', 'Income amount must be positive.');
                    }
                }

                if ($type === 'expense') {
                    if (count($entries) !== 1) {
                        $validator->errors()->add('entries', 'Expense transactions must have exactly 1 entry.');
                    } elseif ($entries[0]['amount'] >= 0) {
                        $validator->errors()->add('entries.0.amount', 'Expense amount must be negative.');
                    }
                }

                if ($type === 'transfer') {
                    $entryCount = count($entries);

                    if (!in_array($entryCount, [2, 3])) {
                        $validator->errors()->add('entries', 'Transfer transactions must have 2 or 3 entries (source, destination, and optional fee).');
                    } else {
                        // Check same currency for main entries
                        if ($entries[0]['currency_id'] !== $entries[1]['currency_id']) {
                            $validator->errors()->add('entries', 'Transfer source and destination entries must have the same currency.');
                        }

                        if ($entryCount === 2) {
                            // Standard transfer: amounts must sum to 0
                            $sum = $entries[0]['amount'] + $entries[1]['amount'];
                            if (abs($sum) > 0.000001) {
                                $validator->errors()->add('entries', 'Transfer entry amounts must sum to 0.');
                            }
                        } else {
                            // Transfer with fee: third entry is the fee (negative)
                            // Fee must be negative (outgoing)
                            if ($entries[2]['amount'] >= 0) {
                                $validator->errors()->add('entries.2.amount', 'Fee amount must be negative.');
                            }

                            // The first two entries represent the transfer (don't need to sum to 0 with fee)
                            // Total of all three entries will be negative (the fee amount)
                        }

                        // Check one positive, one negative for first two entries
                        if (($entries[0]['amount'] > 0 && $entries[1]['amount'] > 0) ||
                            ($entries[0]['amount'] < 0 && $entries[1]['amount'] < 0)) {
                            $validator->errors()->add('entries', 'Transfer must have one positive and one negative entry for source and destination.');
                        }
                    }
                }

                if ($type === 'exchange') {
                    if (count($entries) !== 2) {
                        $validator->errors()->add('entries', 'Exchange transactions must have exactly 2 entries.');
                    } else {
                        // Check different currencies
                        if ($entries[0]['currency_id'] === $entries[1]['currency_id']) {
                            $validator->errors()->add('entries', 'Exchange entries must have different currencies.');
                        }
                        // Check one positive, one negative
                        if (($entries[0]['amount'] > 0 && $entries[1]['amount'] > 0) ||
                            ($entries[0]['amount'] < 0 && $entries[1]['amount'] < 0)) {
                            $validator->errors()->add('entries', 'Exchange must have one positive and one negative entry.');
                        }
                        // Check rate is provided
                        foreach ($entries as $index => $entry) {
                            if (!isset($entry['rate']) || $entry['rate'] === null) {
                                $validator->errors()->add("entries.{$index}.rate", 'Rate is required for exchange transactions.');
                            }
                        }
                    }
                }
            }
        ];
    }
}
