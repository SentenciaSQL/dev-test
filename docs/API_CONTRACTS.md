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

### GET /applications
Lista las aplicaciones del desarrollador autenticado.

### POST /applications
Body: `{ name, packageName, description?, category?, currentVersion?, playStoreUrl?, closedTestingUrl?, instructions?, screenshotUrls? }`  
→ 201 Application. Valida package único por propietario. Plan Free: máx. 1 app ACTIVE.

### GET /applications/{id}
### PATCH /applications/{id}
### DELETE /applications/{id}
Archiva (status=ARCHIVED). Soft-archive, no hard delete.

### GET /campaigns
Campañas creadas por el usuario.

### GET /campaigns/explore?country=&sdkInt=
Campañas en `PUBLISHED` o `RECRUITING` filtrables por país y SDK.

### GET /campaigns/{id}
Visible para el owner o si está en reclutamiento/activa.

### POST /campaigns
Body: `{ applicationId, name, description?, testType?, durationDays, startsAt?, targetTesters?, allowedCountries?, minAndroidSdk?, maxAndroidSdk?, instructions? }`  
→ DRAFT. Coste por tester: 7→12 TC, 14→20 TC, 30→30 TC. Free: 1 campaña no terminal.

### PATCH /campaigns/{id}
Solo en DRAFT.

### POST /campaigns/{id}/publish
Reserva `targetTesters * costPerTesterTc` en el wallet (idempotent) y pasa a `RECRUITING`.

### POST /campaigns/{id}/cancel
Libera reserva OPEN si existía; status `CANCELLED`.

## Fase 3 — Groups

Al publicar una campaña se crean grupos automáticamente (troceo por `defaultGroupSize=15`, mínimo 12).

### GET /campaigns/{campaignId}/groups
Lista grupos. El owner ve miembros; testers ven plazas y su membresía.

### POST /campaigns/{campaignId}/join
Asignación automática al primer grupo `RECRUITING` con plazas. Membresía inicial `ACCEPTED`.  
Si el grupo se llena → `READY`. Si se cubre el cupo de campaña → `FULL`.

### POST /campaigns/{campaignId}/groups/{groupId}/join
Unión manual a un grupo concreto (mismas validaciones).

### GET /me/groups
Grupos del tester autenticado.

### PATCH /group-members/{memberId}
Body: `{ status }`  
Transiciones: `ACCEPTED→CONFIRMED|DROPPED`, `CONFIRMED→ACTIVE|DROPPED`, `ACTIVE→DROPPED|COMPLETED`, `INVITED→ACCEPTED|DROPPED`.  
Self o owner/admin. Al abandonar se reabre reclutamiento si aplica.

### Cancelación de campaña
Cancela grupos y marca miembros ocupantes como `DROPPED`.

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
