#!/usr/bin/env bash
# Diagnostico del entorno de desarrollo de lumen-bricks.
# No instala nada: reporta que falta y con que comando resolverlo.
#
#   ./scripts/check-env.sh
#
# Salida: 0 si todo lo obligatorio esta OK, 1 si falta algo.

set -uo pipefail

RUST_MIN="1.84.0"
RUST_PINNED="1.95.0"
WASM_TARGET="wasm32v1-none"
STELLAR_EXPECTED="28.0.0"
NODE_MAJOR_MIN="22"

if [ -t 1 ] && [ "${NO_COLOR:-}" = "" ]; then
  G=$'\033[0;32m'; R=$'\033[0;31m'; Y=$'\033[0;33m'; B=$'\033[0;34m'; D=$'\033[2m'; N=$'\033[0m'
else
  G=""; R=""; Y=""; B=""; D=""; N=""
fi

fail=0
warn=0

ok()    { printf '  %sOK%s    %-22s %s\n' "$G" "$N" "$1" "${2:-}"; }
bad()   { printf '  %sFALTA%s %-22s %s\n' "$R" "$N" "$1" "${2:-}"; fail=$((fail+1)); }
soft()  { printf '  %sAVISO%s %-22s %s\n' "$Y" "$N" "$1" "${2:-}"; warn=$((warn+1)); }
fix()   { printf '        %s-> %s%s\n' "$D" "$1" "$N"; }
head_() { printf '\n%s%s%s\n' "$B" "$1" "$N"; }

# Compara versiones semanticas: devuelve 0 si $1 >= $2
ver_ge() {
  [ "$1" = "$2" ] && return 0
  [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

printf '%s\n' "lumen-bricks — diagnostico de entorno"
printf '%s%s%s\n' "$D" "$(uname -s) $(uname -m)" "$N"

# ---------------------------------------------------------------- Rust
head_ "Rust"

if command -v rustup >/dev/null 2>&1; then
  ok "rustup" "$(rustup --version 2>/dev/null | head -n1 | awk '{print $2}')"
else
  bad "rustup" "no encontrado"
  fix "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
fi

if command -v rustc >/dev/null 2>&1; then
  rv="$(rustc --version | awk '{print $2}')"
  if ! ver_ge "$rv" "$RUST_MIN"; then
    bad "rustc" "$rv (Stellar exige >= $RUST_MIN)"
    fix "rustup update stable"
  elif [ "$rv" != "$RUST_PINNED" ]; then
    soft "rustc" "$rv (el repo fija $RUST_PINNED)"
    fix "corre este script desde la raiz del repo; rustup aplica rust-toolchain.toml"
  else
    ok "rustc" "$rv"
  fi
else
  bad "rustc" "no encontrado"
  fix "instala rustup (arriba) y reabri la terminal"
fi

if command -v cargo >/dev/null 2>&1; then
  ok "cargo" "$(cargo --version | awk '{print $2}')"
else
  bad "cargo" "no encontrado"
fi

if command -v rustup >/dev/null 2>&1; then
  if rustup target list --installed 2>/dev/null | grep -qx "$WASM_TARGET"; then
    ok "target wasm" "$WASM_TARGET"
  else
    bad "target wasm" "$WASM_TARGET no instalado"
    fix "rustup target add $WASM_TARGET"
  fi
  if rustup target list --installed 2>/dev/null | grep -qx "wasm32-unknown-unknown"; then
    soft "target viejo" "wasm32-unknown-unknown presente"
    fix "no lo uses para compilar contratos: la red rechaza ese WASM"
  fi
fi

# ------------------------------------------------------------- Stellar
head_ "Stellar"

if command -v stellar >/dev/null 2>&1; then
  sv="$(stellar --version 2>/dev/null | head -n1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  sv="${sv:-desconocida}"
  if [ "$sv" = "$STELLAR_EXPECTED" ]; then
    ok "stellar" "$sv"
  else
    soft "stellar" "$sv (el repo usa $STELLAR_EXPECTED)"
    fix "cargo install --locked stellar-cli@$STELLAR_EXPECTED"
  fi
  printf '        %s   binario: %s%s\n' "$D" "$(command -v stellar)" "$N"
else
  bad "stellar" "no encontrada"
  fix "curl -fsSL https://github.com/stellar/stellar-cli/raw/main/install.sh | sh"
  fix "o: cargo install --locked stellar-cli@$STELLAR_EXPECTED"
fi

if command -v soroban >/dev/null 2>&1; then
  soft "soroban" "CLI vieja presente"
  fix "fue reemplazada por 'stellar'; desinstalala para evitar confusiones"
fi

# -------------------------------------------------------------- Docker
head_ "Docker"

if command -v docker >/dev/null 2>&1; then
  ok "docker" "$(docker --version 2>/dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  if docker info >/dev/null 2>&1; then
    ok "daemon" "corriendo"
  else
    bad "daemon" "no responde"
    fix "arranca Docker Desktop, o: sudo systemctl start docker"
  fi
  if docker compose version >/dev/null 2>&1; then
    ok "compose" "$(docker compose version --short 2>/dev/null)"
  else
    bad "compose" "plugin no encontrado"
    fix "instala el plugin docker-compose-v2"
  fi
else
  bad "docker" "no encontrado"
  fix "https://docs.docker.com/get-docker/"
fi

# ------------------------------------------------------ Opcionales
head_ "Opcional (solo para apps/web)"

if command -v node >/dev/null 2>&1; then
  nv="$(node --version | tr -d 'v')"
  if [ "${nv%%.*}" -ge "$NODE_MAJOR_MIN" ] 2>/dev/null; then
    ok "node" "$nv"
  else
    soft "node" "$nv (se recomienda >= $NODE_MAJOR_MIN)"
  fi
else
  soft "node" "no encontrado — todavia no hace falta"
fi

command -v git >/dev/null 2>&1 \
  && ok "git" "$(git --version | awk '{print $3}')" \
  || bad "git" "no encontrado"

# ------------------------------------------------------------ Resumen
head_ "Resumen"

if [ "$fail" -eq 0 ] && [ "$warn" -eq 0 ]; then
  printf '  %sEntorno listo.%s\n\n' "$G" "$N"
elif [ "$fail" -eq 0 ]; then
  printf '  %sListo para trabajar%s, con %d aviso(s) arriba.\n\n' "$G" "$N" "$warn"
else
  printf '  %s%d cosa(s) obligatoria(s) sin resolver%s (y %d aviso(s)).\n' "$R" "$fail" "$N" "$warn"
  printf '  %sGuia completa: docs/setup/%s\n\n' "$D" "$N"
  exit 1
fi
