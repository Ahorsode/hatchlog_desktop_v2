# Flutter Nest notes (Phase 3)

## Online
- `HatchlogApiClient` uses Nest domain REST (`/api/v1/livestock`, `/houses`, `/eggs`, …) with Bearer Supabase JWT.
- Sync engine prefers Nest for houses/livestock online hydration when `HATCHLOG_API_URL` is set and reachable.

## Offline
- Mortality / feeding / eggs continue via `/api/v1/sync/push`.
- Local SQLite/Drift offline path is unchanged.
