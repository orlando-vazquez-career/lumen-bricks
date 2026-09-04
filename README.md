# lumen-bricks

Tokenizacion de activos sobre [Stellar](https://developers.stellar.org/).

> **Estado: kickoff.** Este repositorio contiene la base de trabajo — entorno,
> documentacion, infraestructura local y CI. **Todavia no hay codigo de
> aplicacion ni contratos**: el diseño se define con el equipo antes de escribir
> la primera linea. Ver [`docs/architecture/`](docs/architecture/) para las
> decisiones abiertas.

---

## Que hay aca

| Carpeta | Que va adentro | Estado |
|---|---|---|
| [`contracts/`](contracts/) | Contratos Soroban en Rust (el token, el registro de activos, lo que definamos) | vacio |
| [`apps/web/`](apps/web/) | dApp — conexion de wallet, emision, panel del inversor | vacio |
| [`services/`](services/) | Servicios off-chain: SEPs de anchor, KYC, oraculos, indexado | vacio |
| [`packages/`](packages/) | Librerias compartidas entre apps y servicios (tipos, cliente de contratos) | vacio |
| [`infra/`](infra/) | Docker, compose, red Stellar local | listo |
| [`docs/`](docs/) | Setup por SO, arquitectura, estandares (SEPs) | listo |
| [`scripts/`](scripts/) | Diagnostico de entorno | listo |

Cada carpeta vacia tiene un `README.md` que explica que corresponde poner ahi y
que decisiones faltan tomar.

---

## Arranque rapido

Tres pasos. El detalle por sistema operativo esta en [`docs/setup/`](docs/setup/).

### 1. Instalar el toolchain

<details>
<summary><b>macOS / Linux</b></summary>

```sh
# Rust (rustup toma la version de rust-toolchain.toml al entrar al repo)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Stellar CLI
curl -fsSL https://github.com/stellar/stellar-cli/raw/main/install.sh | sh
# o: brew install stellar-cli
```
</details>

<details>
<summary><b>Windows</b></summary>

```powershell
# Rust
winget install --id Rustlang.Rustup

# Stellar CLI: usa el binario oficial. En Windows, `cargo install` crashea
# a rustc y winget suele ir atrasado. Detalle en docs/setup/windows.md
$ver = "28.0.0"
Invoke-WebRequest -Uri "https://github.com/stellar/stellar-cli/releases/download/v$ver/stellar-cli-$ver-x86_64-pc-windows-msvc.tar.gz" -OutFile "$env:TEMP\stellar.tar.gz"
tar -xzf "$env:TEMP\stellar.tar.gz" -C "$env:USERPROFILE\.cargoin"
```
</details>

Guia completa: [Windows](docs/setup/windows.md) · [Linux](docs/setup/linux.md) · [macOS](docs/setup/macos.md)

### 2. Verificar

```sh
./scripts/check-env.sh          # macOS / Linux
```
```powershell
.\scripts\check-env.ps1         # Windows
```

El script chequea version de Rust, el target `wasm32v1-none`, la CLI de Stellar,
Docker y Node, y te dice exactamente que comando correr por cada cosa que falte.

### 3. Levantar la red local

```sh
cd infra && docker compose up -d stellar-local
```

Deja una red Stellar completa en `http://localhost:8000` (RPC, Horizon y
friendbot). Detalle en [`infra/README.md`](infra/README.md).

---

## Versiones fijadas

Estas son las versiones contra las que trabaja el repo. Cambiar cualquiera es una
decision de equipo, no individual — van fijadas en archivos versionados para que
nadie compile contra algo distinto.

| Herramienta | Version | Donde se fija |
|---|---|---|
| Rust | `1.95.0` | [`rust-toolchain.toml`](rust-toolchain.toml) |
| Target WASM | `wasm32v1-none` | [`rust-toolchain.toml`](rust-toolchain.toml) |
| Stellar CLI | `28.0.0` | [`docs/setup/`](docs/setup/), CI |
| `soroban-sdk` | `27.0.6` | [`Cargo.toml`](Cargo.toml) (`workspace.dependencies`) |
| `@stellar/stellar-sdk` (JS) | `17.0.1` | se fija al crear `apps/web` |
| Docker Engine | `>= 24` | — |
| Node.js | `22 LTS` | se fija con `.nvmrc` al crear `apps/web` |

> **`wasm32v1-none`, no `wasm32-unknown-unknown`.** Stellar migro de target. El
> viejo todavia compila pero produce WASM con imports que la red rechaza. Si ves
> un error de deploy sobre imports desconocidos, es esto.

---

## Contexto del dominio

Tokenizar un activo en Stellar tiene dos caminos, y **elegir entre ellos es la
primera decision de arquitectura pendiente**:

- **Activo clasico** — emitido por una cuenta emisora, con trustlines y flags de
  autorizacion (`AUTH_REQUIRED`, `AUTH_REVOCABLE`, `AUTH_CLAWBACK_ENABLED`).
  Barato, rapido, con DEX y path payments nativos. Se puede exponer a contratos
  via el **Stellar Asset Contract (SAC)**.
- **Token Soroban propio** — un contrato Rust que implementa
  [SEP-41](https://developers.stellar.org/docs/tokens/token-interface). Logica
  arbitraria (vesting, whitelist on-chain, reparto de dividendos), a cambio de
  mas superficie de auditoria.

Para un activo del mundo real casi siempre se termina en un hibrido, y entran
SEP-8 (activos regulados), SEP-10 (auth), SEP-12 (KYC) y SEP-24/SEP-6 (rampa
fiat). El mapa completo con enlaces esta en
[`docs/standards/tokenizacion-stellar.md`](docs/standards/tokenizacion-stellar.md).

---

## Documentacion

- [**Setup por SO**](docs/setup/) — Windows, Linux, macOS, paso a paso
- [**Docker**](infra/README.md) — red local, imagen de build reproducible, compose
- [**Arquitectura**](docs/architecture/) — vision y decisiones (ADRs)
- [**Estandares**](docs/standards/) — SEPs y patrones de tokenizacion
- [**Contribuir**](CONTRIBUTING.md) — flujo de ramas, commits, PRs
- [**Seguridad**](SECURITY.md) — manejo de claves y reporte de vulnerabilidades

## Referencias externas

- [Stellar Developer Docs](https://developers.stellar.org/)
- [Stellar Skills](https://skills.stellar.org/) — contexto de Stellar para agentes de IA
- [`stellar/stellar-dev-skill`](https://github.com/stellar/stellar-dev-skill)
- [`stellar-experimental/stellar-raven`](https://github.com/stellar-experimental/stellar-raven) — MCP server
- [`kaankacar/stellar-build`](https://github.com/kaankacar/stellar-build)
- [`stellar/stellar-docs`](https://github.com/stellar/stellar-docs)

## Licencia

[Apache-2.0](LICENSE)
