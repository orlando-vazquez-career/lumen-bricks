# Arquitectura

> **Estado: sin definir.** Este es un kickoff. Lo que sigue son las preguntas
> abiertas, no un diseño.

- [Vision general](overview.md) — el problema y las piezas en juego
- [Decisiones (ADRs)](decisions/) — registro de lo que se va cerrando

## Decisiones abiertas

Ordenadas por lo que bloquean. Las primeras condicionan a las demas.

| # | Decision | Bloquea | Estado |
|---|---|---|---|
| 1 | Modelo del activo: clasico + SAC, token SEP-41 propio, o hibrido | Todo lo on-chain | abierta |
| 2 | Jurisdiccion y marco regulatorio del activo | Decisiones 3, 4, 6 | abierta |
| 3 | Flags de control: `AUTH_REQUIRED` / `REVOCABLE` / `CLAWBACK` | Diseño del emisor — **irreversible tras la primera emision** | abierta |
| 4 | Donde vive el KYC/whitelist: on-chain, SEP-8, o flags clasicos | `services/` | abierta |
| 5 | Custodia de la clave emisora: multisig, HSM, KMS | Operacion y seguridad | abierta |
| 6 | Rampa fiat: SEP-24, SEP-6, anchor propio o de terceros | `services/`, alcance del producto | abierta |
| 7 | Estrategia de upgrade de contratos: inmutable vs actualizable | `contracts/` | abierta |
| 8 | Stack del frontend y wallets soportadas | `apps/web/` | abierta |
| 9 | Lenguaje de los servicios off-chain | `services/`, `packages/` | abierta |

Contexto tecnico para 1, 3 y 4:
[`docs/standards/tokenizacion-stellar.md`](../standards/tokenizacion-stellar.md).

> La decision 3 merece atencion especial: los flags de autorizacion **no se
> pueden aplicar retroactivamente**. Activar clawback despues de emitir no afecta
> a los tokens ya emitidos. Hay que resolverla antes de la primera emision en
> mainnet, incluso si el resto queda abierto.
