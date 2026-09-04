# Tokenizacion de activos en Stellar

Mapa de las opciones y los estandares. **No es una decision tomada** — es el
material para tomarla.

---

## Los dos caminos

### A. Activo clasico (emisor + trustlines)

El modelo nativo de Stellar, anterior a los contratos. Una cuenta **emisora**
crea el activo; cada tenedor abre una **trustline** para poder recibirlo.

**A favor**
- Comisiones minimas y finalidad en ~5 segundos.
- DEX, order books y path payments **nativos**, sin escribir nada.
- Los controles regulatorios son flags del protocolo, no codigo tuyo que auditar.
- Se expone a contratos via **SAC** (abajo) sin migrar nada.

**En contra**
- La logica esta limitada a lo que el protocolo ofrece. Nada de vesting,
  dividendos automaticos ni reglas a medida.

**Flags de control** (se setean en la cuenta emisora, con `set_options`):

| Flag | Efecto | Uso tipico |
|---|---|---|
| `AUTH_REQUIRED` | El emisor debe autorizar cada trustline | Whitelist de inversores acreditados |
| `AUTH_REVOCABLE` | El emisor puede congelar un balance | Orden judicial, sancion |
| `AUTH_CLAWBACK_ENABLED` | El emisor puede recuperar tokens emitidos | Error de emision, resolucion regulatoria |
| `AUTH_IMMUTABLE` | Congela los flags anteriores para siempre | Prometer que no habra clawback |

> El orden importa: `AUTH_IMMUTABLE` es irreversible y bloquea a los otros tres.

### B. Token Soroban propio (SEP-41)

Un contrato Rust que implementa la [interfaz de token
SEP-41](https://developers.stellar.org/docs/tokens/token-interface).

**A favor**
- Logica arbitraria: vesting, whitelist on-chain, reparto de dividendos,
  redencion, reglas de transferencia complejas.
- Componible con otros contratos en la misma transaccion.

**En contra**
- Superficie de auditoria propia. Cada linea es riesgo.
- No participa del DEX clasico salvo que lo integres explicitamente.
- Mas caro por operacion, y hay que gestionar **rent** del estado.

### C. Hibrido (lo habitual para un activo real)

Activo clasico como unidad de valor + contratos alrededor para la logica de
negocio, conectados por el SAC. Se queda con el DEX nativo y los flags
regulatorios, y suma lo que el protocolo no da.

---

## Stellar Asset Contract (SAC)

Cada activo clasico tiene **automaticamente** un contrato que lo representa en
Soroban, con la interfaz SEP-41. No hay que desplegar nada, solo instanciarlo:

```sh
stellar contract asset deploy --asset <CODIGO>:<G...EMISOR>
stellar contract id asset --asset <CODIGO>:<G...EMISOR>
```

Es lo que hace viable el camino C: el activo sigue siendo clasico, y los
contratos lo mueven como si fuera un token Soroban.

[Documentacion del SAC](https://developers.stellar.org/docs/tokens/stellar-asset-contract)

---

## SEPs relevantes

Los *Stellar Ecosystem Proposals* son los estandares de interoperabilidad. Estos
son los que tocan un proyecto de tokenizacion:

| SEP | Nombre | Por que nos importa |
|---|---|---|
| [SEP-1](https://developers.stellar.org/docs/tokens/publishing-asset-info) | `stellar.toml` | Metadata publica del emisor y del activo. Sin esto, las wallets muestran el token como desconocido. |
| [SEP-6](https://developers.stellar.org/docs/anchoring-assets/) | Deposito/retiro programatico | Rampa fiat sin UI del anchor |
| [SEP-8](https://developers.stellar.org/docs/tokens/control-asset-access) | **Activos regulados** | Cada transferencia pasa por un servidor de aprobacion. El estandar para valores con restricciones. |
| [SEP-10](https://developers.stellar.org/docs/building-apps/authentication) | Web Authentication | Login probando control de una cuenta, sin password |
| [SEP-12](https://developers.stellar.org/docs/anchoring-assets/) | KYC API | Formato estandar para datos del inversor |
| [SEP-24](https://developers.stellar.org/docs/anchoring-assets/) | Deposito/retiro interactivo | Rampa fiat con UI hosteada por el anchor |
| [SEP-41](https://developers.stellar.org/docs/tokens/token-interface) | Token Interface | La interfaz que debe cumplir un token Soroban |

---

## Preguntas a resolver antes de codear

Cada una empuja la decision hacia A, B o C:

1. **¿El activo tiene restricciones legales de transferencia?**
   Si → `AUTH_REQUIRED` + SEP-8. Empuja a A o C.
2. **¿Hace falta poder congelar o recuperar tokens?**
   Si → `AUTH_REVOCABLE` / `AUTH_CLAWBACK_ENABLED`. Hay que decidirlo **antes**
   de la primera emision: activar clawback despues no afecta a lo ya emitido.
3. **¿Hay logica que el protocolo no cubre?** (vesting, dividendos, redencion)
   Si → C. Solo B si ademas no necesitas DEX nativo.
4. **¿Se va a tradear en el DEX de Stellar?**
   Si → A o C.
5. **¿Quien controla la cuenta emisora?**
   Una sola clave es un punto unico de falla que vale todo el activo. Multisig
   con umbral, y custodia en HSM/KMS.
6. **¿Que jurisdiccion aplica?**
   Define 1 y 2, y si el KYC puede vivir on-chain.

---

## Lectura

- [Tokens en Stellar](https://developers.stellar.org/docs/tokens)
- [Control de acceso a un activo](https://developers.stellar.org/docs/tokens/control-asset-access)
- [Anatomia de un activo](https://developers.stellar.org/docs/tokens/anatomy-of-an-asset)
- [Lista de SEPs](https://github.com/stellar/stellar-protocol/tree/master/ecosystem)
- [Assets & SAC — Stellar Skills](https://skills.stellar.org/)
