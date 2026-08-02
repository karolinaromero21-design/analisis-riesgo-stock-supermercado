-- ============================================================
-- 05_stored_procedure_trigger.sql
-- Automatización: Stored Procedure + Trigger para el monitoreo
-- de riesgo de stock.
--
-- NOTA IMPORTANTE: estos objetos se diseñaron sobre un modelo
-- teórico de INVENTARIO que incluye cantidadParaReposicion y
-- reposicionPedida (ver sql/04_normalizacion_3fn.sql). Verificar
-- que esas columnas existan en tu instancia real antes de correr
-- este script — en el export de datos usado para el análisis final,
-- la tabla INVENTARIO solo tenía idSucursal, idProducto y
-- cantidadEnStock.
-- ============================================================

-- --- Stored Procedure: reporte de productos en riesgo por provincia ---
DELIMITER $$
CREATE PROCEDURE sp_reporte_riesgo_stock(IN p_provincia VARCHAR(100))
BEGIN
  DECLARE v_total INT DEFAULT 0;

  SELECT COUNT(*) INTO v_total
  FROM inventario i
  JOIN sucursales s ON s.idSucursal = i.idSucursal
  WHERE s.provincia = p_provincia
    AND i.cantidadEnStock < i.cantidadParaReposicion;

  SELECT CONCAT('Productos en riesgo en ', p_provincia, ': ', v_total) AS resumen;

  SELECT
    s.nombre AS sucursal,
    p.descripcion AS producto,
    p.categoria,
    i.cantidadEnStock AS stock_actual,
    i.cantidadParaReposicion AS umbral,
    i.reposicionPedida AS pedido_activo,
    ROUND(i.cantidadEnStock / NULLIF(i.cantidadParaReposicion, 0) * 100, 1) AS pct_del_umbral
  FROM inventario i
  JOIN sucursales s ON s.idSucursal = i.idSucursal
  JOIN productos p ON p.idProducto = i.idProducto
  WHERE s.provincia = p_provincia
    AND i.cantidadEnStock < i.cantidadParaReposicion
  ORDER BY i.cantidadEnStock ASC;
END $$
DELIMITER ;

-- Uso:
-- CALL sp_reporte_riesgo_stock('BUENOS AIRES');


-- --- Tabla auxiliar para registrar alertas automáticas ---
CREATE TABLE alertas_reposicion (
  idAlerta INT AUTO_INCREMENT PRIMARY KEY,
  fechaAlerta DATETIME DEFAULT NOW(),
  idSucursal INT,
  idProducto INT,
  stockAnterior INT,
  stockNuevo INT,
  umbral INT
);

-- --- Trigger: registra una alerta cuando el stock cruza el umbral hacia abajo ---
DELIMITER $$
CREATE TRIGGER trg_alerta_reposicion
AFTER UPDATE ON inventario
FOR EACH ROW
BEGIN
  IF NEW.cantidadEnStock < NEW.cantidadParaReposicion
     AND OLD.cantidadEnStock >= OLD.cantidadParaReposicion THEN
    INSERT INTO alertas_reposicion (
      idSucursal, idProducto, stockAnterior, stockNuevo, umbral
    ) VALUES (
      NEW.idSucursal, NEW.idProducto,
      OLD.cantidadEnStock, NEW.cantidadEnStock,
      NEW.cantidadParaReposicion
    );
  END IF;
END $$
DELIMITER ;
