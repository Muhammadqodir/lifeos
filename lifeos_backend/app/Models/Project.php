<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Project extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'title',
        'description',
        'color',
        'icon',
        'tags',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'tags' => 'array',
    ];

    /**
     * Boot the model.
     */
    protected static function boot()
    {
        parent::boot();

        // Normalize title before saving (for uniqueness check)
        static::saving(function ($project) {
            if ($project->isDirty('title')) {
                $project->title = trim($project->title);
            }

            // Normalize tags: trim and lowercase
            if ($project->isDirty('tags') && is_array($project->tags)) {
                $project->tags = array_map(function ($tag) {
                    return strtolower(trim($tag));
                }, $project->tags);
            }
        });
    }

    /**
     * Get the user that owns the project.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the todos for the project.
     */
    public function todos(): HasMany
    {
        return $this->hasMany(Todo::class);
    }
}
