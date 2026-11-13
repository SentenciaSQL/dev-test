# ADR 0001 — Monolito modular

## Estado
Aceptado

## Contexto
Se necesita consistencia financiera (créditos, reservas, billing) y velocidad de MVP sin orquestación distribuida.

## Decisión
Un único despliegue Spring Boot organizado por paquetes/módulos de dominio. Sin microservicios en MVP.

## Consecuencias
(+) Transacciones ACID entre campañas y créditos.  
(+) Operación más simple.  
(−) Límites de escalado independiente por módulo; se revisará tras product-market fit.
