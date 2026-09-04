#Requires -Version 5.1
<#
.SYNOPSIS
  Diagnostico del entorno de desarrollo de lumen-bricks.
.DESCRIPTION
  No instala nada: reporta que falta y con que comando resolverlo.
  Devuelve exit code 1 si falta algo obligatorio.
.EXAMPLE
  .\scripts\check-env.ps1
#>

$ErrorActionPreference = 'Continue'

$RustMin         = [version]'1.84.0'
$RustPinned      = '1.95.0'
$WasmTarget      = 'wasm32v1-none'
$StellarExpected = '28.0.0'
$NodeMajorMin    = 22

$script:Fail = 0
$script:Warn = 0

function Write-Ok   { param($n, $v) Write-Host "  OK    " -F Green      -NoNewline; Write-Host ("{0,-22} {1}" -f $n, $v) }
function Write-Bad  { param($n, $v) Write-Host "  FALTA " -F Red        -NoNewline; Write-Host ("{0,-22} {1}" -f $n, $v); $script:Fail++ }
function Write-Soft { param($n, $v) Write-Host "  AVISO " -F Yellow     -NoNewline; Write-Host ("{0,-22} {1}" -f $n, $v); $script:Warn++ }
function Write-Fix  { param($c)     Write-Host "        -> $c"          -F DarkGray }
function Write-Head { param($t)     Write-Host ""; Write-Host $t        -F Cyan }

function Get-Ver {
  param($Text)
  if ($Text -match '(\d+\.\d+\.\d+)') { return $Matches[1] }
  return $null
}

Write-Host "lumen-bricks - diagnostico de entorno"
Write-Host ("Windows {0} ({1})" -f [Environment]::OSVersion.Version, $env:PROCESSOR_ARCHITECTURE) -F DarkGray

# ------------------------------------------------------------------ Rust
Write-Head "Rust"

if (Get-Command rustup -ErrorAction SilentlyContinue) {
  Write-Ok "rustup" (Get-Ver (rustup --version 2>&1 | Select-Object -First 1))
} else {
  Write-Bad "rustup" "no encontrado"
  Write-Fix "winget install --id Rustlang.Rustup"
}

if (Get-Command rustc -ErrorAction SilentlyContinue) {
  $rv = Get-Ver (rustc --version 2>&1)
  if (-not $rv) {
    Write-Bad "rustc" "no se pudo leer la version"
  } elseif ([version]$rv -lt $RustMin) {
    Write-Bad "rustc" "$rv (Stellar exige >= $RustMin)"
    Write-Fix "rustup update stable"
  } elseif ($rv -ne $RustPinned) {
    Write-Soft "rustc" "$rv (el repo fija $RustPinned)"
    Write-Fix "corre este script desde la raiz del repo; rustup aplica rust-toolchain.toml"
  } else {
    Write-Ok "rustc" $rv
  }
} else {
  Write-Bad "rustc" "no encontrado"
  Write-Fix "instala rustup y REABRI la terminal (el PATH se refresca al abrir)"
}

if (Get-Command cargo -ErrorAction SilentlyContinue) {
  Write-Ok "cargo" (Get-Ver (cargo --version 2>&1))
} else {
  Write-Bad "cargo" "no encontrado"
}

if (Get-Command rustup -ErrorAction SilentlyContinue) {
  $targets = rustup target list --installed 2>&1
  if ($targets -contains $WasmTarget) {
    Write-Ok "target wasm" $WasmTarget
  } else {
    Write-Bad "target wasm" "$WasmTarget no instalado"
    Write-Fix "rustup target add $WasmTarget"
  }
  if ($targets -contains 'wasm32-unknown-unknown') {
    Write-Soft "target viejo" "wasm32-unknown-unknown presente"
    Write-Fix "no lo uses para contratos: la red rechaza ese WASM"
  }
}

# Linker de MSVC: la causa numero uno de builds rotos en Windows nativo
$hasLink = [bool](Get-Command link.exe -ErrorAction SilentlyContinue)
if (-not $hasLink) {
  $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
  if (Test-Path $vswhere) {
    $vc = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath 2>$null
    if ($vc) { $hasLink = $true }
  }
}
if ($hasLink) {
  Write-Ok "build tools MSVC" "presentes"
} else {
  Write-Soft "build tools MSVC" "no detectados"
  Write-Fix 'winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"'
}

# --------------------------------------------------------------- Stellar
Write-Head "Stellar"

$stellarCmd = Get-Command stellar -ErrorAction SilentlyContinue
if ($stellarCmd) {
  $sv = Get-Ver (stellar --version 2>&1 | Select-Object -First 1)
  if ($sv -eq $StellarExpected) {
    Write-Ok "stellar" $sv
  } else {
    Write-Soft "stellar" "$sv (el repo usa $StellarExpected)"
    Write-Fix "cargo install --locked stellar-cli@$StellarExpected"
  }
  Write-Host ("           binario: {0}" -f $stellarCmd.Source) -F DarkGray

  $all = @(Get-Command stellar -All -ErrorAction SilentlyContinue)
  if ($all.Count -gt 1) {
    Write-Soft "stellar" "hay $($all.Count) instalaciones en el PATH"
    $all | ForEach-Object { Write-Fix $_.Source }
    Write-Fix "gana la primera; quedate con una sola para evitar sorpresas"
  }
} else {
  Write-Bad "stellar" "no encontrada"
  Write-Fix "winget install --id Stellar.StellarCLI"
  Write-Fix "o (version exacta): cargo install --locked stellar-cli@$StellarExpected"
  Write-Fix "si la acabas de instalar, REABRI la terminal"
}

# ---------------------------------------------------------------- Docker
Write-Head "Docker"

if (Get-Command docker -ErrorAction SilentlyContinue) {
  Write-Ok "docker" (Get-Ver (docker --version 2>&1))
  docker info *> $null
  if ($LASTEXITCODE -eq 0) {
    Write-Ok "daemon" "corriendo"
  } else {
    Write-Bad "daemon" "no responde"
    Write-Fix "arranca Docker Desktop"
  }
  $cv = docker compose version 2>&1
  if ($LASTEXITCODE -eq 0) {
    Write-Ok "compose" (Get-Ver $cv)
  } else {
    Write-Bad "compose" "plugin no encontrado"
  }
} else {
  Write-Bad "docker" "no encontrado"
  Write-Fix "winget install --id Docker.DockerDesktop"
}

# ------------------------------------------------------------- Opcional
Write-Head "Opcional (solo para apps/web)"

if (Get-Command node -ErrorAction SilentlyContinue) {
  $nv = (node --version 2>&1) -replace '^v', ''
  $nvMajor = [int](($nv -split '\.')[0])
  if ($nvMajor -ge $NodeMajorMin) {
    Write-Ok "node" $nv
  } else {
    Write-Soft "node" "$nv (se recomienda >= $NodeMajorMin)"
  }
} else {
  Write-Soft "node" "no encontrado - todavia no hace falta"
}

if (Get-Command git -ErrorAction SilentlyContinue) {
  Write-Ok "git" (Get-Ver (git --version 2>&1))
  if ((git config --get core.longpaths) -ne 'true') {
    Write-Soft "git longpaths" "desactivado"
    Write-Fix "git config --global core.longpaths true"
  }
} else {
  Write-Bad "git" "no encontrado"
}

# -------------------------------------------------------------- Resumen
Write-Head "Resumen"

if ($script:Fail -eq 0 -and $script:Warn -eq 0) {
  Write-Host "  Entorno listo." -F Green
  Write-Host ""
  exit 0
} elseif ($script:Fail -eq 0) {
  Write-Host "  Listo para trabajar" -F Green -NoNewline
  Write-Host ", con $($script:Warn) aviso(s) arriba."
  Write-Host ""
  exit 0
} else {
  Write-Host "  $($script:Fail) cosa(s) obligatoria(s) sin resolver" -F Red -NoNewline
  Write-Host " (y $($script:Warn) aviso(s))."
  Write-Host "  Guia completa: docs\setup\windows.md" -F DarkGray
  Write-Host ""
  exit 1
}
