# Arquitectura — AppTrial (nombre provisional)

## 1. Visión

Monolito modular en **Kotlin + Spring Boot 4** como única autoridad de negocio, y cliente **Flutter + Dart** exclusivo para Android. Comunicación REST/JSON; SSE para progreso de campañas (`/campaigns/{id}/events`).

```
┌──────────────────────────┐
│  Flutter Android App     │
│  Riverpod · GoRouter     │
│  Dio · Secure Storage    │
│  IAP · FCM · Pickers     │
└────────────┬─────────────┘
             │ HTTPS / JWT
             ▼
┌──────────────────────────┐     ┌─────────────┐
│  Spring Boot Modular     │────▶│ PostgreSQL  │
│  Web MVC · Security      │     └─────────────┘
│  JPA · Flyway · AI*      │     ┌─────────────┐
└───┬──────────┬───────┬───┘────▶│ Redis       │
    │          │       │         └─────────────┘
    ▼          ▼       ▼
  S3        FCM    Google Play
 evidencias  push  Developer API
                   + RTDN/PubSub
```

\* Spring AI a partir de Fase 8.

## 2. Decisiones clave

| Decisión | Elección | Motivo |
|---|---|---|
| Nombre comercial | Pendiente (`AppTrial` de trabajo) | Evitar marca de terceros |
| Estilo de despliegue | Monolito modular | Velocidad MVP, consistencia financiera |
| UI móvil | Flutter únicamente | Requisito de producto |
| Backend | Kotlin + Spring Boot 4 + Java 21 | Requisito + LTS |
| Pagos | Solo Google Play Billing | Política de productos digitales |
| Auth | JWT access + refresh rotativo | Móvil-friendly, sin sesión sticky |
| Créditos | Ledger inmutable + reservas | Auditoría y concurrencia |
| Almacenamiento de evidencias | S3 + URLs firmadas | Privacidad y escalado |
| Caché / rate limit | Redis | Protección y temporales |
| Migraciones | Flyway | Evolución controlada del esquema |
| Tests automatizados | Ninguno en este proyecto | Requisito explícito |

## 3. Módulos backend

Paquetes bajo `com.apptrial.backend.*` (un solo artefacto JAR):

| Módulo | Responsabilidad |
|---|---|
| `shared` | Config, seguridad, errores, paginación, auditoría |
| `identity` | Auth, tokens, verificación email, sesiones |
| `users` | Perfil, roles, reputación, preferencias |
| `applications` | Apps Android del desarrollador |
| `campaigns` | Campañas y ciclo de vida |
| `testergroups` | Grupos, cupos, membresía |
| `missions` | Misiones de campaña |
| `evidence` | Archivos y metadatos |
| `feedback` | Feedback y bugs |
| `credits` | Wallet, ledger, reservas, recompensas |
| `billing` | Verificación Google Play, productos, órdenes |
| `subscriptions` | Planes y ciclo de vida de suscripción |
| `notifications` | Preferencias + FCM |
| `analytics` | Métricas agregadas (post-MVP) |
| `aiassistant` | Resúmenes y clustering (post-MVP) |
| `administration` | Moderación y ajustes auditables |

Regla: los módulos de dominio no dependen de Flutter. Las reglas financieras viven solo en `credits` + `billing`.

## 4. Capas Flutter

Organización por feature (`lib/features/<feature>/{presentation,domain,data}`) más `lib/core`.

| Feature | Notas |
|---|---|
| authentication | Login/registro; tokens en Secure Storage |
| profile / devices | Perfil y dispositivos |
| applications / campaigns | Panel desarrollador |
| tester_groups / missions / evidence / feedback | Flujo tester |
| wallet / billing / subscriptions | Solo UI; backend decide montos |
| notifications / settings | Preferencias y FCM |
| analytics / ai_assistant | Métricas y insights |
| administration | Moderación, antifraude, auditoría |

## 5. Seguridad

- Spring Security + JWT Bearer
- Autorización por rol **y** propiedad del recurso
- Validación Bean Validation en entrada
- Rate limiting Redis en auth y compras
- Evidencias privadas vía URL firmada S3 (TTL corto)
- Secretos vía variables de entorno / secret manager
- Idempotency-Key en compras y acreditaciones
- No confiar en precios/saldos enviados por el cliente

## 6. Integraciones externas

| Sistema | Uso | Fase |
|---|---|---|
| PostgreSQL | Persistencia | 1 |
| Redis | Caché, rate limit, tokens temporales | 1 |
| SMTP / proveedor email | Verificación y reset | 1 |
| AWS S3 | Evidencias | 4 |
| FCM | Push | 7 |
| Google Play Developer API | Verify/acknowledge/consume | 6 |
| Pub/Sub RTDN | Renovaciones/reembolsos | 6 |
| OpenAI vía Spring AI | Insights | 8 |

## 7. Google Play closed testing (contexto de producto)

Según la documentación oficial de Play Console Help (*App testing requirements for new personal developer accounts*):

- Aplica a **cuentas personales** creadas después del **13 nov 2023**.
- Requiere closed test con **≥ 12 testers opted-in de forma continua durante 14 días** antes de solicitar acceso a producción.
- La plataforma usa **15 testers por defecto** como margen operativo.
- **No** se garantiza la aprobación de Google.
- **No** existe API oficial para consultar la permanencia opted-in en Play; AppTrial registra confirmaciones y evidencias propias.
- **Prohibido:** simular instalaciones, actividad ficticia o manipular métricas de Play.

## 8. Economía TestCredits (propuesta inicial)

Costos por tester: 12 / 20 / 30 TC (7 / 14 / 30 días).  
Tope orientativo de recompensa: 20 TC/tester en campaña estándar 14 días.  
Créditos no retirables ni convertibles a dinero real.

## 9. Observabilidad

Spring Actuator (`/actuator/health`, metrics), logs estructurados JSON, `audit_logs` para acciones sensibles.
