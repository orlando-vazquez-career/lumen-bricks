# packages/

Librerias compartidas entre `apps/` y `services/`. **Vacio a proposito.**

Poner algo aca solo cuando **dos o mas** consumidores lo necesiten. Un paquete
compartido con un solo consumidor es una carpeta de mas.

## Candidatos previsibles

- Bindings TypeScript de los contratos, generados con
  `stellar contract bindings typescript` — deberian generarse en CI, no
  commitearse a mano.
- Tipos del dominio (activo, participacion, inversor) compartidos entre web y servicios.
- Helpers de red: passphrase, URLs de RPC/Horizon por entorno.

## Decisiones abiertas

- [ ] Gestor de workspace JS: pnpm workspaces (default) vs alternativa
- [ ] Si los bindings se generan en build o se versionan
