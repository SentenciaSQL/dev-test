# Plan de implementación

## Principios

1. Backend primero para cada capacidad; Flutter consume contratos estables.
2. Una fase = vertical slice usable (API + UI mínima).
3. Sin tests automatizados ni carpetas `test`/`*_test.dart` de producto.
4. No inventar APIs de Google; verificar docs oficiales en cada integración.
5. Economía TC tratada como propuesta hasta validación comercial.

## Orden

| Fase | Entregable | Dependencias |
|---|---|---|
| 0 | Docs, esquema Flyway, skeleton Flutter/Spring, Docker Compose | — |
| 1 | Auth JWT, perfil, dispositivos | Postgres, Redis, email |
| 2 | Apps + campañas | Fase 1 |
| 3 | Grupos + asignación | Fase 2 |
| 4 | Misiones, evidencias S3, feedback | Fase 3, S3 |
| 5 | Wallet + ledger + reservas/recompensas | Fase 4 |
| 6 | Play Billing + suscripciones + RTDN | Fase 5, Play Console |
| 7 | FCM + analíticas básicas | Fases previas |
| 8 | Spring AI + admin avanzado | Control de costos |
| 9 | SSE campañas + antifraude + auditoría | Fases 7–8 |

## Estado actual del repositorio

**Fases 0–9:** misiones/evidencias/feedback, ledger TC, Play Billing, notificaciones FCM (MOCK/FIREBASE stub), analíticas, Spring AI insights (con fallback heurístico), admin (suspend/créditos/antifraude), SSE de campañas y audit logs.

## DoD por fase

- Migraciones Flyway aplicadas
- Endpoints documentados en `API_CONTRACTS.md`
- Flutter muestra loading/error/empty
- Reglas de negocio críticas solo en backend
- Commit atómico y documentado
