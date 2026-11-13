# ADR 0003 — Ledger inmutable de TestCredits

## Estado
Aceptado

## Contexto
Créditos impulsan reclutamiento y recompensas; errores de concurrencia o doble gasto son riesgos de negocio.

## Decisión
Saldos en `credit_wallets` derivados/actualizados solo junto a asientos append-only en `credit_transactions`, con idempotency keys, reservas (`credit_reservations`) y locking optimista.

## Consecuencias
(+) Auditoría completa y reembolsos trazables.  
(−) Más complejidad que un contador simple.
