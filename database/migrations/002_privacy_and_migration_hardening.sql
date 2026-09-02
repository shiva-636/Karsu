-- KARSU v0.3.4 privacy and migration hardening.
-- Safe to run repeatedly.

ALTER TABLE privacy_settings
  ALTER COLUMN ai_personalization_opt_in SET DEFAULT FALSE;

-- Existing rows were created before explicit opt-in was enforced.
-- Treat the old implicit TRUE as not opted in. Users can explicitly opt in later.
UPDATE privacy_settings
SET ai_personalization_opt_in = FALSE
WHERE ai_personalization_opt_in IS TRUE;

-- Ensure every existing user has a privacy row with safe defaults.
INSERT INTO privacy_settings (user_id)
SELECT id FROM users
WHERE NOT EXISTS (SELECT 1 FROM privacy_settings p WHERE p.user_id = users.id);
