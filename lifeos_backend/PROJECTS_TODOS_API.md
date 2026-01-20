# Projects & Todos API Documentation

## Overview

The Projects & Todos module allows users to organize tasks within projects. Each user has their own isolated projects and todos with comprehensive filtering, ordering, and status tracking capabilities.

**Base URL**: `/api/v1`

**Authentication**: All endpoints require Bearer token authentication (Laravel Sanctum).

**Response Format**: All responses follow a consistent JSON envelope:
```json
{
  "data": { ... },
  "message": "Success message (for mutations)"
}
```

For paginated results:
```json
{
  "data": [ ... ],
  "links": { ... },
  "meta": { ... }
}
```

---

## Projects

### List Projects

**Endpoint**: `GET /api/v1/projects`

**Query Parameters**:
- `search` (string, optional): Search projects by title
- `per_page` (integer, optional, default: 15): Items per page

**Response**:
```json
{
  "data": [
    {
      "id": 1,
      "title": "Work Projects",
      "description": "All work-related tasks",
      "color": "#FF5733",
      "icon": "https://example.com/icon.png",
      "tags": ["work", "important"],
      "todos_count": 5,
      "created_at": "2026-01-16T10:00:00.000000Z",
      "updated_at": "2026-01-16T10:00:00.000000Z"
    }
  ],
  "links": { ... },
  "meta": { ... }
}
```

**Example Request**:
```bash
curl -X GET "https://api.lifeos.com/api/v1/projects?search=Work" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

---

### Create Project

**Endpoint**: `POST /api/v1/projects`

**Request Body**:
```json
{
  "title": "Health Goals",
  "description": "Fitness and wellness tracking",
  "color": "#00FF00",
  "icon": "health-icon.png",
  "tags": ["health", "personal"]
}
```

**Validation Rules**:
- `title`: Required, string, 3-120 characters, unique per user
- `description`: Optional, string
- `color`: Required, hex format (`#RRGGBB`)
- `icon`: Optional, string, max 255 characters
- `tags`: Optional, array of strings (max 50 chars each)

**Response** (201 Created):
```json
{
  "data": {
    "id": 2,
    "title": "Health Goals",
    "description": "Fitness and wellness tracking",
    "color": "#00FF00",
    "icon": "health-icon.png",
    "tags": ["health", "personal"],
    "created_at": "2026-01-16T11:00:00.000000Z",
    "updated_at": "2026-01-16T11:00:00.000000Z"
  },
  "message": "Project created successfully."
}
```

**Example Request**:
```bash
curl -X POST "https://api.lifeos.com/api/v1/projects" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "title": "Health Goals",
    "color": "#00FF00",
    "tags": ["health", "personal"]
  }'
```

---

### Get Project Details

**Endpoint**: `GET /api/v1/projects/{id}`

**Response**:
```json
{
  "data": {
    "id": 1,
    "title": "Work Projects",
    "description": "All work-related tasks",
    "color": "#FF5733",
    "icon": "work-icon.png",
    "tags": ["work", "important"],
    "todos_count": 5,
    "created_at": "2026-01-16T10:00:00.000000Z",
    "updated_at": "2026-01-16T10:00:00.000000Z"
  }
}
```

**Example Request**:
```bash
curl -X GET "https://api.lifeos.com/api/v1/projects/1" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

---

### Update Project

**Endpoint**: `PUT /api/v1/projects/{id}`

**Request Body** (all fields optional):
```json
{
  "title": "Updated Title",
  "color": "#0000FF",
  "tags": ["work", "priority"]
}
```

**Response**:
```json
{
  "data": {
    "id": 1,
    "title": "Updated Title",
    "color": "#0000FF",
    "tags": ["work", "priority"],
    ...
  },
  "message": "Project updated successfully."
}
```

**Example Request**:
```bash
curl -X PUT "https://api.lifeos.com/api/v1/projects/1" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"title": "Updated Title", "color": "#0000FF"}'
```

---

### Delete Project

**Endpoint**: `DELETE /api/v1/projects/{id}`

**Note**: This performs a soft delete. The project and its todos are not permanently removed.

**Response**:
```json
{
  "message": "Project deleted successfully."
}
```

**Example Request**:
```bash
curl -X DELETE "https://api.lifeos.com/api/v1/projects/1" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

---

## Todos

### List Todos

**Endpoint**: `GET /api/v1/todos`

**Query Parameters**:
- `project_id` (integer, optional): Filter by project
- `status` (string, optional): Filter by status (`planned`, `in_progress`, `blocked`, `done`)
- `tag` (string, optional): Filter by tag (case-insensitive)
- `planned_from` (datetime, optional): Filter todos planned from this date
- `planned_to` (datetime, optional): Filter todos planned until this date
- `search` (string, optional): Search by title
- `order_by` (string, optional): Order by field (`planned_date_time`, `priority`, `urgency`, `energy`, `created_at`)
- `order_direction` (string, optional): `asc` or `desc` (default: `desc`)
- `per_page` (integer, optional, default: 15): Items per page

**Response**:
```json
{
  "data": [
    {
      "id": 1,
      "project_id": 1,
      "project": {
        "id": 1,
        "title": "Work Projects",
        "color": "#FF5733",
        ...
      },
      "title": "Finish API documentation",
      "comment": "Include all endpoints with examples",
      "status": "in_progress",
      "priority": "high",
      "urgency": "high",
      "energy": "medium",
      "time_spent_minutes": 45,
      "planned_date_time": "2026-01-20T10:00:00.000000Z",
      "completed_at": null,
      "tags": ["documentation", "urgent"],
      "created_at": "2026-01-16T10:00:00.000000Z",
      "updated_at": "2026-01-16T11:00:00.000000Z"
    }
  ],
  "links": { ... },
  "meta": { ... }
}
```

**Example Request**:
```bash
curl -X GET "https://api.lifeos.com/api/v1/todos?status=in_progress&order_by=priority&order_direction=desc" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

---

### Create Todo

**Endpoint**: `POST /api/v1/todos`

**Request Body**:
```json
{
  "project_id": 1,
  "title": "Implement payment gateway",
  "comment": "Use Stripe API",
  "status": "planned",
  "priority": "high",
  "urgency": "middle",
  "energy": "hard",
  "time_spent_minutes": 0,
  "planned_date_time": "2026-01-20 10:00:00",
  "tags": ["backend", "payment"]
}
```

**Validation Rules**:
- `project_id`: Required, must belong to the user
- `title`: Required, string, 3-160 characters
- `comment`: Optional, string
- `status`: Required, enum (`planned`, `in_progress`, `blocked`, `done`)
- `priority`: Required, enum (`low`, `middle`, `high`)
- `urgency`: Required, enum (`low`, `middle`, `high`)
- `energy`: Required, enum (`easy`, `medium`, `hard`)
- `time_spent_minutes`: Optional, integer, min 0
- `planned_date_time`: Optional, datetime (format: `Y-m-d H:i:s`)
- `tags`: Optional, array of strings (max 50 chars each)

**Response** (201 Created):
```json
{
  "data": {
    "id": 2,
    "project_id": 1,
    "title": "Implement payment gateway",
    "status": "planned",
    "priority": "high",
    ...
  },
  "message": "Todo created successfully."
}
```

**Example Request**:
```bash
curl -X POST "https://api.lifeos.com/api/v1/todos" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "project_id": 1,
    "title": "Implement payment gateway",
    "status": "planned",
    "priority": "high",
    "urgency": "middle",
    "energy": "hard"
  }'
```

---

### Get Todo Details

**Endpoint**: `GET /api/v1/todos/{id}`

**Response**:
```json
{
  "data": {
    "id": 1,
    "project_id": 1,
    "project": { ... },
    "title": "Finish API documentation",
    "status": "in_progress",
    ...
  }
}
```

**Example Request**:
```bash
curl -X GET "https://api.lifeos.com/api/v1/todos/1" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

---

### Update Todo

**Endpoint**: `PUT /api/v1/todos/{id}`

**Request Body** (all fields optional):
```json
{
  "title": "Updated task title",
  "status": "done",
  "priority": "low"
}
```

**Note**: When `status` is changed to `done`, `completed_at` is automatically set to the current timestamp. When changed from `done` to any other status, `completed_at` is cleared.

**Response**:
```json
{
  "data": {
    "id": 1,
    "title": "Updated task title",
    "status": "done",
    "completed_at": "2026-01-16T12:00:00.000000Z",
    ...
  },
  "message": "Todo updated successfully."
}
```

**Example Request**:
```bash
curl -X PUT "https://api.lifeos.com/api/v1/todos/1" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"status": "done"}'
```

---

### Update Todo Status

**Endpoint**: `PATCH /api/v1/todos/{id}/status`

**Request Body**:
```json
{
  "status": "in_progress"
}
```

**Validation Rules**:
- `status`: Required, enum (`planned`, `in_progress`, `blocked`, `done`)

**Response**:
```json
{
  "data": {
    "id": 1,
    "status": "in_progress",
    "completed_at": null,
    ...
  },
  "message": "Todo status updated successfully."
}
```

**Example Request**:
```bash
curl -X PATCH "https://api.lifeos.com/api/v1/todos/1/status" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"status": "in_progress"}'
```

---

### Delete Todo

**Endpoint**: `DELETE /api/v1/todos/{id}`

**Note**: This performs a soft delete.

**Response**:
```json
{
  "message": "Todo deleted successfully."
}
```

**Example Request**:
```bash
curl -X DELETE "https://api.lifeos.com/api/v1/todos/1" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

---

## Data Models

### Project Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | - | Auto-generated ID |
| `user_id` | integer | ✓ | Owner user ID (auto-set) |
| `title` | string | ✓ | Project title (3-120 chars, unique per user) |
| `description` | text | - | Project description |
| `color` | string | ✓ | Hex color (#RRGGBB) |
| `icon` | string | - | Image path/URL |
| `tags` | array | - | Array of strings |
| `created_at` | datetime | - | Creation timestamp |
| `updated_at` | datetime | - | Last update timestamp |

### Todo Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | - | Auto-generated ID |
| `user_id` | integer | ✓ | Owner user ID (auto-set) |
| `project_id` | integer | ✓ | Associated project ID |
| `title` | string | ✓ | Task title (3-160 chars) |
| `comment` | text | - | Task details/notes |
| `status` | enum | ✓ | `planned`, `in_progress`, `blocked`, `done` |
| `priority` | enum | ✓ | `low`, `middle`, `high` |
| `urgency` | enum | ✓ | `low`, `middle`, `high` |
| `energy` | enum | ✓ | `easy`, `medium`, `hard` |
| `time_spent_minutes` | integer | - | Time spent (>= 0) |
| `planned_date_time` | datetime | - | Planned execution time |
| `completed_at` | datetime | - | Auto-set when status = done |
| `tags` | array | - | Array of strings |
| `created_at` | datetime | - | Creation timestamp |
| `updated_at` | datetime | - | Last update timestamp |

---

## Authorization

All endpoints enforce user-scoped access:
- Users can only view/modify their own projects and todos
- Cross-user access attempts return `403 Forbidden`
- Unauthenticated requests return `401 Unauthorized`

---

## Error Responses

### Validation Error (422)
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "title": ["The title field is required."],
    "color": ["The color must be in hex format (e.g., #FF5733)."]
  }
}
```

### Unauthorized (401)
```json
{
  "message": "Unauthenticated."
}
```

### Forbidden (403)
```json
{
  "message": "This action is unauthorized."
}
```

### Not Found (404)
```json
{
  "message": "No query results for model [App\\Models\\Project] 123"
}
```

---

## Notes

### Tag Normalization
All tags are automatically normalized on save:
- Trimmed of whitespace
- Converted to lowercase
- Example: `["  Work  ", "URGENT"]` → `["work", "urgent"]`

### Completed At Lifecycle
- When `status` changes to `done`: `completed_at` is auto-set to current timestamp
- When `status` changes from `done` to anything else: `completed_at` is cleared
- Manual setting of `completed_at` is ignored

### Soft Deletes
Both projects and todos use soft deletes:
- Deleted records are not permanently removed
- They're excluded from queries by default
- `deleted_at` column is set to deletion timestamp

---

## Testing

Run the feature tests:

```bash
cd lifeos_backend
php artisan test --filter=ProjectTest
php artisan test --filter=TodoTest
```

Or run all tests:

```bash
composer run test
```

---

## Setup

1. Run migrations:
```bash
php artisan migrate
```

2. (Optional) Seed test data:
```bash
php artisan db:seed --class=ProjectSeeder
```

3. Generate API documentation:
```bash
php artisan route:list --path=api/v1/projects
php artisan route:list --path=api/v1/todos
```
