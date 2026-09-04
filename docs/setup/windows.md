# Setup — Windows

Dos caminos validos. **Si dudas, elegi WSL2**: es identico a lo que corre CI y te
ahorra la mayoria de los problemas de rutas y toolchain.

- [Camino A — WSL2](#camino-a--wsl2-recomendado)
- [Camino B — Windows nativo (MSVC)](#camino-b--windows-nativo-msvc)

---

## Camino A — WSL2 (recomendado)

### 1. Instalar WSL2 + Ubuntu

En PowerShell **como administrador**:

```powershell
wsl --install -d Ubuntu
```

Reinicia si te lo pide. Despues abri "Ubuntu" desde el menu inicio y segui la
**[guia de Linux](linux.md)** dentro de esa terminal.

### 2. Clonar dentro del filesystem de Linux

Esto importa mucho. Cloná en `~/` (o sea `/home/<usuario>/`), **no** en
`/mnt/c/...`:

```sh
cd ~
git clone https://github.com/orlando-vazquez-career/lumen-bricks.git
```

Compilar Rust sobre `/mnt/c` es entre 5 y 20 veces mas lento porque cada acceso
a archivo cruza la capa de traduccion 9P. Tambien rompe la deteccion de cambios
de `cargo`.

### 3. Docker Desktop con backend WSL2

Instala [Docker Desktop](https://www.docker.com/products/docker-desktop/) en
Windows y activa la integracion:

`Settings -> Resources -> WSL Integration -> Enable integration with Ubuntu`

Asi el `docker` que corres dentro de Ubuntu usa el motor de Docker Desktop.

### 4. Editor

VS Code con la extension **WSL** (`ms-vscode-remote.remote-wsl`). Abri el
proyecto con `code .` **desde la terminal de Ubuntu** — el servidor de lenguaje
de Rust corre del lado Linux y todo funciona.

---

## Camino B — Windows nativo (MSVC)

### 1. Build tools de C/C++ (hacelo primero)

Rust en Windows usa el linker de MSVC. Sin esto, `cargo build` falla con
`error: linker 'link.exe' not found`.

```powershell
winget install --id Microsoft.VisualStudio.2022.BuildTools `
  --override "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

Si ya tenes Visual Studio instalado con el workload **"Desarrollo para el
escritorio con C++"**, saltea este paso.

### 2. Rust

```powershell
winget install --id Rustlang.Rustup
```

O descarga [rustup-init.exe](https://win.rustup.rs/x86_64) y ejecutalo.

**Cerra y volve a abrir la terminal** para que tome el `PATH`.

```powershell
rustc --version     # debe reportar 1.95.0 dentro del repo
```

> No corras `rustup default`. Al entrar al repo, `rust-toolchain.toml` cambia la
> version automaticamente y la descarga si falta.

### 3. Target WASM

```powershell
rustup target add wasm32v1-none
```

### 4. Stellar CLI

En Windows conviene **usar un binario ya compilado**. Las tres opciones, de
mejor a peor para este sistema operativo:

**a) Binario oficial (recomendado)** — version exacta, sin compilar:

```powershell
$ver = "28.0.0"
$tmp = "$env:TEMP\stellar-cli"
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
Invoke-WebRequest -Uri "https://github.com/stellar/stellar-cli/releases/download/v$ver/stellar-cli-$ver-x86_64-pc-windows-msvc.tar.gz" -OutFile "$tmp\stellar.tar.gz"
tar -xzf "$tmp\stellar.tar.gz" -C "$env:USERPROFILE\.cargoin"
stellar --version
```

`~\.cargoin` ya esta en tu `PATH` si instalaste Rust con rustup, asi que no
hay que tocar variables de entorno.

**b) Instalador oficial** — el asistente grafico, si preferis:
[stellar-cli-installer-28.0.0-x86_64-pc-windows-msvc.exe](https://github.com/stellar/stellar-cli/releases/download/v28.0.0/stellar-cli-installer-28.0.0-x86_64-pc-windows-msvc.exe)

**c) winget** — comodo, pero **el manifest va atrasado**. Al momento de escribir
esto ofrecia 27.1.0 cuando el release era 28.0.0:

```powershell
winget install --id Stellar.StellarCLI
winget show --id Stellar.StellarCLI --versions   # ver que tiene disponible
```

> **Evita `cargo install --locked stellar-cli` en Windows.** Compilar el crate
> `stellar-xdr` (codigo generado, muy grande) hace crashear a `rustc` con
> `STATUS_STACK_BUFFER_OVERRUN` (`0xc0000409`) en varias combinaciones de
> toolchain. Verificado fallando con Rust 1.95.0 en Windows 11. En Linux y macOS
> funciona sin problema; en Windows usa el binario.

Verifica:

```powershell
stellar --version     # 28.0.0
```

> **Si terminas con dos instalaciones**, gana la que aparezca primero en el
> `PATH`, y el `PATH` de maquina (donde escribe winget:
> `C:\Program Files (x86)\Stellar CLI`) va **antes** que el de usuario (donde
> esta `~\.cargoin`). O sea: la de winget tapa a la otra aunque sea mas vieja.
> Confirma cual usas con `(Get-Command stellar).Source` y quedate con una sola:
> `winget uninstall --id Stellar.StellarCLI`.
> El script `check-env.ps1` detecta y avisa de este caso.

### 5. Autocompletado en PowerShell

```powershell
New-Item -ItemType Directory -Path $(Split-Path $PROFILE) -Force
if (-Not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE | Out-Null }
Add-Content $PROFILE 'Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete'
Add-Content $PROFILE 'stellar completion --shell powershell | Out-String | Invoke-Expression'
```

### 6. Docker Desktop

```powershell
winget install --id Docker.DockerDesktop
```

### 7. Git — rutas largas y finales de linea

Rust genera rutas profundas en `target/`. Windows corta en 260 caracteres salvo
que lo habilites:

```powershell
git config --global core.longpaths true
```

Y para que los finales de linea no ensucien los diffs (el repo ya trae un
`.gitattributes` que normaliza, esto es el refuerzo del lado del cliente):

```powershell
git config --global core.autocrlf false
```

### 8. Antivirus

Windows Defender escanea cada archivo que escribe `cargo`, lo que puede triplicar
el tiempo de compilacion. Excluir la carpeta `target/` es seguro y hace una
diferencia grande:

```powershell
Add-MpPreference -ExclusionPath "$PWD\target"
```

(Requiere terminal como administrador.)

---

## Verificacion final

```powershell
.\scripts\check-env.ps1
```

## Problemas frecuentes

| Sintoma | Causa | Solucion |
|---|---|---|
| `linker 'link.exe' not found` | Faltan los build tools de MSVC | Paso 1 |
| `can't find crate for 'core'` al compilar a WASM | Falta el target | `rustup target add wasm32v1-none` |
| El deploy falla con imports desconocidos | Compilaste a `wasm32-unknown-unknown` | Usa `wasm32v1-none` |
| `stellar: command not found` tras instalar | La terminal tiene el `PATH` viejo | Cerra y abri la terminal |
| `STATUS_STACK_BUFFER_OVERRUN` al instalar la CLI | `cargo install` crashea a rustc compilando `stellar-xdr` | Usa el binario oficial (paso 4a) |
| `stellar --version` no coincide con 28.0.0 | Hay dos instalaciones y la del PATH de maquina gana | `winget uninstall --id Stellar.StellarCLI` |
| Compilacion lentisima | Repo en `/mnt/c` bajo WSL, o Defender escaneando `target/` | Pasos A.2 / B.8 |
| `docker: command not found` en WSL | Falta la integracion WSL en Docker Desktop | Paso A.3 |
