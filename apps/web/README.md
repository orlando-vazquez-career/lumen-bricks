# apps/web/

dApp de lumen-bricks. **Vacio a proposito.**

Es la cara visible del producto: conectar wallet, ver el activo tokenizado,
emitir/transferir, y el panel del inversor.

## Decisiones abiertas

- [ ] Framework (Next.js App Router es el default salvo que haya razon para otro)
- [ ] Integracion de wallet: [Stellar Wallets Kit](https://github.com/Creit-Tech/Stellar-Wallets-Kit)
      (multi-wallet) vs Freighter directo vs passkeys / smart wallets
- [ ] Que se firma en el cliente y que pasa por un backend
- [ ] Si hace falta indexado propio o alcanza con RPC + Horizon

## Cuando arranque

```sh
pnpm create next-app@latest apps/web
pnpm --filter web add @stellar/stellar-sdk@17.0.1
```

Fija Node con un `.nvmrc` (`22`) y agrega la app al workspace de pnpm.

## Referencia

- [Frontend & Wallets — Stellar Skills](https://skills.stellar.org/)
- [`@stellar/stellar-sdk`](https://github.com/stellar/js-stellar-sdk) — v17.0.1
