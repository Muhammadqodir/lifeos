# Local-first architecture

LifeOS reads and writes data on the device and syncs with the server in the
background. Nothing on screen waits for the network: an action is saved
locally and shown at once, and it works the same offline.

**Covered so far:** projects, todos, habits, habit entries, and Home, which is
built from them. Finance and Health still call the API directly; see
[Adding an entity](#adding-an-entity) and [Next steps](#next-steps).

```
 Screen ── BLoC ── Repository ──┬── LocalStore (sembast) ── watch() streams ──► every screen
                                │        ▲  outbox
                                └── SyncEngine ──── push / pull ────► Laravel /v1/sync/*
```

## Principles

1. **The device is the source of truth for the UI.** Repositories return
   streams over the local store. They never return the result of an HTTP
   call.
2. **A write is one local transaction.** It changes the record and appends an
   operation to the outbox. The engine sends the outbox later.
3. **Screens don't refresh each other.** Every write notifies the store's
   watchers, so Home, the project list and the habit list update themselves.
   ⌘R and pull-to-refresh only ask the engine to sync now.
4. **The server has the last word.** When it refuses a change, the device
   puts the server's copy back and tells the user why.

## Client

| Piece | File | Job |
|---|---|---|
| `LocalStore` | `lib/core/sync/local_store.dart` | One sembast store per entity, the outbox and sync metadata. `write()` runs a transaction and then notifies watchers. `watch(entities, read)` re-reads after every relevant write. IndexedDB on web, a file on iOS and macOS. |
| `SyncEngine` | `lib/core/sync/sync_engine.dart` | `create` / `update` / `delete` for repositories, the push and pull loop, retries, `status` (idle, syncing, offline, error, pending count), and `issues` (refused changes). |
| `SyncApi` | `lib/core/sync/sync_api.dart` | The two HTTP calls. |
| ids | `lib/core/sync/ids.dart` | `newId()` (uuid v4). `habitEntryId(habit, day)` (uuid v5) gives the same id on every device. |
| `HabitStats` | `lib/features/habits/domain/habit_stats.dart` | Streaks and completion rate from local entries. Mirrors the backend's `HabitStatsService`. |
| `SyncIndicator` | `lib/core/ui/components/sync_indicator.dart` | Header icon shown only when offline or failing. Tap it to retry. |

**Records** are stored in the sync API's JSON format: snake_case, `id` is the
uuid, and foreign keys are uuids. `server_id` is the backend's integer id,
needed only for endpoints that don't sync (the project icon upload). DTOs read
records with `fromJson`.

**When the engine syncs:** 400 ms after a change, every minute, when the app
returns to the foreground, and on `syncNow()` (⌘R, pull-to-refresh, tapping
the indicator). A round pushes the whole outbox first and then pulls. After a
failure it retries at 5, 10 and 20 seconds, then every 30 seconds.

**The outbox.** Each local change adds one operation:
`{op_id, entity, id, type: create|update|delete, data}`.

- An edit to a record that hasn't been sent yet is folded into the queued
  operation, so a create followed by three edits goes out as one create.
- Deleting something the server never saw drops its queued operations and
  sends nothing.
- Operations that are being sent are never modified.

**Merging server data.** When a pushed record comes back or a pulled record
arrives, the engine stores the server's copy and re-applies any change still
queued for that record. Unsent edits are never overwritten. Deletions in a
pull also remove the record's children: a project's todos, a habit's entries.

**Accounts.** `start(userId)` clears local data that belongs to a different
user. When a session expires the engine stops and keeps local data, so unsent
changes survive signing in again. Signing out pushes for up to 5 seconds and
then clears the device. If the user is offline, those unsent changes are
lost. The signed-in profile is cached so the app opens offline.

**First launch.** Lists wait for `whenReady()`, which completes after the
first sync attempt, even a failed one. A fresh sign-in therefore shows
"loading" instead of an empty screen.

## Server

| Piece | File |
|---|---|
| Endpoints | `app/Http/Controllers/Api/V1/SyncController.php` (`GET /v1/sync/pull`, `POST /v1/sync/push`) |
| Protocol | `app/Sync/SyncService.php` |
| Entity mapping and validation | `app/Sync/Entities/*Sync.php`, listed in `app/Sync/SyncRegistry.php` (parents first) |
| uuid and tombstones on every write path | `app/Models/Concerns/Syncable.php`, `sync_tombstones` |
| Idempotent retries | `sync_operations` (pruned after 30 days in `routes/console.php`) |

### Pull

`GET /v1/sync/pull?cursor=<iso8601>` returns:

```json
{"data": {
  "cursor": "2026-10-30T17:42:57.000000Z",
  "full": false,
  "changes": {"projects": [...], "todos": [...], "habits": [...], "habit_entries": [...]},
  "deleted": {"projects": ["uuid"], "todos": [], "habits": [], "habit_entries": []}
}}
```

- With no cursor, the response is everything (`full: true`). The client then
  drops local records the server doesn't have, except unsent creations.
- The cursor is the server time taken *before* reading, compared with `>=`,
  so a write that lands during a pull is sent again rather than missed.
  Applying a record twice does nothing.

### Push

`POST /v1/sync/push` with `{"ops": [...]}` (at most 200) returns one result
per operation, in order:

```json
{"op_id": "…", "status": "applied", "record": {...}}
{"op_id": "…", "status": "rejected", "code": "validation_failed", "message": "…", "errors": {...}, "record": {...} | null}
```

| Situation | Result |
|---|---|
| `create` with a new uuid | Created. Missing fields get the same defaults as the REST API: a todo is `inbox` or `planned`, a habit is `active`. |
| `create` with a uuid that already exists | Treated as an update, so a retry is safe. |
| `create` of a habit entry for a day that already has one | Merged into the existing entry. `record.id` is that entry's uuid, and the client swaps its copy. |
| `update` | Only the fields sent change. Validation uses `sometimes` rules. |
| `update` of a deleted or unknown record | Rejected with `gone`, `record: null`. The client deletes its copy. |
| `delete` | Deletes the record, idempotently. Deleting a project also deletes its todos. |
| Someone else's uuid | Rejected with `forbidden`. |
| Same `op_id` again | Returns the stored first result without applying it again. |

Each operation runs in its own transaction, so one rejection never blocks the
operations after it.

**Conflicts** are resolved last-writer-wins *per field*. An update carries only
the fields that changed, so edits to different fields on two devices both
survive. When two devices change the same field, the one the server receives
last wins. This is the right trade-off for a single-person app. Ordered or
collaborative data (shared lists, counters) would need a different rule.

## Adding an entity

1. **Backend**
   - Add the `Syncable` trait to the model, and a migration with a `uuid`
     column (backfilled) and a `(user_id, updated_at)` index.
   - Write `app/Sync/Entities/FooSync.php` covering serialization, rules,
     uuid → id mapping and defaults.
   - Register it in `SyncRegistry` after its parents.
   - Add cases to `tests/Feature/Api/V1/SyncTest.php`.
2. **Client**
   - Add the name to `SyncEntities.all`, plus `children` if deleting it should
     remove other records.
   - Give the DTO a `String id` and a `fromJson` for the wire format.
   - Write a repository that reads with `store.watch` and writes through
     `SyncEngine`.
   - Make the BLoC subscribe to the stream instead of loading.
3. **Derived numbers** such as totals and streaks are computed on the device
   from local records. Keep the server copy (if any) in step and say so in
   both files.

## What stays online

- **Files.** The project icon is uploaded with `POST /v1/projects/{id}/icon`
  after the project has synced. The next pull brings the new path. Offline,
  the project is created without its icon.
- **Sign-in, registration and FX rates.**
- **Finance and Health** for now.

## Next steps

- **Finance.** Wallets, categories and transactions already carry a client
  uuid (`client_id`) for idempotent creates. Balances and analytics would move
  to the device. Multi-currency conversion needs FX rates cached locally.
- **Health.** Sleep and wellbeing entries are simple to move. Workouts are
  nested (session → exercises → sets → completion photo) and would sync as
  separate entities, with the photo uploaded like the project icon.
- **Instant updates.** Pull is periodic. A WebSocket or push notification that
  says "something changed" could trigger `syncNow()` across devices.
- **Large accounts.** Pull returns everything changed since the cursor in one
  response, which is fine at personal scale. Add per-entity paging if an
  account grows to tens of thousands of rows.

## Deploying

The response format change (`{data}` everywhere, 204 for deletes,
`{message, code}` errors) and the sync endpoints need backend and app to ship
together:

1. Deploy the backend and run `php artisan migrate`. This adds uuids to
   existing rows.
2. Release the app. Builds that predate this change will misread auth
   responses (`data.user` instead of `user`), so update every installed copy.
