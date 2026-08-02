# Diagnóstico de formas normales

Antes de normalizar (ver `sql/04_normalizacion_3fn.sql`), se diagnosticó en qué forma normal
estaba cada una de las 9 tablas originales y qué problema concreto presentaba.

| Tabla | Forma Normal | Problema detectado |
|---|---|---|
| CATEGORIAS | 3FN | Sin problemas detectados. Tabla simple y correctamente atómica. |
| SUCURSALES | 2FN | 7 columnas de horario (Lunes a Domingo) son un grupo repetitivo. Viola 1FN. |
| CAJEROS | 2FN | Depende de SUCURSALES pero sin FK formal declarada. |
| CLIENTES | 3FN | Estructura correcta. Campos atómicos sin dependencias transitivas. |
| PRODUCTOS | 2FN | `categoria` y `subCategoria` son atributos que deberían referenciar una tabla CATEGORIAS con FK. |
| INVENTARIO | 1FN | Clave compuesta sin declaración formal. Sin FK. |
| ORDENES | 2FN | Contiene `idSucursal` e `idCliente` sin FK formales declaradas. |
| ORDENES_DETALLE | 2FN | `precioUnitario` puede depender solo del producto, no de la orden completa. |
| DEVOLUCIONES | 2FN | Sin FK formales a ORDENES ni PRODUCTOS. |

## Repaso de conceptos

- **1FN (Primera Forma Normal):** cada columna tiene un solo valor atómico — sin listas ni
  grupos repetidos (ej. las 7 columnas de horario en SUCURSALES).
- **2FN (Segunda Forma Normal):** cumple 1FN, y todo atributo no clave depende de **toda** la
  clave primaria, no de una parte (ej. `precioUnitario` en ORDENES_DETALLE dependía solo del
  producto).
- **3FN (Tercera Forma Normal):** cumple 2FN, y ningún atributo no clave depende de otro
  atributo no clave — sin dependencias transitivas (ej. `categoria`/`subCategoria` como texto
  libre en PRODUCTOS en vez de una FK a CATEGORIAS).

## Verificaciones empíricas realizadas

- **Redundancia de `precioUnitario`:** se confirmó que coincidía exactamente con el precio de
  catálogo en las 319.745 filas de ORDENES_DETALLE — valida la decisión de eliminarlo en la
  normalización.
- **Clave compuesta de INVENTARIO:** se verificó que no existen duplicados en la combinación
  `(idSucursal, idProducto)` — la clave compuesta identifica cada registro de forma única.
