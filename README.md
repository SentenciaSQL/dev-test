# AppTrial (nombre provisional)

Plataforma comercial para conectar desarrolladores de aplicaciones Android con testers.  
**El nombre comercial definitivo está pendiente.** No utilizar marcas de terceros.

## Stack obligatorio

| Capa | Tecnología |
|---|---|
| Móvil | Flutter + Dart (solo Android) |
| Backend | Kotlin + Spring Boot 4 + Java 21 |
| DB | PostgreSQL |
| Caché | Redis |
| Archivos | AWS S3 |
| Pagos | Solo Google Play Billing |
| Moneda interna | TestCredits (TC) |

## Estructura del monorepo

```
backend/     Monolito modular Spring Boot
mobile/      App Flutter (feature-first)
docs/        Arquitectura, MVP, modelo de datos, ADRs, OpenAPI
infra/       docker-compose (Postgres, Redis, LocalStack S3)
```

## Documentación

- [Alcance MVP](docs/MVP.md)
- [Arquitectura](docs/ARCHITECTURE.md)
- [Modelo de datos](docs/DATA_MODEL.md)
- [Contratos REST](docs/API_CONTRACTS.md)
- [Plan de implementación](docs/IMPLEMENTATION_PLAN.md)
- [ADRs](docs/adr/)

## Estado actual

**Fases 0–6:** misiones/evidencias/feedback, ledger con recompensas y SPEND por plaza, Google Play Billing (verify MOCK/GOOGLE + RTDN stub).

No se incluyen tests automatizados (restricción del proyecto).

## Arranque local

### Infra

```bash
docker compose -f infra/docker-compose.yml up -d
```

### Backend

```bash
cd backend
./gradlew bootJar
JWT_SECRET='local-dev-secret-at-least-32-characters' java -jar build/libs/apptrial-backend-0.1.0-SNAPSHOT.jar
```

API: `http://localhost:8080/api/v1`  
Health: `http://localhost:8080/actuator/health`

### Flutter

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

## Módulos backend

`identity` · `users` · `applications` · `campaigns` · `testergroups` · `missions` · `evidence` · `feedback` · `credits` · `billing` · `subscriptions` · `notifications` · `analytics` · `aiassistant` · `administration`

## Reglas clave

- El backend es la única autoridad para créditos, precios, permisos y pagos.
- No Stripe/PayPal ni pasarelas externas para compras digitales de la app.
- No simular participación ni manipular métricas de Google Play.
- Campañas por defecto: **15 testers** (margen sobre el requisito de 12 / 14 días de cuentas personales nuevas en Play).
