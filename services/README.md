# services/

Servicios off-chain. **Vacio a proposito.**

Todo lo que no puede vivir en un contrato: cumplimiento normativo, custodia de
secretos, integracion con sistemas del mundo real, e indexado.

## Candidatos

| Servicio | Para que | Estandar |
|---|---|---|
| **Anchor / rampa** | Entrada y salida de fiat | [SEP-24](https://developers.stellar.org/docs/anchoring-assets/) (interactivo), [SEP-6](https://developers.stellar.org/docs/anchoring-assets/) (programatico) |
| **Servidor de aprobacion** | Firmar transacciones de un activo regulado | [SEP-8](https://developers.stellar.org/docs/tokens/control-asset-access) |
| **Autenticacion** | Login probando control de una cuenta Stellar | [SEP-10](https://developers.stellar.org/docs/building-apps/authentication) |
| **KYC** | Recibir y validar datos del inversor | [SEP-12](https://developers.stellar.org/docs/anchoring-assets/) |
| **`stellar.toml`** | Metadata publica del emisor y del activo | [SEP-1](https://developers.stellar.org/docs/tokens/publishing-asset-info) |
| **Indexador** | Historico y reportes que RPC no cubre | — |

## Decisiones abiertas

- [ ] Lenguaje: Rust (comparte tipos con los contratos) o TypeScript (comparte con la web)
- [ ] Cuales de estos SEPs son obligatorios para nuestro caso regulatorio
- [ ] Donde se custodian las claves del emisor (HSM, KMS, multisig)
- [ ] Si el emisor usa `AUTH_REQUIRED` — eso obliga a tener servidor de aprobacion

> **Nota de cumplimiento.** Si el activo se ofrece en Chile, el tratamiento de
> datos del KYC cae bajo la Ley 21.719 (vigente desde diciembre 2026). Conviene
> resolverlo al diseñar, no despues.
