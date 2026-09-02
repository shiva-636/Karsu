-- KARSU v0.3 safe migration for an existing database.
-- Existing users whose password cannot be recovered must set a new password
-- through an administrative/user-verification flow before they can log in.
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS onboarding_completed_at TIMESTAMPTZ;
ALTER TABLE business_profiles ADD COLUMN IF NOT EXISTS available_time_minutes_per_day INT;
CREATE TABLE IF NOT EXISTS auth_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_id TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_user ON auth_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_active ON auth_sessions(token_id, expires_at) WHERE revoked_at IS NULL;
CREATE TABLE IF NOT EXISTS user_intelligence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL, type TEXT NOT NULL DEFAULT 'insight', summary TEXT, source TEXT, url TEXT,
  priority TEXT NOT NULL DEFAULT 'normal', status TEXT NOT NULL DEFAULT 'active', created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS privacy_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(), user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  analytics_opt_in BOOLEAN NOT NULL DEFAULT FALSE, ai_personalization_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
  marketing_opt_in BOOLEAN NOT NULL DEFAULT FALSE, data_sharing_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(), updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
