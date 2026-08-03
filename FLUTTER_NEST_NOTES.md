# Flutter Nest notes (desktop) — Nest required

## Transport
- **Farm / commerce data:** Nest REST + `/api/v1/sync/push` only. `HATCHLOG_API_URL` is **required** in `.env` at app start.
- Sync online gate uses Nest `canReach()` (not Supabase HEAD).
- **Auth / identity leftovers:** Supabase Auth (JWT), license RPCs, team provision edge, membership/permissions.

## Online
- Push/pull Nest-only for: houses, livestock, inventory, sales, expenses, customers, suppliers, formulations, eggs, feeding, mortality, health schedules, ledger txs, farm settings, egg categories
- Pending deletions sync via Nest soft-delete endpoints (not Supabase `.delete()`)
- Trash list/restore and audit logs via Nest `/api/v1/trash` and `/api/v1/audit`
- No Supabase dual-write/fallback for Nest-owned domains

## Offline
- Egg / feed / mortality → `POST /api/v1/sync/push`
- Do **not** expand offline sync beyond those three entities

## Smoke checklist
- Missing `HATCHLOG_API_URL` → app start throws
- Nest up: farm sync does not insert into Supabase commerce/ops tables
- Auth / license / team provision still use Supabase
