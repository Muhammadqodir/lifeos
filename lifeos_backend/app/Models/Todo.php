<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Todo extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'project_id',
        'title',
        'comment',
        'status',
        'priority',
        'urgency',
        'energy',
        'time_spent_minutes',
        'planned_date',
        'planned_time',
        'completed_at',
        'tags',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'tags' => 'array',
        'planned_date' => 'date',
        'completed_at' => 'datetime',
        'time_spent_minutes' => 'integer',
    ];

    /**
     * Allowed values for enum fields.
     */
    public const STATUS_INBOX = 'inbox';
    public const STATUS_PLANNED = 'planned';
    public const STATUS_IN_PROGRESS = 'in_progress';
    public const STATUS_BLOCKED = 'blocked';
    public const STATUS_DONE = 'done';

    public const PRIORITY_LOW = 'low';
    public const PRIORITY_MIDDLE = 'middle';
    public const PRIORITY_HIGH = 'high';

    public const URGENCY_LOW = 'low';
    public const URGENCY_MIDDLE = 'middle';
    public const URGENCY_HIGH = 'high';

    public const ENERGY_EASY = 'easy';
    public const ENERGY_MEDIUM = 'medium';
    public const ENERGY_HARD = 'hard';

    /**
     * Get allowed values for each enum field.
     */
    public static function getAllowedStatuses(): array
    {
        return [
            self::STATUS_INBOX,
            self::STATUS_PLANNED,
            self::STATUS_IN_PROGRESS,
            self::STATUS_BLOCKED,
            self::STATUS_DONE,
        ];
    }

    public static function getAllowedPriorities(): array
    {
        return [
            self::PRIORITY_LOW,
            self::PRIORITY_MIDDLE,
            self::PRIORITY_HIGH,
        ];
    }

    public static function getAllowedUrgencies(): array
    {
        return [
            self::URGENCY_LOW,
            self::URGENCY_MIDDLE,
            self::URGENCY_HIGH,
        ];
    }

    public static function getAllowedEnergies(): array
    {
        return [
            self::ENERGY_EASY,
            self::ENERGY_MEDIUM,
            self::ENERGY_HARD,
        ];
    }

    /**
     * Boot the model.
     */
    protected static function boot()
    {
        parent::boot();

        // Auto-set completed_at when status changes to "done"
        static::saving(function ($todo) {
            if ($todo->isDirty('status')) {
                if ($todo->status === self::STATUS_DONE && !$todo->completed_at) {
                    $todo->completed_at = now();
                } elseif ($todo->status !== self::STATUS_DONE) {
                    $todo->completed_at = null;
                }
            }

            // Normalize tags: trim and lowercase
            if ($todo->isDirty('tags') && is_array($todo->tags)) {
                $todo->tags = array_map(function ($tag) {
                    return strtolower(trim($tag));
                }, $todo->tags);
            }
        });
    }

    /**
     * Get the user that owns the todo.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the project that owns the todo.
     */
    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }
}
