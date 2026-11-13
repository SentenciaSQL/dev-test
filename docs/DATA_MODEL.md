# Modelo de datos — AppTrial

PostgreSQL + Flyway. UUIDs como PK salvo tablas de catálogo. Timestamps en UTC (`timestamptz`). Soft-delete solo donde aporta (users, applications); el ledger de créditos **nunca** se borra.

## Diagrama de relaciones (resumen)

```
users ─┬─ user_roles
       ├─ user_devices
       ├─ refresh_tokens
       ├─ tester_profiles
       ├─ credit_wallets ── credit_transactions
       │                 └── credit_reservations
       ├─ applications ── campaigns ─┬─ campaign_groups ── group_members
       │                             ├─ campaign_missions ── mission_submissions ── evidence_files
       │                             └─ feedback_reports
       ├─ orders ── payments
       └─ subscriptions ── subscription_plans

products (catálogo billing)
notifications
audit_logs
```

## Entidades principales

### users
| Columna | Tipo | Notas |
|---|---|---|
| id | UUID PK | |
| email | CITEXT UNIQUE | |
| password_hash | TEXT NULL | null si solo OAuth futuro |
| display_name | VARCHAR(120) | |
| photo_url | TEXT | |
| country_code | CHAR(2) | ISO 3166-1 |
| locale | VARCHAR(16) | |
| email_verified_at | TIMESTAMPTZ | |
| status | ENUM | ACTIVE, SUSPENDED, DELETED |
| reputation_score | NUMERIC(8,2) | default 0 |
| created_at / updated_at | TIMESTAMPTZ | |

### user_roles
UNIQUE(user_id, role) — roles: `DEVELOPER`, `TESTER`, `ADMIN`.

### user_devices
Dispositivos Android del tester: model, manufacturer, android_version, sdk_int, unique(user_id, device_fingerprint).

### applications
UNIQUE(owner_user_id, package_name). Campos: name, description, icon_url, category, current_version, play_store_url, closed_testing_url, instructions, status.

### campaigns
FK application_id. type, duration_days, starts_at, target_testers, allowed_countries[], min/max android, instructions, reward_budget_tc, status (`DRAFT`…`EXPIRED`).

### campaign_groups
target_size default 15. status: RECRUITING, READY, ACTIVE, COMPLETED, CANCELLED.

### group_members
Estados de participación: INVITED, ACCEPTED, CONFIRMED, ACTIVE, DROPPED, COMPLETED.  
UNIQUE(group_id, user_id). Timestamps por transición.

### campaign_missions / mission_submissions / evidence_files
Misiones tipadas; submissions con estados PENDING→APPROVED/REJECTED; evidencias en S3 (object_key, content_type, size).

### credit_wallets
available_balance, reserved_balance. Version para locking optimista.

### credit_transactions
Ledger append-only: type (PURCHASE, SUBSCRIPTION_GRANT, PROMOTIONAL, RESERVE, RELEASE, SPEND, REWARD, REFUND, ADMIN_ADJUST), amount signed, credit_origin, reference_type/id, idempotency_key UNIQUE.

### credit_reservations
Reserva por campaña/plaza; status OPEN/CONSUMED/RELEASED.

### products / orders / payments / subscription_plans / subscriptions
Catálogo Play (`credits_100`, … / `subscription_*`). Orders con purchase_token UNIQUE. Payments verificados contra Google. Suscripciones con estado y expiry.

### notifications / audit_logs
Preferencias en users o tabla dedicada; audit con actor, action, entity, payload JSONB.

## Índices clave

- `campaigns(status, starts_at)`
- `group_members(user_id, status)`
- `mission_submissions(mission_id, status)`
- `credit_transactions(wallet_id, created_at)`
- `payments(purchase_token)` UNIQUE
- `refresh_tokens(token_hash)` UNIQUE

## Reglas de eliminación

- Borrar usuario → anonimizar PII; conservar ledger y audit.
- Borrar campaña DRAFT → hard delete permitido.
- Campaña con actividad → solo CANCELLED.
- Transacciones de crédito → **nunca** DELETE.
