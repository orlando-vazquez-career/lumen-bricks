# contracts/

Contratos Soroban en Rust. **Vacio a proposito** — el diseño se define con el
equipo antes de escribir codigo.

## Como se agrega un contrato

```sh
stellar contract init contracts/<nombre> --name <nombre>
```

Despues registralo en el workspace raiz (`Cargo.toml`):

```toml
[workspace]
members = ["contracts/<nombre>"]
```

Y usa la dependencia centralizada, para que todos los contratos compilen contra
el mismo SDK:

```toml
[dependencies]
soroban-sdk = { workspace = true }
```

## Convenciones acordadas

- Un contrato por carpeta, en `snake_case`.
- Los tests unitarios van en `src/test.rs` dentro del mismo crate; los de
  integracion entre contratos, en un crate aparte.
- Nada de `unwrap()` ni `panic!()` en rutas de ejecucion: usa `panic_with_error!`
  con un enum `#[contracterror]` para que el cliente reciba un codigo estable.
- `overflow-checks = true` esta activo tambien en release (ver `Cargo.toml` raiz).
  No lo apagues: en un contrato de tokenizacion, un overflow silencioso es dinero.

## Comandos

```sh
stellar contract build                    # compila a wasm32v1-none
cargo test                                # tests unitarios
stellar contract optimize --wasm <path>   # reduce el tamaño del WASM
```

## Decisiones abiertas

Estas se resuelven en [`docs/architecture/decisions/`](../docs/architecture/decisions/)
antes de la primera linea de codigo:

- [ ] Activo clasico + SAC, token Soroban SEP-41 propio, o hibrido
- [ ] Modelo de control de acceso (admin unico, multisig, timelock)
- [ ] Estrategia de upgrade: contrato inmutable o `update_current_contract_wasm`
- [ ] Donde vive el KYC/whitelist: on-chain, off-chain con firma, o flags clasicos
- [ ] Politica de clawback y congelamiento (que exige el marco regulatorio)

Contexto de las opciones: [`docs/standards/tokenizacion-stellar.md`](../docs/standards/tokenizacion-stellar.md)
