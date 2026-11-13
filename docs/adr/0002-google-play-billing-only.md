# ADR 0002 — Solo Google Play Billing

## Estado
Aceptado

## Contexto
La monetización es venta de moneda virtual y suscripciones dentro de una app Android distribuida por Play.

## Decisión
Todos los pagos digitales de la app se procesan exclusivamente con Google Play Billing + Developer API + RTDN. No Stripe/PayPal/Paddle/etc.

## Consecuencias
(+) Cumplimiento de políticas de productos digitales de Play.  
(+) Un solo flujo de verificación server-side.  
(−) Sin cobro web directo en MVP; futuras expansiones requerirían nuevo ADR.
