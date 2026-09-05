# Contexto para agentes de IA

Instrucciones para Claude Code y agentes similares que trabajen en este repo.
Las personas pueden leerlo tambien: no hay nada oculto aca.

## Estado del proyecto

**Kickoff.** Hay infraestructura, documentacion y CI. **No hay codigo de
aplicacion ni contratos, y es a proposito.** El diseño se decide con el equipo.

> **No implementes funcionalidad sin que exista el ADR correspondiente** en
> `docs/architecture/decisions/`. Las decisiones abiertas estan listadas en
> `docs/architecture/README.md`. Si te piden algo que depende de una decision sin
> cerrar, decilo y proponé cerrarla primero.

## Que es esto

Tokenizacion de activos sobre Stellar. Las dos vias posibles — activo clasico con
SAC, o token Soroban SEP-41 propio — estan comparadas en
`docs/standards/tokenizacion-stellar.md`. **Todavia no elegimos.**

## Versiones fijadas

No las cambies sin decirlo explicitamente. El job `pins` de CI falla si la
documentacion y el workflow se desincronizan.

| Que | Version | Donde |
|---|---|---|
| Rust | `1.95.0` | `rust-toolchain.toml` |
| Target WASM | `wasm32v1-none` | `rust-toolchain.toml` |
| Stellar CLI | `28.0.0` | `docs/setup/`, `.github/workflows/ci.yml` |
| `soroban-sdk` | `27.0.6` | `Cargo.toml` (`workspace.dependencies`) |
| `@stellar/stellar-sdk` | `17.0.1` | pendiente, al crear `apps/web` |

**El target es `wasm32v1-none`, no `wasm32-unknown-unknown`.** El viejo compila
pero produce WASM que la red rechaza. Es el error mas comun con informacion
desactualizada.

## Estructura

```
contracts/   contratos Soroban (Rust)      — vacio
apps/web/    dApp                          — vacio
services/    off-chain: SEPs, KYC, anchor  — vacio
packages/    librerias compartidas         — vacio
infra/       Docker y red local            — listo
docs/        setup, arquitectura, SEPs     — listo
scripts/     diagnostico de entorno        — listo
```

Cada carpeta vacia tiene un README con lo que va adentro y que falta decidir.

## Convenciones

- **Documentacion en español**, sin acentos en nombres de archivo ni en scripts.
- **Scripts `.ps1`: cuerpo ASCII y guardados con BOM UTF-8.** Windows PowerShell
  5.1 lee sin BOM como ANSI y rompe el parseo con cualquier caracter no-ASCII.
- Commits: [Conventional Commits](https://www.conventionalcommits.org/).
- Contratos: sin `unwrap()` ni `panic!()`; errores como enum `#[contracterror]`.
- Aritmetica de balances: siempre variantes checked.
- **Nunca escribas una clave secreta (`S...`) en un archivo**, ni de testnet.

## Comandos

```sh
./scripts/check-env.sh                          # diagnostico (Windows: .ps1)
docker compose -f infra/compose.yaml --profile local up -d --wait
docker compose -f infra/compose.yaml --profile tools run --rm toolbox
cargo fmt --all --check && cargo clippy --all-targets -- -D warnings
stellar contract build
```

## Antes de responder sobre Stellar

La API de Soroban se movio mucho. Verifica contra la fuente antes de afirmar:

- [developers.stellar.org](https://developers.stellar.org/) — doc oficial
- [`stellar/stellar-dev-skill`](https://github.com/stellar/stellar-dev-skill) —
  skill oficial para agentes:
  `/plugin marketplace add stellar/stellar-dev-skill`
- [skills.stellar.org](https://skills.stellar.org/) — catalogo de skills
- [Raven](https://github.com/stellar-experimental/stellar-raven) — MCP server con
  doc y datos del ecosistema en vivo (`https://raven.stellar.org/mcp`)
- Skills de [stellar-build](https://github.com/orlando-vazquez-career/stellar-build)
  copiadas en `.claude/skills/` (34 skills; el router por fase esta en
  `.claude/skills/SKILL_ROUTER.md`). Se descubren al iniciar la sesion. La de
  revision de codigo se llama `adversarial-code-review` para no pisar el
  `/code-review` integrado de Claude Code.

Si tu conocimiento y la doc oficial difieren, gana la doc oficial. Decilo en vez
de improvisar.
