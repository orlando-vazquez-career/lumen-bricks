# Devcontainer

Reusa el servicio `toolbox` de [`infra/compose.yaml`](../infra/compose.yaml), asi
que el entorno del devcontainer y el de `docker compose run` son **el mismo**:
una sola definicion que mantener.

## Usar

VS Code te ofrece "Reopen in Container" al abrir el repo. O desde la paleta:
`Dev Containers: Reopen in Container`.

## Notas

- `rust-analyzer` esta configurado con `target = wasm32v1-none`. Si en algun
  momento agregamos crates que no son contratos (un servicio en Rust, por
  ejemplo), habra que pasar a `rust-analyzer.cargo.target` por carpeta.
- Los artefactos van a `target-docker/`, separados del `target/` del host, para
  no corromper el cache de cargo entre sistemas operativos.
- Para levantar tambien la red Stellar local, desde una terminal del contenedor:
  `docker compose --profile local up -d` no funciona (no hay docker adentro).
  Levantala desde el host y usa `http://stellar-local:8000/rpc` como RPC.
