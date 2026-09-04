# Decisiones de arquitectura (ADRs)

Un ADR registra **una** decision: que se decidio, por que, y que se descarto.
Sirve para que dentro de seis meses nadie tenga que reconstruir el razonamiento
desde el chat.

## Cuando escribir uno

Cuando la decision es cara de revertir. Elegir el modelo del activo o los flags
de autorizacion, si. El nombre de una variable, no.

## Como

1. Copia [`0000-template.md`](0000-template.md) a `NNNN-titulo-en-kebab-case.md`.
2. Numera correlativo, sin reusar numeros.
3. Abri un PR. La discusion va en el PR; el archivo queda con el resultado.
4. Un ADR aceptado **no se edita**. Si cambia la decision, se escribe uno nuevo
   que marque al anterior como `Reemplazado por NNNN`.

## Indice

| # | Decision | Estado |
|---|---|---|
| — | _ninguna todavia_ | — |
