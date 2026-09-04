# Vision general

> Borrador de kickoff. Se completa con el equipo.

## Problema

<!-- Que activo se tokeniza, para quien, y que gana con estar en cadena.
     Una tokenizacion que no mejora liquidez, fraccionamiento, transparencia o
     costo de liquidacion no justifica la complejidad. -->

_Pendiente._

## Por que Stellar

Argumentos que aplican a un activo del mundo real, para validar o descartar:

- Costo por operacion en el orden de fracciones de centavo, y finalidad en ~5 s.
- Emision de activos y controles de autorizacion **en el protocolo**, no en
  codigo propio a auditar.
- DEX y path payments nativos: liquidez y conversion sin desplegar un AMM.
- Estandares de anchor (SEP-6/24) ya adoptados para la rampa fiat.
- Soroban cubre la logica a medida cuando el protocolo no alcanza.

## Piezas

```
                      ┌──────────────────┐
   Inversor ───────►  │   apps/web       │  wallet, emision, panel
                      └────────┬─────────┘
                               │
              ┌────────────────┼─────────────────┐
              ▼                                  ▼
     ┌──────────────────┐              ┌──────────────────┐
     │   services/      │              │   Stellar RPC    │
     │  KYC · SEP-8     │              │   / Horizon      │
     │  anchor · indexer│              └────────┬─────────┘
     └────────┬─────────┘                       │
              │                                 ▼
              │                      ┌──────────────────────┐
              └─────────────────────►│  Red Stellar         │
                                     │  activo + contracts/ │
                                     └──────────────────────┘
```

## Fuera de alcance (por ahora)

<!-- Escribir esto explicitamente ahorra discusiones despues. -->

_Pendiente._

## Riesgos

| Riesgo | Impacto | Mitigacion |
|---|---|---|
| Compromiso de la clave emisora | Total — el activo entero | Multisig con umbral + custodia en HSM/KMS |
| Flags de autorizacion mal elegidos | Alto — no son retroactivos | Cerrar la decision 3 antes de emitir en mainnet |
| Cambio regulatorio | Medio/alto | Preferir controles del protocolo sobre logica propia |
| Bug en contrato desplegado | Alto | Auditoria + decidir la estrategia de upgrade (decision 7) |
| Falta de liquidez en el DEX | Medio | Evaluar market maker o pool desde el diseño |
