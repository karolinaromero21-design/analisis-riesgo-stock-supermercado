-- ============================================================
-- 03_consultas_diagnosticas.sql
-- Capa DIAGNÓSTICA: ¿por qué pasó?
-- ============================================================

-- 1. ¿Hay productos en inventario que nunca se vendieron? (primer hallazgo)
-- LEFT JOIN conserva todas las filas de inventario, tengan o no venta asociada;
-- el filtro se queda solo con las que no encontraron ninguna coincidencia.
SELECT DISTINCT
  i.idProducto,
  p.descripcion AS 'Descripcion',
  p.categoria AS 'Categoria'
FROM inventario i
LEFT JOIN ordenes_detalle od ON od.idProducto = i.idProducto
JOIN productos p ON p.idProducto = i.idProducto
WHERE od.idProducto IS NULL;
-- Resultado: 0 filas → no hay stock muerto por ausencia total de demanda.

-- 2. Devoluciones agrupadas por motivo
SELECT
  d.motivoDevolucion AS 'Motivo',
  COUNT(*) AS 'Total Devoluciones'
FROM devoluciones d
GROUP BY d.motivoDevolucion
ORDER BY COUNT(*) DESC;

-- 3. Clientes que compraron en más de 2 sucursales distintas
SELECT
  c.apellido AS 'Apellido',
  c.nombre AS 'Nombre',
  c.idCliente AS 'ID Cliente',
  COUNT(DISTINCT o.idSucursal) AS 'Sucursales Distintas'
FROM clientes c
JOIN ordenes o ON o.idCliente = c.idCliente
GROUP BY c.idCliente, c.apellido, c.nombre
HAVING COUNT(DISTINCT o.idSucursal) > 2
ORDER BY COUNT(DISTINCT o.idSucursal) DESC;

-- 4. Productos devueltos más de 5 veces
SELECT
  d.idProducto,
  p.descripcion AS 'Descripcion',
  p.categoria AS 'Categoria',
  COUNT(*) AS 'Total Devoluciones'
FROM devoluciones d
JOIN productos p ON p.idProducto = d.idProducto
GROUP BY d.idProducto, p.descripcion, p.categoria
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;

-- 5. Sucursales con ventas superiores a $500.000 en 2021
-- WHERE filtra filas antes de agrupar (año 2021);
-- HAVING filtra después de agrupar, sobre el SUM ya calculado.
SELECT
  s.nombre AS 'Sucursal',
  COUNT(o.idOrden) AS 'Cantidad Ordenes',
  SUM(o.montoTotal) AS 'Monto Total'
FROM ordenes o
JOIN sucursales s ON s.idSucursal = o.idSucursal
WHERE YEAR(o.fechaCompra) = 2021
GROUP BY s.idSucursal, s.nombre
HAVING SUM(o.montoTotal) > 500000
ORDER BY SUM(o.montoTotal) DESC;
