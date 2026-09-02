-- KARSU database schema (PostgreSQL)
-- Implements the entities described in product spec section 39, plus
-- supporting tables referenced elsewhere in the spec (opportunities,
-- news, iv_conversations, experiments, finance, team).
--
-- Conventions: UUID primary keys, created_at/updated_at on every table,
-- foreign keys with ON DELETE CASCADE scoped to the owning user/business
-- so account deletion (spec 48.3) can cascade cleanly.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------------
-- Users
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                TEXT NOT NULL,
    email               TEXT NOT NULL UNIQUE,
    country             TEXT,
    city_region         TEXT,
    preferred_language  TEXT,
    firebase_uid        TEXT UNIQUE,
    password_hash       TEXT,
    onboarding_completed_at TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Business profiles
-- ---------------------------------------------------------------------
CREATE TABLE business_profiles (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_type       TEXT[],                    -- software / hardware / service / etc
    industry            TEXT,
    idea                TEXT,
    problem             TEXT,
    target_customer     TEXT,
    proposed_solution   TEXT,
    stage               TEXT NOT NULL DEFAULT 'idea'
                         CHECK (stage IN ('idea','research','validation','prototype',
                                           'mvp','launch','early_revenue','growth','scale')),
    existing_customers  BOOLEAN DEFAULT FALSE,
    existing_prototype  BOOLEAN DEFAULT FALSE,
    existing_revenue    BOOLEAN DEFAULT FALSE,
    short_term_goal_30d TEXT,
    long_term_goal_1y   TEXT,
    vision_5y           TEXT,
    budget_available    NUMERIC(14,2),
    hours_per_day       NUMERIC(4,2),
    days_per_week       INT,
    available_time_minutes_per_day INT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_business_profiles_user ON business_profiles(user_id);

-- ---------------------------------------------------------------------
-- Skills / capability assessment
-- ---------------------------------------------------------------------
CREATE TABLE skills (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category            TEXT NOT NULL,   -- technical / business / personal
    skill_name          TEXT NOT NULL,   -- e.g. 'marketing', 'sales', 'leadership'
    score                INT NOT NULL CHECK (score BETWEEN 0 AND 100),
    assessment_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_skills_user ON skills(user_id);

-- ---------------------------------------------------------------------
-- Roadmaps & milestones
-- ---------------------------------------------------------------------
CREATE TABLE roadmaps (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    stage               TEXT NOT NULL,
    completion_pct      INT NOT NULL DEFAULT 0 CHECK (completion_pct BETWEEN 0 AND 100),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE milestones (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    roadmap_id          UUID NOT NULL REFERENCES roadmaps(id) ON DELETE CASCADE,
    title               TEXT NOT NULL,
    target_date         DATE,
    completed_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Tasks (daily/weekly activity engine)
-- ---------------------------------------------------------------------
CREATE TABLE tasks (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    milestone_id        UUID REFERENCES milestones(id) ON DELETE SET NULL,
    title               TEXT NOT NULL,
    description         TEXT,
    estimated_minutes   INT,
    difficulty          TEXT CHECK (difficulty IN ('easy','medium','hard')),
    purpose             TEXT,
    status              TEXT NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending','in_progress','completed','skipped')),
    scheduled_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_tasks_user_date ON tasks(user_id, scheduled_date);

-- ---------------------------------------------------------------------
-- Daily activities (end-of-day tracking log)
-- ---------------------------------------------------------------------
CREATE TABLE daily_activities (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date       DATE NOT NULL DEFAULT CURRENT_DATE,
    tasks_completed     INT DEFAULT 0,
    hours_worked        NUMERIC(4,2),
    learning_hours      NUMERIC(4,2),
    customers_contacted INT DEFAULT 0,
    meetings            INT DEFAULT 0,
    networking_count    INT DEFAULT 0,
    ideas_generated     INT DEFAULT 0,
    experiments_run     INT DEFAULT 0,
    revenue             NUMERIC(14,2) DEFAULT 0,
    expenses            NUMERIC(14,2) DEFAULT 0,
    confidence_level    INT CHECK (confidence_level BETWEEN 1 AND 10),
    motivation_level    INT CHECK (motivation_level BETWEEN 1 AND 10),
    reflection          TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, activity_date)
);

-- ---------------------------------------------------------------------
-- Surveys (adaptive daily survey engine)
-- ---------------------------------------------------------------------
CREATE TABLE surveys (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    survey_date         DATE NOT NULL DEFAULT CURRENT_DATE,
    questions           JSONB NOT NULL DEFAULT '[]',
    responses           JSONB NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Experiments
-- ---------------------------------------------------------------------
CREATE TABLE experiments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    hypothesis          TEXT NOT NULL,
    experiment_desc     TEXT,
    target              TEXT,
    actual_result       TEXT,
    evidence            TEXT,
    conclusion          TEXT CHECK (conclusion IN ('supported','partially_supported','not_supported','inconclusive')),
    next_action         TEXT,
    start_date          DATE,
    end_date            DATE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Finance
-- ---------------------------------------------------------------------
CREATE TABLE finance_records (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    record_type         TEXT NOT NULL CHECK (record_type IN ('revenue','expense')),
    category            TEXT,
    amount              NUMERIC(14,2) NOT NULL,
    record_date         DATE NOT NULL DEFAULT CURRENT_DATE,
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Team
-- ---------------------------------------------------------------------
CREATE TABLE team_members (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name                TEXT,
    role                TEXT,
    responsibilities    TEXT,
    skills              TEXT[],
    availability        TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- News (industry intelligence — always source-attributed)
-- ---------------------------------------------------------------------
CREATE TABLE news_articles (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source              TEXT NOT NULL,
    headline            TEXT NOT NULL,
    published_date      DATE,
    industry            TEXT,
    summary             TEXT,
    url                 TEXT NOT NULL,
    ingested_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_news_industry ON news_articles(industry);

-- ---------------------------------------------------------------------
-- Opportunities (grants, programs, competitions — verified before display)
-- ---------------------------------------------------------------------
CREATE TABLE opportunities (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title               TEXT NOT NULL,
    source              TEXT NOT NULL,
    eligibility         TEXT,
    deadline            DATE,
    industry            TEXT,
    status              TEXT NOT NULL DEFAULT 'unverified'
                         CHECK (status IN ('unverified','verified','expired')),
    url                 TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Competitors / similar businesses
-- ---------------------------------------------------------------------
CREATE TABLE competitors (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                TEXT NOT NULL,
    industry            TEXT,
    product_or_service  TEXT,
    target_market       TEXT,
    business_model      TEXT,
    geographic_market   TEXT,
    website             TEXT,
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- IV conversations (AI chat history — user-controllable, spec 48.7)
-- ---------------------------------------------------------------------
CREATE TABLE iv_conversations (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mode                TEXT,
    message             TEXT NOT NULL,
    response            TEXT NOT NULL,
    context_snapshot    JSONB,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_iv_conversations_user ON iv_conversations(user_id, created_at);

-- ---------------------------------------------------------------------
-- Scores (entrepreneur development + business health, kept separate)
-- ---------------------------------------------------------------------
CREATE TABLE scores (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score_type          TEXT NOT NULL CHECK (score_type IN ('entrepreneur_development','business_health')),
    value               INT NOT NULL CHECK (value BETWEEN 0 AND 100),
    breakdown           JSONB,
    recorded_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_scores_user ON scores(user_id, score_type, recorded_at);

-- ---------------------------------------------------------------------
-- Notifications
-- ---------------------------------------------------------------------
CREATE TABLE notifications (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type                TEXT NOT NULL,   -- industry_alert / opportunity_alert / task_reminder / etc
    title               TEXT NOT NULL,
    body                TEXT,
    read_at             TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_notifications_user ON notifications(user_id, created_at);


-- ---------------------------------------------------------------------
-- Authentication sessions
-- ---------------------------------------------------------------------
CREATE TABLE auth_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_id TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_auth_sessions_user ON auth_sessions(user_id);
CREATE INDEX idx_auth_sessions_active ON auth_sessions(token_id, expires_at) WHERE revoked_at IS NULL;

-- User-scoped intelligence items created by the app/user. Global news/opportunities
-- remain separate and source-attributed.
CREATE TABLE user_intelligence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'insight',
    summary TEXT,
    source TEXT,
    url TEXT,
    priority TEXT NOT NULL DEFAULT 'normal',
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_user_intelligence_user ON user_intelligence(user_id, created_at DESC);
-- ---------------------------------------------------------------------
-- Privacy settings
-- ---------------------------------------------------------------------
CREATE TABLE privacy_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    analytics_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    ai_personalization_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    marketing_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    data_sharing_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- updated_at trigger helper
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_privacy_settings_updated_at BEFORE UPDATE ON privacy_settings FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_user_intelligence_updated_at BEFORE UPDATE ON user_intelligence
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_business_profiles_updated_at BEFORE UPDATE ON business_profiles
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();
CREATE TRIGGER trg_roadmaps_updated_at BEFORE UPDATE ON roadmaps
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

