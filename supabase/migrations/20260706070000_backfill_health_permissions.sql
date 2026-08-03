-- Backfill health permissions for workers created before health columns existed.
-- Mirrors poultry-pms migration 20260704100000_add_health_permissions.

UPDATE public.user_permissions
SET
  can_view_health = true,
  can_edit_health = true
WHERE can_view_health = false
  AND can_edit_health = false
  AND (
    can_view_mortality = true
    OR can_view_eggs = true
    OR can_view_feeding = true
  );
