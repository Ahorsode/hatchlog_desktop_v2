-- Enable RLS on audit tables
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE delete_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE insert_logs ENABLE ROW LEVEL SECURITY;

-- Ensure foreign keys exist for Supabase joins to work
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_audit_logs_user') THEN
    ALTER TABLE audit_logs ADD CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_id) REFERENCES users(id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_delete_logs_user') THEN
    ALTER TABLE delete_logs ADD CONSTRAINT fk_delete_logs_user FOREIGN KEY (user_id) REFERENCES users(id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_insert_logs_user') THEN
    ALTER TABLE insert_logs ADD CONSTRAINT fk_insert_logs_user FOREIGN KEY (user_id) REFERENCES users(id);
  END IF;
END $$;

-- Policy for audit_logs: allow users to view logs for their farm
DROP POLICY IF EXISTS "Users can view audit logs for their farm" ON audit_logs;
CREATE POLICY "Users can view audit logs for their farm"
ON audit_logs FOR SELECT
TO authenticated
USING (
  farm_id IN (
    SELECT farm_id FROM farm_members WHERE user_id = auth.uid()
  )
);

-- Policy for delete_logs: allow users to view delete logs for their farm
DROP POLICY IF EXISTS "Users can view delete logs for their farm" ON delete_logs;
CREATE POLICY "Users can view delete logs for their farm"
ON delete_logs FOR SELECT
TO authenticated
USING (
  farm_id IN (
    SELECT farm_id FROM farm_members WHERE user_id = auth.uid()
  )
);

-- Also allow insertion if needed (usually handled by triggers, but just in case)
DROP POLICY IF EXISTS "Allow authenticated insert to audit_logs" ON audit_logs;
CREATE POLICY "Allow authenticated insert to audit_logs"
ON audit_logs FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated insert to delete_logs" ON delete_logs;
CREATE POLICY "Allow authenticated insert to delete_logs"
ON delete_logs FOR INSERT
TO authenticated
WITH CHECK (true);
