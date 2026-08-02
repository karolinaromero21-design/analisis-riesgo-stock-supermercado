-- ============================================================
-- 02_consultas_descriptivas.sql
-- Capa DESCRIPTIVA: ¿qué pasó?
-- ============================================================

-- 1. Todos los campos de CATEGORIAS, ordenados alfabéticamente
SELECT * FROM categorias
ORDER BY categoria ASC;

-- 2. ID, descripción y categoría de cada producto
SELECT
  p.idProducto AS 'ID Producto',
  p.descripcion AS 'Descripcion',
  p.categoria AS 'Categoria'
FROM productos p
ORDER BY p.categoria, p.descripcion;

-- 3. Sucursales de la provincia de Buenos Aires
SELECT
  idSucursal AS 'Codigo',
  nombre AS 'Nombre',
  localidad AS 'Localidad'
FROM sucursales
WHERE provincia = 'BUENOS AIRES'
ORDER BY localidad, nombre;

-- 4. Top 10 clientes por gasto total
SELECT
  c.apellido AS 'Apellido',
  c.nombre AS 'Nombre',
  SUM(o.montoTotal) AS 'Monto Total Gastado'
FROM clientes c
JOIN ordenes o ON o.idCliente = c.idCliente
GROUP BY c.idCliente, c.apellido, c.nombre
ORDER BY SUM(o.montoTotal) DESC
LIMIT 10;

-- 5. Órdenes realizadas entre el 2021-06-01 y el 2021-12-31
SELECT
  idOrden AS 'ID Orden',
  fechaCompra AS 'Fecha',
  montoTotal AS 'Monto Total'
FROM ordenes
WHERE fechaCompra BETWEEN '2021-06-01' AND '2021-12-31'
ORDER BY montoTotal DESC;

-- 6. Monto promedio de las órdenes por mes y año
SELECT
  YEAR(fechaCompra) AS 'Anio',
  MONTH(fechaCompra) AS 'Mes',
  ROUND(AVG(montoTotal), 2) AS 'Monto Promedio'
FROM ordenes
GROUP BY YEAR(fechaCompra), MONTH(fechaCompra)
ORDER BY YEAR(fechaCompra), MONTH(fechaCompra);

-- 7. Cantidad de órdenes por sucursal
SELECT
  s.nombre AS 'Sucursal',
  COUNT(o.idOrden) AS 'Cantidad de Ordenes'
FROM ordenes o
JOIN sucursales s ON s.idSucursal = o.idSucursal
GROUP BY s.idSucursal, s.nombre
ORDER BY COUNT(o.idOrden) DESC;

-- 8. Top 3 categorías por unidades vendidas
SELECT
  p.categoria AS 'Categoria',
  SUM(od.cantidad) AS 'Total Unidades Vendidas'
FROM ordenes_detalle od
JOIN productos p ON p.idProducto = od.idProducto
GROUP BY p.categoria
ORDER BY SUM(od.cantidad) DESC
LIMIT 3;
