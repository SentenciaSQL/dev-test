-- AppTrial initial schema (provisional product name)
-- Ledger tables are append-oriented; no destructive cascades into credit_transactions.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "citext";

-- ========== Identity & users ==========

CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email               CITEXT NOT NULL,
    password_hash       TEXT,
    display_name        VARCHAR(120) NOT NULL,
    photo_url           TEXT,
    country_code        CHAR(2),
    locale              VARCHAR(16) NOT NULL DEFAULT 'en',
    email_verified_at   TIMESTAMPTZ,
    status              VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    reputation_score    NUMERIC(8, 2) NOT NULL DEFAULT 0,
    notification_prefs  JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT ck_users_status CHECK (status IN ('ACTIVE', 'SUSPENDED', 'DELETED'))
);

CREATE TABLE user_roles (
    user_id     UUID NOT NULL REFERENCES users(id),
    role        VARCHAR(32) NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, role),
    CONSTRAINT ck_user_roles_role CHECK (role IN ('DEVELOPER', 'TESTER', 'ADMIN'))
);

CREATE TABLE refresh_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash      VARCHAR(128) NOT NULL,
    expires_at      TIMESTAMPTZ NOT NULL,
    revoked_at      TIMESTAMPTZ,
    replaced_by_id  UUID REFERENCES refresh_tokens(id),
    user_agent      TEXT,
    ip_address      VARCHAR(64),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_refresh_tokens_hash UNIQUE (token_hash)
);

CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);

CREATE TABLE email_verification_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(128) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ NOT NULL,
    used_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE password_reset_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash  VARCHAR(128) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ NOT NULL,
    used_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_devices (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_fingerprint  VARCHAR(128) NOT NULL,
    model               VARCHAR(120),
    manufacturer        VARCHAR(120),
    android_version     VARCHAR(32) NOT NULL,
    sdk_int             INT,
    is_primary          BOOLEAN NOT NULL DEFAULT FALSE,
    last_seen_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_devices_fingerprint UNIQUE (user_id, device_fingerprint)
);

CREATE INDEX idx_user_devices_user ON user_devices(user_id);

CREATE TABLE tester_profiles (
    user_id                 UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    campaigns_completed     INT NOT NULL DEFAULT 0,
    campaigns_dropped       INT NOT NULL DEFAULT 0,
    bio                     TEXT,
    preferred_categories    TEXT[] NOT NULL DEFAULT '{}',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========== Applications & campaigns ==========

CREATE TABLE applications (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id       UUID NOT NULL REFERENCES users(id),
    name                VARCHAR(160) NOT NULL,
    description         TEXT,
    package_name        VARCHAR(255) NOT NULL,
    icon_url            TEXT,
    category            VARCHAR(64),
    current_version     VARCHAR(64),
    play_store_url      TEXT,
    closed_testing_url  TEXT,
    instructions        TEXT,
    status              VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_applications_owner_package UNIQUE (owner_user_id, package_name),
    CONSTRAINT ck_applications_status CHECK (status IN ('ACTIVE', 'ARCHIVED', 'SUSPENDED'))
);

CREATE INDEX idx_applications_owner ON applications(owner_user_id);

CREATE TABLE application_screenshots (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id  UUID NOT NULL REFERENCES applications(id) ON DELETE CASCADE,
    image_url       TEXT NOT NULL,
    sort_order      INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE campaigns (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id      UUID NOT NULL REFERENCES applications(id),
    created_by_user_id  UUID NOT NULL REFERENCES users(id),
    name                VARCHAR(160) NOT NULL,
    description         TEXT,
    test_type           VARCHAR(64) NOT NULL DEFAULT 'CLOSED',
    duration_days       INT NOT NULL,
    starts_at           TIMESTAMPTZ,
    ends_at             TIMESTAMPTZ,
    target_testers      INT NOT NULL DEFAULT 15,
    allowed_countries   CHAR(2)[] NOT NULL DEFAULT '{}',
    min_android_sdk     INT,
    max_android_sdk     INT,
    instructions        TEXT,
    status              VARCHAR(32) NOT NULL DEFAULT 'DRAFT',
    cost_per_tester_tc  INT NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_campaigns_status CHECK (status IN (
        'DRAFT', 'PUBLISHED', 'RECRUITING', 'FULL', 'ACTIVE', 'COMPLETED', 'CANCELLED', 'EXPIRED'
    )),
    CONSTRAINT ck_campaigns_duration CHECK (duration_days IN (7, 14, 30) OR duration_days > 0),
    CONSTRAINT ck_campaigns_target CHECK (target_testers >= 12)
);

CREATE INDEX idx_campaigns_app_status ON campaigns(application_id, status);
CREATE INDEX idx_campaigns_status_starts ON campaigns(status, starts_at);

CREATE TABLE campaign_groups (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id     UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    name            VARCHAR(120) NOT NULL,
    target_size     INT NOT NULL DEFAULT 15,
    starts_at       TIMESTAMPTZ,
    ends_at         TIMESTAMPTZ,
    status          VARCHAR(32) NOT NULL DEFAULT 'RECRUITING',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_campaign_groups_status CHECK (status IN (
        'RECRUITING', 'READY', 'ACTIVE', 'COMPLETED', 'CANCELLED'
    )),
    CONSTRAINT ck_campaign_groups_size CHECK (target_size >= 12)
);

CREATE INDEX idx_campaign_groups_campaign ON campaign_groups(campaign_id);

CREATE TABLE group_members (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id        UUID NOT NULL REFERENCES campaign_groups(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id),
    status          VARCHAR(32) NOT NULL DEFAULT 'INVITED',
    invited_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    accepted_at     TIMESTAMPTZ,
    confirmed_at    TIMESTAMPTZ,
    active_at       TIMESTAMPTZ,
    dropped_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_group_members UNIQUE (group_id, user_id),
    CONSTRAINT ck_group_members_status CHECK (status IN (
        'INVITED', 'ACCEPTED', 'CONFIRMED', 'ACTIVE', 'DROPPED', 'COMPLETED'
    ))
);

CREATE INDEX idx_group_members_user_status ON group_members(user_id, status);

-- ========== Missions, evidence, feedback ==========

CREATE TABLE campaign_missions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id         UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
    title               VARCHAR(160) NOT NULL,
    description         TEXT,
    instructions        TEXT,
    mission_type        VARCHAR(64) NOT NULL,
    reward_tc           INT NOT NULL DEFAULT 0,
    due_at              TIMESTAMPTZ,
    evidence_required   BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order          INT NOT NULL DEFAULT 0,
    status              VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_campaign_missions_status CHECK (status IN ('ACTIVE', 'DISABLED'))
);

CREATE TABLE mission_submissions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id      UUID NOT NULL REFERENCES campaign_missions(id),
    user_id         UUID NOT NULL REFERENCES users(id),
    description     TEXT,
    status          VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    reviewer_notes  TEXT,
    reviewed_by     UUID REFERENCES users(id),
    reviewed_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_mission_submissions UNIQUE (mission_id, user_id),
    CONSTRAINT ck_mission_submissions_status CHECK (status IN (
        'PENDING', 'SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'REJECTED'
    ))
);

CREATE INDEX idx_mission_submissions_status ON mission_submissions(mission_id, status);

CREATE TABLE evidence_files (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id   UUID NOT NULL REFERENCES mission_submissions(id) ON DELETE CASCADE,
    storage_key     TEXT NOT NULL,
    content_type    VARCHAR(128) NOT NULL,
    size_bytes      BIGINT NOT NULL,
    checksum_sha256 VARCHAR(64),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE feedback_reports (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id     UUID NOT NULL REFERENCES campaigns(id),
    user_id         UUID NOT NULL REFERENCES users(id),
    report_type     VARCHAR(32) NOT NULL,
    title           VARCHAR(200) NOT NULL,
    body            TEXT NOT NULL,
    severity        VARCHAR(32),
    status          VARCHAR(32) NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_feedback_type CHECK (report_type IN ('BUG', 'FEEDBACK', 'OTHER')),
    CONSTRAINT ck_feedback_status CHECK (status IN ('OPEN', 'TRIAGED', 'RESOLVED', 'DISMISSED'))
);

-- ========== Credits ==========

CREATE TABLE credit_wallets (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL UNIQUE REFERENCES users(id),
    available_balance   INT NOT NULL DEFAULT 0,
    reserved_balance    INT NOT NULL DEFAULT 0,
    version             BIGINT NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_wallet_available CHECK (available_balance >= 0),
    CONSTRAINT ck_wallet_reserved CHECK (reserved_balance >= 0)
);

CREATE TABLE credit_transactions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id           UUID NOT NULL REFERENCES credit_wallets(id),
    entry_type          VARCHAR(32) NOT NULL,
    amount_tc           INT NOT NULL,
    credit_origin       VARCHAR(32),
    balance_after       INT NOT NULL,
    reserved_after      INT NOT NULL,
    reference_type      VARCHAR(64),
    reference_id        UUID,
    idempotency_key     VARCHAR(128),
    metadata            JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_credit_tx_idempotency UNIQUE (idempotency_key),
    CONSTRAINT ck_credit_tx_type CHECK (entry_type IN (
        'PURCHASE', 'SUBSCRIPTION_GRANT', 'PROMOTIONAL', 'RESERVE', 'RELEASE',
        'SPEND', 'REWARD', 'REFUND', 'ADMIN_ADJUST'
    )),
    CONSTRAINT ck_credit_origin CHECK (
        credit_origin IS NULL OR credit_origin IN ('PURCHASED', 'SUBSCRIPTION', 'PROMOTIONAL')
    )
);

CREATE INDEX idx_credit_tx_wallet_created ON credit_transactions(wallet_id, created_at DESC);

CREATE TABLE credit_reservations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id       UUID NOT NULL REFERENCES credit_wallets(id),
    campaign_id     UUID NOT NULL REFERENCES campaigns(id),
    amount_tc       INT NOT NULL,
    status          VARCHAR(32) NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_credit_reservations_status CHECK (status IN ('OPEN', 'CONSUMED', 'RELEASED')),
    CONSTRAINT ck_credit_reservations_amount CHECK (amount_tc > 0)
);

CREATE INDEX idx_credit_reservations_campaign ON credit_reservations(campaign_id, status);

-- ========== Billing & subscriptions ==========

CREATE TABLE products (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku             VARCHAR(64) NOT NULL UNIQUE,
    product_type    VARCHAR(32) NOT NULL,
    title           VARCHAR(120) NOT NULL,
    credits_tc      INT,
    price_usd_cents INT,
    active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_products_type CHECK (product_type IN ('CONSUMABLE_CREDITS', 'SUBSCRIPTION'))
);

CREATE TABLE subscription_plans (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code                VARCHAR(32) NOT NULL UNIQUE,
    sku                 VARCHAR(64) REFERENCES products(sku),
    monthly_credits_tc  INT NOT NULL DEFAULT 0,
    max_projects        INT,
    price_usd_cents     INT NOT NULL DEFAULT 0,
    active              BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE orders (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    product_id      UUID NOT NULL REFERENCES products(id),
    status          VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_orders_status CHECK (status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED', 'CANCELLED'))
);

CREATE TABLE payments (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id                UUID NOT NULL REFERENCES orders(id),
    user_id                 UUID NOT NULL REFERENCES users(id),
    purchase_token          TEXT NOT NULL,
    play_order_id           TEXT,
    package_name            VARCHAR(255) NOT NULL,
    raw_verification        JSONB,
    status                  VARCHAR(32) NOT NULL DEFAULT 'VERIFIED',
    acknowledged_at         TIMESTAMPTZ,
    consumed_at             TIMESTAMPTZ,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_payments_purchase_token UNIQUE (purchase_token),
    CONSTRAINT ck_payments_status CHECK (status IN (
        'VERIFIED', 'ACKNOWLEDGED', 'CONSUMED', 'REFUNDED', 'REVOKED', 'FAILED'
    ))
);

CREATE TABLE subscriptions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id),
    plan_id             UUID NOT NULL REFERENCES subscription_plans(id),
    purchase_token      TEXT,
    status              VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    current_period_end  TIMESTAMPTZ,
    cancelled_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT ck_subscriptions_status CHECK (status IN (
        'ACTIVE', 'PAST_DUE', 'CANCELLED', 'EXPIRED', 'REVOKED'
    ))
);

CREATE INDEX idx_subscriptions_user ON subscriptions(user_id, status);

-- ========== Notifications & audit ==========

CREATE TABLE notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type      VARCHAR(64) NOT NULL,
    title           VARCHAR(200) NOT NULL,
    body            TEXT NOT NULL,
    payload         JSONB NOT NULL DEFAULT '{}'::jsonb,
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_created ON notifications(user_id, created_at DESC);

CREATE TABLE push_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    fcm_token       TEXT NOT NULL,
    platform        VARCHAR(32) NOT NULL DEFAULT 'ANDROID',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_push_tokens UNIQUE (user_id, fcm_token)
);

CREATE TABLE audit_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id   UUID REFERENCES users(id),
    action          VARCHAR(64) NOT NULL,
    entity_type     VARCHAR(64) NOT NULL,
    entity_id       UUID,
    ip_address      VARCHAR(64),
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id, created_at DESC);

-- Seed catalog products (prices provisional)
INSERT INTO products (sku, product_type, title, credits_tc, price_usd_cents) VALUES
    ('credits_100',  'CONSUMABLE_CREDITS', 'Starter 100 TC',  100,  499),
    ('credits_250',  'CONSUMABLE_CREDITS', 'Basic 250 TC',    250,  999),
    ('credits_600',  'CONSUMABLE_CREDITS', 'Growth 600 TC',   600, 1999),
    ('credits_1500', 'CONSUMABLE_CREDITS', 'Business 1500 TC',1500, 3999),
    ('subscription_developer', 'SUBSCRIPTION', 'Developer plan', NULL, 900),
    ('subscription_pro',       'SUBSCRIPTION', 'Pro plan',       NULL, 1900),
    ('subscription_studio',    'SUBSCRIPTION', 'Studio plan',    NULL, 3900);

INSERT INTO subscription_plans (code, sku, monthly_credits_tc, max_projects, price_usd_cents) VALUES
    ('FREE',       NULL,                     20,   1,    0),
    ('DEVELOPER',  'subscription_developer', 150,  3,  900),
    ('PRO',        'subscription_pro',       400, 10, 1900),
    ('STUDIO',     'subscription_studio',   1000, NULL, 3900);
