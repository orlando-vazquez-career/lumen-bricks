# Setup del entorno

Elegi tu sistema operativo:

- [**Windows**](windows.md) — nativo (MSVC) o WSL2
- [**Linux**](linux.md) — Debian/Ubuntu, Fedora, Arch
- [**macOS**](macos.md) — Apple Silicon e Intel

O salteate todo y [usa Docker](../../infra/README.md#opcion-b-desarrollar-dentro-del-contenedor):
la imagen de build trae el toolchain completo y no toca tu maquina.

## Lo que vas a instalar, y por que

| Herramienta | Version | Para que |
|---|---|---|
| **rustup** | cualquiera reciente | Instala y cambia versiones de Rust. El repo fija la version via `rust-toolchain.toml`, asi que no elegis vos. |
| **Rust** | `1.95.0` | Compila los contratos. Stellar exige `>= 1.84`; nosotros fijamos una version exacta para builds reproducibles. |
| **target `wasm32v1-none`** | — | El formato WASM que acepta la red. **No** es `wasm32-unknown-unknown`. |
| **Stellar CLI** | `28.0.0` | Compilar, desplegar e invocar contratos; manejar identidades y redes. |
| **Docker** | `>= 24` | Red Stellar local y builds reproducibles. |
| **Node.js** | `22 LTS` | Solo para la dApp (`apps/web`). Todavia no hace falta. |

## Verificacion

Cualquiera sea el camino, terminas corriendo el mismo diagnostico:

```sh
./scripts/check-env.sh      # macOS / Linux
```
```powershell
.\scripts\check-env.ps1     # Windows
```

Salida esperada: todo en `OK`. Cada `FALTA` viene con el comando exacto para
resolverlo.
