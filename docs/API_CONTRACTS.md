# Contratos REST — AppTrial API v1

Base URL: `/api/v1`  
Auth: `Authorization: Bearer <access_token>`  
Content-Type: `application/json`  
Errores: `{ "code": "...", "message": "...", "details": [] }`  
Paginación: `?page=0&size=20` → `{ items, page, size, totalElements, totalPages }`

## Fase 1 — Identity & Users

### POST /auth/register
Body: `{ email, password, displayName, roles: ["DEVELOPER"|"TESTER"] }`  
→ 201 `{ userId, email, roles }` + email de verificación.

### POST /auth/login
Body: `{ email, password }` → `{ accessToken, refreshToken, expiresIn, user }`

### POST /auth/refresh
Body: `{ refreshToken }` → nuevos tokens (rotación).

### POST /auth/logout
Invalida refresh token actual.

### POST /auth/verify-email
Body: `{ token }`

### POST /auth/forgot-password
Body: `{ email }` → 202 siempre (anti-enumeración).

### POST /auth/reset-password
Body: `{ token, newPassword }`

### GET /me
Perfil del usuario autenticado.

### PATCH /me
Actualiza displayName, countryCode, locale, photoUrl, notificationPreferences.

### GET /me/devices · POST /me/devices · DELETE /me/devices/{id}

## Fase 2 — Applications & Campaigns

### /applications CRUD (owner)
### POST /campaigns · GET /campaigns/{id} · PATCH · POST /{id}/publish
### GET /campaigns/explore (tester) con filtros país/android

## Fase 3 — Groups

### GET /campaigns/{id}/groups
### POST /campaigns/{id}/groups/{groupId}/join
### PATCH /group-members/{id}/status (confirm / drop) — con reglas de backend

## Fase 4 — Missions / Evidence / Feedback

### CRUD misiones (developer owner)
### POST /missions/{id}/submissions
### POST /submissions/{id}/evidence (presigned upload flow)
### POST /campaigns/{id}/feedback

## Fase 5 — Credits

### GET /wallet
### GET /wallet/transactions
*(Mutaciones solo vía servicios internos / billing / rewards)*

## Fase 6 — Billing

### GET /billing/products
### POST /billing/purchases/verify  
Headers: `Idempotency-Key`  
Body: `{ productId, purchaseToken, packageName }`  
→ acredita créditos o activa suscripción tras verify con Google.

### POST /billing/rtdn (interno, Pub/Sub push)

## SSE (futuro)

`GET /campaigns/{id}/events` — text/event-stream para progreso.
