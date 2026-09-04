# Setup — macOS

Vale igual para Apple Silicon (M1–M4) e Intel. Donde hay diferencia, esta marcada.

## 1. Herramientas de linea de comandos de Xcode

```sh
xcode-select --install
```

Trae el linker y los headers de C que Rust necesita. Si ya tenes Xcode completo,
saltealo.

## 2. Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

En Apple Silicon, agrega Homebrew al `PATH` cuando el instalador te lo indique:

```sh
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 3. Rust

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

> Instala Rust con **rustup**, no con `brew install rust`. La formula de Homebrew
> no maneja toolchains multiples y este repo fija la version via
> `rust-toolchain.toml`.

Verifica dentro del repo:

```sh
rustc --version     # 1.95.0
```

## 4. Target WASM

```sh
rustup target add wasm32v1-none
```

## 5. Stellar CLI

```sh
brew install stellar-cli
```

O bien:

```sh
curl -fsSL https://github.com/stellar/stellar-cli/raw/main/install.sh | sh
# o, version exacta desde fuente:
cargo install --locked stellar-cli@28.0.0
```

Verifica: `stellar --version` → `28.0.0`

## 6. Autocompletado (zsh es el shell por defecto)

```sh
echo 'source <(stellar completion --shell zsh)' >> ~/.zshrc
source ~/.zshrc
```

## 7. Docker

```sh
brew install --cask docker
open -a Docker      # arranca el daemon la primera vez
```

Alternativas mas livianas si Docker Desktop te molesta:
[OrbStack](https://orbstack.dev/) (`brew install --cask orbstack`) o
[Colima](https://github.com/abiosoft/colima) (`brew install colima docker`).

> **Apple Silicon.** Las imagenes de `stellar/quickstart` publican `linux/arm64`,
> asi que corren nativas. Si alguna imagen del stack no lo hiciera, Docker cae a
> emulacion QEMU y se pone lenta; el `compose.yaml` del repo deja documentado
> como forzar `platform` en ese caso.

## 8. Node.js (opcional por ahora)

```sh
brew install fnm
fnm install 22 && fnm use 22
corepack enable
```

---

## Verificacion final

```sh
./scripts/check-env.sh
```

## Problemas frecuentes

| Sintoma | Solucion |
|---|---|
| `xcrun: error: invalid active developer path` | `xcode-select --install` |
| `can't find crate for 'core'` | `rustup target add wasm32v1-none` |
| `brew: command not found` en Apple Silicon | Agrega `/opt/homebrew/bin` al `PATH` (paso 2) |
| `Cannot connect to the Docker daemon` | `open -a Docker` y espera a que arranque |
| Builds lentos en M-series | Confirma que no estas bajo Rosetta: `uname -m` debe decir `arm64` |
