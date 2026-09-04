# Seguridad

## Reportar una vulnerabilidad

**No abras un issue publico.**

Usa [Security Advisories](../../security/advisories/new) de GitHub, que crea un
canal privado con los mantenedores.

Incluí: que es, como reproducirlo, y que impacto tiene. Respondemos dentro de las
72 horas habiles.

## Manejo de claves

Reglas que aplican desde hoy, incluso sin codigo:

1. **Ninguna clave secreta (`S...`) entra al repositorio.** Ni de testnet.
   Una clave de testnet en el historial entrena al equipo a que es aceptable, y
   la proxima es de mainnet.
2. **Las identidades viven en el keystore de la CLI**, no en archivos:
   ```sh
   stellar keys generate deployer --fund   # testnet/local
   stellar keys address deployer
   ```
3. **`.env` esta en `.gitignore`.** Lo que se versiona es `.env.example`, con
   nombres de variables y **sin** valores.
4. **La cuenta emisora nunca es una sola clave.** Multisig con umbral, y la
   custodia en HSM o KMS. Es la decision 5 de
   [arquitectura](docs/architecture/README.md#decisiones-abiertas).
5. **CI no ve claves de mainnet.** Los deploys a mainnet son manuales y firmados
   por humanos.

### Si se filtra una clave

Asumi que esta comprometida desde el segundo en que toco un disco ajeno.
Reescribir el historial de git **no alcanza**: GitHub conserva objetos
inalcanzables y los forks quedan intactos.

1. Rota la clave inmediatamente.
2. Si tiene fondos o autoridad de firma, movelos primero.
3. Recien despues limpia el historial.

## Contratos

Antes de cualquier deploy a mainnet:

- [ ] Auditoria externa del codigo del contrato
- [ ] Estrategia de upgrade decidida y documentada en un ADR (decision 7)
- [ ] Los flags de autorizacion del emisor decididos **antes** de la primera
      emision — no son retroactivos (decision 3)
- [ ] Build reproducible verificado: el WASM en cadena coincide con el hash
      construido desde el commit ([`infra/README.md`](infra/README.md#3-build-reproducible-de-contratos))
- [ ] Runbook de incidentes escrito y probado en testnet
