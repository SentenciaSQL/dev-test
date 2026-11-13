# Alcance del MVP — AppTrial (nombre provisional)

> **Nombre comercial:** pendiente de definir.  
> **Nombre de trabajo:** AppTrial  
> **Moneda interna:** TestCredits (TC)

## Objetivo del MVP

Entregar una plataforma usable que permita a un desarrollador registrar una app Android, publicar una campaña de testing cerrado, reclutar testers en grupos, recibir evidencias/feedback y operar con créditos internos. Los pagos digitales se verifican solo vía Google Play Billing.

## Incluido en el MVP

| Área | Alcance |
|---|---|
| Identidad | Registro, login, refresh JWT, verificación de email, recuperación de contraseña |
| Perfil | Datos básicos, foto, país, idioma, roles DEVELOPER/TESTER |
| Dispositivos | Registro de dispositivos Android del tester |
| Aplicaciones | CRUD de apps del desarrollador (package name único por propietario) |
| Campañas | Crear/publicar/reclutar; estados básicos; cupos |
| Grupos | Grupos de 15 por defecto; asignación automática; estados de miembro |
| Misiones | Definición + envío de evidencias + revisión approve/reject |
| Feedback | Reportes de bugs y comentarios |
| Créditos | Wallet, ledger, reserva al crear campaña, recompensas al aprobar |
| Billing | Verificación de compras Google Play + paquetes de créditos (sandbox) |
| Notificaciones | Preferencias + envío FCM de eventos clave |
| Admin | Suspender usuario, ajustar créditos auditables, moderar evidencias |

## Excluido del MVP (Fases 7–8 / post-MVP)

- Microservicios
- Analíticas avanzadas y dashboards ricos
- Spring AI / OpenAI (solo diseño de interfaz)
- Equipos multi-usuario / API pública Studio
- SSE en tiempo real (diseñado; implementación posterior)
- Login social Google (opcional; se añade si aporta valor sin retrasar auth)
- iOS / React Native / Ionic / UI nativa Android
- Tests automatizados de cualquier tipo

## Criterios de éxito del MVP

1. Un usuario puede actuar como desarrollador y tester con el mismo account.
2. Una campaña de 14 días / 15 testers reserva 300 TC y libera lo no usado.
3. Las recompensas solo se acreditan tras aprobación en backend.
4. Ningún crédito se modifica sin asiento en `credit_transactions`.
5. Las compras se acreditan solo tras verificación server-side con Google Play Developer API.
6. La app Flutter no decide precios, saldos ni permisos.

## Fases de implementación

1. Autenticación, usuarios, perfiles y dispositivos  
2. Aplicaciones y campañas  
3. Grupos de testers y asignaciones  
4. Misiones, evidencias y feedback  
5. Créditos, wallet y recompensas  
6. Google Play Billing y suscripciones  
7. Notificaciones y analíticas  
8. IA y administración avanzada  

Este repositorio inicia la **Fase 1** con el diseño completo, el esquema de datos y los contratos REST base.
