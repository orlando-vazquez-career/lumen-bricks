# Infraestructura — Docker

Docker cumple **tres funciones distintas** en este repo. Conviene tenerlas
separadas en la cabeza, porque la gente suele mezclarlas y termina con un
contenedor que hace todo mal.

| Funcion | Servicio / archivo | Cuando lo usas |
|---|---|---|
| **Red Stellar local** | `stellar-local` en [`compose.yaml`](compose.yaml) | Todos los dias. Blockchain descartable para probar. |
| **Toolbox de desarrollo** | `toolbox` + [`docker/Dockerfile.dev`](docker/Dockerfile.dev) | Si no queres instalar Rust en tu maquina, o para igualar CI. |
| **Build reproducible** | [`docker/Dockerfile.contracts`](docker/Dockerfile.contracts) | Al construir el WASM que se despliega. Mismo input, mismo hash. |

Todos los comandos de abajo asumen que estas en `infra/`. Desde la raiz, agrega
`-f infra/compose.yaml`.

---

## 1. Red Stellar local

Una red entera — Core, RPC, Horizon y friendbot — en un contenedor.

```sh
docker compose --profile local up -d
```

La primera vez tarda ~1 minuto en producir el primer ledger. Segui el progreso
con `docker compose logs -f stellar-local`, o espera al healthcheck:

```sh
docker compose --profile local up -d --wait
```

### Que queda expuesto

Todo sale por el **puerto 8000**, con un nginx adelante que rutea por path:

| URL | Servicio |
|---|---|
| `http://localhost:8000` | Horizon (API clasica) |
| `http://localhost:8000/rpc` | Stellar RPC (contratos) |
| `http://localhost:8000/friendbot?addr=<G...>` | Friendbot — fondea cuentas de prueba |
| `http://localhost:11626` | Endpoint de admin de Stellar Core |

### Apuntar la CLI a la red local

```sh
stellar network add local \
  --rpc-url http://localhost:8000/rpc \
  --network-passphrase "Standalone Network ; February 2017"

stellar network use local

# Una identidad fondeada para trabajar
stellar keys generate deployer --fund
stellar keys address deployer
```

### Empezar de cero

El estado vive en un volumen nombrado, asi que sobrevive a `down`. Para borrarlo:

```sh
docker compose --profile local down -v
```

Usa esto cada vez que cambies algo que toque genesis o cuando el estado quede
raro. Es barato: son segundos.

### Elegir el tag de la imagen

```yaml
image: stellar/quickstart:latest    # protocolo de mainnet hoy  <- default
image: stellar/quickstart:testing   # protocolo candidato de testnet
image: stellar/quickstart:future    # features de protocolo sin liberar
```

Antes de un upgrade de protocolo, corre la suite contra `testing` para detectar
roturas con anticipacion.

> **Fijar por digest.** `latest` se mueve. Cuando el proyecto tenga tests de
> integracion en CI, cambia a `stellar/quickstart@sha256:<digest>` para que un
> push de la imagen no rompa el pipeline un martes cualquiera. Obtene el digest
> con `docker buildx imagetools inspect stellar/quickstart:latest`.

---

## 2. Desarrollar dentro del contenedor

Si no queres Rust, la CLI ni sus dependencias en tu maquina:

```sh
docker compose --profile tools run --rm toolbox
```

Te deja una shell en `/workspace` (el repo montado) con `cargo`, el target
`wasm32v1-none` y `stellar 28.0.0` ya configurados. Tambien sirve para comandos
sueltos:

```sh
docker compose --profile tools run --rm toolbox stellar --version
docker compose --profile tools run --rm toolbox cargo fmt --check
```

**Detalles que importan:**

- El cache de cargo vive en volumenes nombrados (`cargo-registry`, `cargo-git`),
  asi que solo el primer `run` es lento.
- Los artefactos de compilacion van a `target-docker/`, **separado** del `target/`
  del host. Compartirlos entre Linux del contenedor y Windows/macOS del host
  corrompe el cache de cargo.
- Las identidades de la CLI persisten en el volumen `stellar-config`.

### Hablarle a la red local desde el toolbox

Estan en la misma red de compose, asi que el host es el nombre del servicio, no
`localhost`:

```sh
docker compose --profile local up -d          # primero la red
docker compose --profile tools run --rm toolbox \
  stellar network add local \
    --rpc-url http://stellar-local:8000/rpc \
    --network-passphrase "Standalone Network ; February 2017"
```

El `compose.yaml` ya deja esas URLs en variables de entorno del servicio.

---

## 3. Build reproducible de contratos

El objetivo: que el `.wasm` desplegado a mainnet se pueda reconstruir desde el
commit y dar **byte por byte identico**. Es lo que permite que un tercero
verifique que el contrato en cadena es el codigo que auditaron.

```sh
# desde la RAIZ del repo
docker build -f infra/docker/Dockerfile.contracts -o type=local,dest=./artifacts .
sha256sum artifacts/*.wasm
```

Que lo hace reproducible:

- **Imagen base fijada** (`rust:1.95.0-bookworm`), no `rust:latest`.
- **Toolchain fijado** por `rust-toolchain.toml`, incluida la version del target.
- **`cargo build --locked`** — falla si `Cargo.lock` no esta al dia, en vez de
  resolver versiones nuevas en silencio.
- **Etapa final `scratch`** con `-o`: exporta solo los `.wasm`, sin metadata del
  builder.
- **Perfil de release** con `codegen-units = 1` y `lto = true` (ver `Cargo.toml`),
  que ademas de achicar el binario elimina el no-determinismo de la compilacion
  paralela.

> Mientras `contracts/` este vacio el build corre igual y no produce artefactos.
> Es a proposito: asi la infraestructura ya esta probada cuando llegue el primer
> contrato.

---

## Referencia rapida

```sh
docker compose --profile local up -d --wait      # levantar red local
docker compose logs -f stellar-local             # ver logs
docker compose --profile local down              # parar, conservar estado
docker compose --profile local down -v           # parar y borrar estado
docker compose --profile tools run --rm toolbox  # shell del toolchain
docker compose --profile tools build --no-cache  # reconstruir el toolbox
docker compose ps                                # que esta corriendo
```

## Problemas frecuentes

| Sintoma | Causa | Solucion |
|---|---|---|
| `port is already allocated` en 8000 | Otro proceso ocupa el puerto | Cambia el mapeo a `"8001:8000"` o libera el puerto |
| Friendbot devuelve 400/404 al arrancar | La red aun no produjo el primer ledger | Espera el healthcheck: `up -d --wait` |
| La CLI no llega al RPC desde el toolbox | Usaste `localhost` en vez del nombre del servicio | `http://stellar-local:8000/rpc` |
| Builds lentisimos en Apple Silicon | Emulacion de plataforma | Las imagenes publican `arm64`; confirma con `docker image inspect --format '{{.Architecture}}'` |
| `cargo` recompila todo cada vez | Se comparte `target/` entre host y contenedor | Ya esta separado en `target-docker/`; no lo remapees |
| Estado corrupto tras cambiar de tag | Volumen con datos del protocolo viejo | `down -v` y volve a levantar |
