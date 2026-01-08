# Health & Fitness API - Curl Examples

Base URL: `http://localhost:8000/api/v1`

**Authentication**: All endpoints require Bearer token authentication via Sanctum.

## Authentication

### Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password"
  }'
```

Response includes `token` - use this in subsequent requests as `Bearer {token}`.

## Sleep Tracking

### List Sleep Entries
```bash
curl -X GET "http://localhost:8000/api/v1/health/sleep?from=2026-01-01&to=2026-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create Sleep Entry
```bash
curl -X POST http://localhost:8000/api/v1/health/sleep \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2026-01-04",
    "sleep_start": "2026-01-03T23:00:00Z",
    "sleep_end": "2026-01-04T07:00:00Z",
    "quality": 4,
    "note": "Good sleep"
  }'
```

### Update Sleep Entry
```bash
curl -X PUT http://localhost:8000/api/v1/health/sleep/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "quality": 5,
    "note": "Great sleep!"
  }'
```

### Delete Sleep Entry
```bash
curl -X DELETE http://localhost:8000/api/v1/health/sleep/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Sleep Summary
```bash
curl -X GET "http://localhost:8000/api/v1/health/sleep/summary?from=2026-01-01&to=2026-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Wellbeing Tracking

### List Wellbeing Entries
```bash
curl -X GET "http://localhost:8000/api/v1/health/wellbeing?from=2026-01-01&to=2026-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create Wellbeing Entry
```bash
curl -X POST http://localhost:8000/api/v1/health/wellbeing \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "date": "2026-01-04",
    "energy": 4,
    "stress": 2,
    "note": "Feeling good today"
  }'
```

### Update Wellbeing Entry
```bash
curl -X PUT http://localhost:8000/api/v1/health/wellbeing/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "energy": 5,
    "stress": 1
  }'
```

### Delete Wellbeing Entry
```bash
curl -X DELETE http://localhost:8000/api/v1/health/wellbeing/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Get Wellbeing Summary
```bash
curl -X GET "http://localhost:8000/api/v1/health/wellbeing/summary?from=2026-01-01&to=2026-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Gym - Workouts

### List Workout Sessions (Paginated)
```bash
curl -X GET "http://localhost:8000/api/v1/gym/workouts?from=2026-01-01&to=2026-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create Workout Session
```bash
curl -X POST http://localhost:8000/api/v1/gym/workouts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "started_at": "2026-01-04T10:00:00Z",
    "ended_at": "2026-01-04T11:30:00Z",
    "type": "strength",
    "note": "Upper body day"
  }'
```

### Get Workout Session (with exercises and sets)
```bash
curl -X GET http://localhost:8000/api/v1/gym/workouts/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Update Workout Session
```bash
curl -X PUT http://localhost:8000/api/v1/gym/workouts/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "note": "Updated: Great workout!"
  }'
```

### Delete Workout Session
```bash
curl -X DELETE http://localhost:8000/api/v1/gym/workouts/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Gym - Exercises

### List All Exercises (System + User Custom)
```bash
curl -X GET "http://localhost:8000/api/v1/gym/exercises?search=bench" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create Custom Exercise
```bash
curl -X POST http://localhost:8000/api/v1/gym/exercises \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: multipart/form-data" \
  -F "name=Cable Fly" \
  -F "type=strength" \
  -F "muscle_group=Chest" \
  -F "image=@/path/to/image.jpg"
```

**Note**: 
- `type` is required and must be one of: `strength`, `distance`, `time`
- `muscle_group` is optional
- `image` is optional and accepts image files (jpeg, jpg, png, webp) up to 2MB

### Get Exercise Progress (Chart Data)
```bash
curl -X GET "http://localhost:8000/api/v1/gym/exercises/1/progress?from=2026-01-01&to=2026-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response Example:**
```json
{
  "exercise": {
    "id": 1,
    "name": "Bench Press",
    "muscle_group": "Chest",
    "is_system": true
  },
  "points": [
    {
      "date": "2026-01-04",
      "volume": 1280.00,
      "best_set_weight": 80.00,
      "best_e1rm": 101.33
    }
  ]
}
```

## Gym - Workout Exercises (Adding exercises to a workout)

### Add Exercise to Workout
```bash
curl -X POST http://localhost:8000/api/v1/gym/workouts/1/exercises \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "exercise_id": 1,
    "sort_order": 0
  }'
```

### Remove Exercise from Workout
```bash
curl -X DELETE http://localhost:8000/api/v1/gym/workout-exercises/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Gym - Sets

### Add Set to Workout Exercise
```bash
curl -X POST http://localhost:8000/api/v1/gym/workout-exercises/1/sets \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "set_index": 1,
    "weight_kg": 80.5,
    "reps": 8,
    "rpe": 7,
    "is_done": true
  }'
```

### Update Set
```bash
curl -X PUT http://localhost:8000/api/v1/gym/sets/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "weight_kg": 82.5,
    "reps": 9,
    "rpe": 8
  }'
```

### Delete Set
```bash
curl -X DELETE http://localhost:8000/api/v1/gym/sets/1 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Complete Workout Example

Here's a complete flow for creating a workout with exercises and sets:

```bash
# 1. Create workout session
WORKOUT=$(curl -X POST http://localhost:8000/api/v1/gym/workouts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "started_at": "2026-01-04T10:00:00Z",
    "ended_at": "2026-01-04T11:00:00Z",
    "type": "strength"
  }' | jq -r '.data.id')

# 2. Add Bench Press to workout (exercise_id=1)
WORKOUT_EXERCISE=$(curl -X POST http://localhost:8000/api/v1/gym/workouts/$WORKOUT/exercises \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "exercise_id": 1,
    "sort_order": 0
  }' | jq -r '.data.id')

# 3. Add sets
curl -X POST http://localhost:8000/api/v1/gym/workout-exercises/$WORKOUT_EXERCISE/sets \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "set_index": 1,
    "weight_kg": 80,
    "reps": 8,
    "rpe": 7,
    "is_done": true
  }'

curl -X POST http://localhost:8000/api/v1/gym/workout-exercises/$WORKOUT_EXERCISE/sets \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "set_index": 2,
    "weight_kg": 80,
    "reps": 8,
    "rpe": 8,
    "is_done": true
  }'

curl -X POST http://localhost:8000/api/v1/gym/workout-exercises/$WORKOUT_EXERCISE/sets \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "set_index": 3,
    "weight_kg": 80,
    "reps": 7,
    "rpe": 9,
    "is_done": true
  }'

# 4. View complete workout
curl -X GET http://localhost:8000/api/v1/gym/workouts/$WORKOUT \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Summary Endpoints Response Examples

### Sleep Summary Response
```json
{
  "count": 10,
  "avg_duration_hours": 7.5,
  "avg_quality": 4.2,
  "points": [
    {
      "date": "2026-01-04",
      "duration_hours": 8.0,
      "quality": 5
    }
  ]
}
```

### Wellbeing Summary Response
```json
{
  "count": 10,
  "avg_energy": 3.8,
  "avg_stress": 2.3,
  "points": [
    {
      "date": "2026-01-04",
      "energy": 4,
      "stress": 2
    }
  ]
}
```

## Notes

- All dates should be in `YYYY-MM-DD` format
- All datetimes should be in ISO 8601 format (e.g., `2026-01-04T10:00:00Z`)
- Quality, energy, and stress are rated 1-5
- RPE (Rate of Perceived Exertion) is rated 1-10
- Weight is in kilograms (decimal with 2 places)
- Reps range from 1-200
- The e1RM (estimated 1 rep max) is calculated using Epley formula: `weight * (1 + reps/30)`
- All list endpoints support optional `from` and `to` date filters
- Workout list endpoint is paginated (20 items per page)
