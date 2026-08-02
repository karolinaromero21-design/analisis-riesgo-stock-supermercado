-- ============================================================
-- 01_ddl_creacion_tablas.sql
-- Creación de la base de datos.
--
-- Nota: las 9 tablas originales (categorias, clientes, productos,
-- sucursales, cajeros, inventario, ordenes, ordenes_detalle,
-- devoluciones) NO se crean con DDL manual. Se generan
-- automáticamente al correr python/carga_datos_mysql.py, que
-- infiere el esquema de cada tabla a partir de los archivos
-- CSV/Excel de origen (vía pandas + SQLAlchemy `to_sql`).
--
-- El DDL manual en este proyecto aparece recién en la etapa de
-- normalización (ver 04_normalizacion_3fn.sql), donde se definen
-- explícitamente tipos, claves primarias/foráneas e índices.
-- ============================================================

CREATE DATABASE IF NOT EXISTS supermercado;
USE supermercado;
