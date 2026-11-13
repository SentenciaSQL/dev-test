-- Optional tracking for AI token/cost control and simple abuse counters.

CREATE TABLE IF NOT EXISTS ai_usage_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES users(id),
    campaign_id     UUID REFERENCES campaigns(id),
    mode            VARCHAR(32) NOT NULL,
    input_chars     INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_usage_user_created ON ai_usage_logs(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS rate_limit_buckets (
    bucket_key      VARCHAR(128) PRIMARY KEY,
    hit_count       INT NOT NULL DEFAULT 0,
    window_started  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
