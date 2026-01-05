# Health & Fitness Tracking - Setup Guide

## Overview

This implementation adds comprehensive health and fitness tracking features to the LifeOS backend API:

1. **Sleep Tracking** - Record sleep duration, quality, and patterns
2. **Wellbeing Tracking** - Track daily energy and stress levels
3. **Gym Tracking** - Log strength workouts with exercises, sets, and progress tracking

## Database Setup

Run migrations to create the new tables:

```bash
cd lifeos_backend
php artisan migrate
```

This creates 6 new tables:
- `sleep_entries`
- `wellbeing_entries`
- `workout_sessions`
- `exercises`
- `workout_exercises`
- `workout_sets`

## Seed Default Exercises

Populate the database with common system exercises:

```bash
php artisan db:seed --class=ExerciseSeeder
```

This creates 28 default exercises across muscle groups:
- Chest (Bench Press, Push-ups, etc.)
- Legs (Squat, Deadlift, etc.)
- Back (Pull-up, Rows, etc.)
- Shoulders (Overhead Press, etc.)
- Arms (Curls, Tricep exercises, etc.)
- Core (Plank, Crunches, etc.)

## Running Tests

```bash
# Run all tests
php artisan test

# Run specific feature tests
php artisan test --filter=SleepEntryTest
php artisan test --filter=ExerciseProgressTest
```

## API Documentation

See [HEALTH_FITNESS_API.md](./HEALTH_FITNESS_API.md) for complete API documentation with curl examples.

## Key Features

### Sleep Tracking
- Record sleep start/end times
- Rate sleep quality (1-5)
- Calculate duration automatically
- Filter by date range
- Get summary statistics with daily breakdown

### Wellbeing Tracking
- Track daily energy levels (1-5)
- Track daily stress levels (1-5)
- Optional notes
- Summary statistics with trends

### Gym Tracking
- Create workout sessions with start/end times
- Add multiple exercises to each workout
- Track sets with weight, reps, and RPE
- Progress tracking per exercise showing:
  - Total volume over time
  - Best single set weight
  - Estimated 1RM using Epley formula

## Architecture

### Models
- `SleepEntry` - Sleep tracking records
- `WellbeingEntry` - Daily wellbeing metrics
- `WorkoutSession` - Workout sessions
- `Exercise` - Exercise library (system + user custom)
- `WorkoutExercise` - Pivot between sessions and exercises
- `WorkoutSet` - Individual sets within exercises

### Authorization
All resources are protected with policies ensuring users can only access their own data:
- `SleepEntryPolicy`
- `WellbeingEntryPolicy`
- `WorkoutSessionPolicy`
- `WorkoutExercisePolicy`
- `WorkoutSetPolicy`

### Validation
Form requests validate all input:
- Date formats and ranges
- Quality/energy/stress ratings (1-5)
- RPE ratings (1-10)
- Weight and rep ranges
- Required vs optional fields

### API Resources
Consistent JSON responses using Laravel API Resources:
- `SleepEntryResource`
- `WellbeingEntryResource`
- `WorkoutSessionResource`
- `ExerciseResource`
- `WorkoutExerciseResource`
- `WorkoutSetResource`

## Database Indexes

Performance indexes added for common queries:
- `sleep_entries(user_id, date)`
- `wellbeing_entries(user_id, date)`
- `workout_sessions(user_id, started_at)`
- `exercises(user_id, name)`
- `workout_exercises(session_id, sort_order)`
- `workout_sets(workout_exercise_id, set_index)`

## Usage Example

```php
// Create a workout
$workout = WorkoutSession::create([
    'user_id' => auth()->id(),
    'started_at' => now(),
    'ended_at' => now()->addHour(),
    'type' => 'strength',
]);

// Add an exercise
$workoutExercise = WorkoutExercise::create([
    'session_id' => $workout->id,
    'exercise_id' => 1, // Bench Press
    'sort_order' => 0,
]);

// Add sets
WorkoutSet::create([
    'workout_exercise_id' => $workoutExercise->id,
    'set_index' => 1,
    'weight_kg' => 80,
    'reps' => 8,
    'rpe' => 7,
    'is_done' => true,
]);

// Get progress
$progress = Exercise::find(1)
    ->workoutExercises()
    ->whereHas('session', fn($q) => $q->where('user_id', auth()->id()))
    ->with('sets')
    ->get();
```

## Future Enhancements

Potential improvements:
1. Photo attachments for custom exercises
2. Workout templates
3. Rest timer tracking
4. Cardio tracking (distance, time, calories)
5. Body measurements tracking
6. Nutrition tracking
7. Integration with fitness trackers
8. Social features (share workouts, follow friends)
9. Workout analytics (volume trends, frequency, etc.)
10. AI-powered workout recommendations
