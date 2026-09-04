# Contribuir

## Antes de la primera linea de codigo

Este repo esta en kickoff. Las [decisiones abiertas](docs/architecture/README.md#decisiones-abiertas)
se cierran con un [ADR](docs/architecture/decisions/) antes de implementar. Un PR
que implemente algo que todavia no se decidio se va a cerrar pidiendo el ADR
primero — no es burocracia: es lo que evita reescribir el modelo del activo dos
semanas despues.

## Entorno

```sh
./scripts/check-env.sh      # macOS / Linux
.\scripts\check-env.ps1     # Windows
```

Guias completas en [`docs/setup/`](docs/setup/).

## Ramas

`main` esta **protegida**: no se puede pushear directo, ni siquiera siendo
admin. Todo cambio entra por PR.

Reglas activas:

| Regla | Estado |
|---|---|
| Push directo a `main` | bloqueado |
| Aprobaciones requeridas | 0 — podes mergear tu propio PR |
| Checks obligatorios | `Que hay para construir`, `Versiones fijadas`, `Docker` |
| La rama debe estar al dia con `main` | si |
| Historial lineal (sin merge commits) | si |
| Force push y borrado de `main` | bloqueados |
| Conversaciones del PR resueltas | requerido |
| Aplica a administradores | si |

> Las aprobaciones estan en **0** a proposito: con un equipo de una persona,
> exigir una aprobacion haria imposible mergear. **Cuando se sume gente,
> subilo a 1:**
>
> ```sh
> gh api -X PATCH repos/orlando-vazquez-career/lumen-bricks/branches/main/protection/required_pull_request_reviews >   -F required_approving_review_count=1
> ```

> El job `Formato, lint y build WASM` **no** es obligatorio todavia: se saltea
> mientras `contracts/` este vacio, y un check saltado como requerido bloquea el
> merge para siempre. Agregalo a la lista en cuanto exista el primer contrato.

```
feat/<tema>      funcionalidad nueva
fix/<tema>       correccion
docs/<tema>      solo documentacion
chore/<tema>     tooling, CI, dependencias
```

## Commits

[Conventional Commits](https://www.conventionalcommits.org/). El tipo va en
minuscula, el scope es la carpeta afectada:

```
feat(contracts): agrega el registro de activos
fix(web): corrige el chequeo de trustline antes de transferir
docs(setup): aclara el target WASM en Windows
chore(ci): fija la version de la CLI en el workflow
```

## Pull requests

1. Que CI pase. Sin excepciones.
2. Un PR = un cambio. Si el titulo necesita un "y", son dos PRs.
3. Describi **por que**, no solo que. El diff ya dice que.
4. Si toca contratos, decilo explicitamente en la descripcion: esos PRs se
   revisan con otro nivel de detalle.
5. Una aprobacion para merge. Dos si toca `contracts/` o el manejo de claves.

## Codigo

### Rust / contratos

- `cargo fmt` y `cargo clippy -- -D warnings` limpios antes de pedir review.
- Nada de `unwrap()` ni `panic!()` en rutas de ejecucion: usa un enum
  `#[contracterror]` con `panic_with_error!`.
- Toda operacion aritmetica sobre balances usa las variantes checked. Los
  `overflow-checks` estan activos en release, pero un panic en produccion sigue
  siendo un incidente.
- Todo cambio de comportamiento viene con test.

### Documentacion

- La doc que cambia con el codigo va en el mismo PR.
- Comandos completos y copiables.
- Cuando fijes una version, fijala en un archivo versionado
  (`rust-toolchain.toml`, `Cargo.toml`, workflow) y referencila desde la prosa.
  El job `pins` de CI falla si la doc y el CI se desincronizan.

## Seguridad

Nunca commitees una clave secreta (`S...`), ni siquiera de testnet.
`.env` esta en `.gitignore`. Ver [SECURITY.md](SECURITY.md).
