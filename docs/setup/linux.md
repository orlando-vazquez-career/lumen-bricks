# Setup — Linux

Probado en Ubuntu 22.04+ / Debian 12+. Las notas para Fedora y Arch estan al pie.

## 1. Dependencias de compilacion

Rust necesita un linker y headers de C.

```sh
# Debian / Ubuntu
sudo apt update && sudo apt install -y build-essential pkg-config libssl-dev curl git
```

Sin `build-essential`, `cargo build` falla con `linker 'cc' not found`.

## 2. Rust

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

Acepta la instalacion por defecto (opcion 1). Verifica **dentro del repo**:

```sh
rustc --version     # 1.95.0
```

> `rustup` lee `rust-toolchain.toml` y cambia de version solo. No corras
> `rustup default`.

## 3. Target WASM

```sh
rustup target add wasm32v1-none
```

## 4. Stellar CLI

```sh
# Script oficial (instala en ~/.local/bin)
curl -fsSL https://github.com/stellar/stellar-cli/raw/main/install.sh | sh
```

Alternativas:

```sh
# Homebrew en Linux
brew install stellar-cli

# Desde fuente, version exacta
cargo install --locked stellar-cli@28.0.0
```

Verifica:

```sh
stellar --version   # 28.0.0
```

Si `stellar: command not found`, agrega el directorio al `PATH`:

```sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

## 5. Autocompletado

```sh
echo 'source <(stellar completion --shell bash)' >> ~/.bashrc
# zsh:
echo 'source <(stellar completion --shell zsh)' >> ~/.zshrc
```

## 6. Docker

```sh
# Docker Engine desde el repo oficial
curl -fsSL https://get.docker.com | sh

# Usar docker sin sudo
sudo usermod -aG docker "$USER"
newgrp docker
```

Verifica: `docker run --rm hello-world`

## 7. Node.js (opcional por ahora)

Solo hace falta cuando arranque `apps/web`.

```sh
curl -fsSL https://fnm.vercel.app/install | bash
fnm install 22 && fnm use 22
corepack enable
```

---

## Verificacion final

```sh
./scripts/check-env.sh
```

---

## Otras distros

<details>
<summary><b>Fedora / RHEL</b></summary>

```sh
sudo dnf install -y @development-tools pkgconf-pkg-config openssl-devel curl git
sudo dnf install -y docker docker-compose-plugin
sudo systemctl enable --now docker
```
</details>

<details>
<summary><b>Arch</b></summary>

```sh
sudo pacman -S --needed base-devel pkgconf openssl curl git
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker
```
</details>

## Problemas frecuentes

| Sintoma | Solucion |
|---|---|
| `linker 'cc' not found` | Instala `build-essential` (paso 1) |
| `can't find crate for 'core'` | `rustup target add wasm32v1-none` |
| `permission denied` al usar docker | `sudo usermod -aG docker $USER` y volve a iniciar sesion |
| `stellar: command not found` | Agrega `~/.local/bin` al `PATH` (paso 4) |
