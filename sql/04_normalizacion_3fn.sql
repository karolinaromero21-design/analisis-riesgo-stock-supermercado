-- ============================================================
-- 04_normalizacion_3fn.sql
-- Normalización a Tercera Forma Normal (3FN) + índices.
-- Ver docs/diagnostico_formas_normales.md para el diagnóstico
-- previo (en qué forma normal estaba cada tabla y por qué).
-- ============================================================

-- 1. CATEGORIAS (ya en 3FN, se agrega subCategoria como campo propio)
CREATE TABLE categorias_3fn (
  idCategoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  subCategoria VARCHAR(100)
);

-- 2. SUCURSALES normalizada (horarios extraídos a tabla separada)
CREATE TABLE sucursales_3fn (
  idSucursal INT PRIMARY KEY,
  fechaAlta DATE,
  nombre VARCHAR(150),
  direccion VARCHAR(200),
  localidad VARCHAR(100),
  provincia VARCHAR(100),
  fechaBaja DATE,
  estado VARCHAR(50)
);
CREATE INDEX idx_suc_provincia ON sucursales_3fn (provincia);
CREATE INDEX idx_suc_estado ON sucursales_3fn (estado);

-- 3. HORARIOS_SUCURSAL (grupo repetitivo extraído de SUCURSALES — resuelve 1FN)
CREATE TABLE horarios_sucursal (
  idHorario INT AUTO_INCREMENT PRIMARY KEY,
  idSucursal INT NOT NULL,
  diaSemana VARCHAR(20) NOT NULL,
  horario VARCHAR(50),
  FOREIGN KEY (idSucursal) REFERENCES sucursales_3fn(idSucursal)
);
CREATE INDEX idx_hor_sucursal ON horarios_sucursal (idSucursal);

-- 4. PRODUCTOS normalizada (referencia a CATEGORIAS con FK)
CREATE TABLE productos_3fn (
  idProducto INT PRIMARY KEY,
  fechaAlta DATE,
  descripcion VARCHAR(400),
  precioUnitario DECIMAL(10,2),
  idCategoria INT NOT NULL,
  fechaBaja DATE,
  estado VARCHAR(50),
  FOREIGN KEY (idCategoria) REFERENCES categorias_3fn(idCategoria)
);
CREATE INDEX idx_prod_categoria ON productos_3fn (idCategoria);
CREATE INDEX idx_prod_estado ON productos_3fn (estado);

-- 5. CLIENTES (ya correcta, se agregan índices)
CREATE TABLE clientes_3fn (
  idCliente INT PRIMARY KEY,
  fechaAlta DATE,
  nombre VARCHAR(100),
  apellido VARCHAR(100),
  email VARCHAR(150),
  provincia VARCHAR(100),
  estado VARCHAR(50)
);
CREATE INDEX idx_cli_provincia ON clientes_3fn (provincia);
CREATE INDEX idx_cli_estado ON clientes_3fn (estado);

-- 6. INVENTARIO con PK compuesta y FK formales (resuelve 1FN)
CREATE TABLE inventario_3fn (
  idSucursal INT NOT NULL,
  idProducto INT NOT NULL,
  cantidadEnStock INT DEFAULT 0,
  cantidadParaReposicion INT DEFAULT 0,
  reposicionPedida TINYINT(1) DEFAULT 0,
  cantidadPedida INT,
  PRIMARY KEY (idSucursal, idProducto),
  FOREIGN KEY (idSucursal) REFERENCES sucursales_3fn(idSucursal),
  FOREIGN KEY (idProducto) REFERENCES productos_3fn(idProducto)
);
CREATE INDEX idx_inv_sucursal ON inventario_3fn (idSucursal);
CREATE INDEX idx_inv_producto ON inventario_3fn (idProducto);

-- 7. ORDENES con FK formales
CREATE TABLE ordenes_3fn (
  idOrden INT PRIMARY KEY,
  idCliente INT NOT NULL,
  idSucursal INT NOT NULL,
  fechaCompra DATE,
  montoTotal DECIMAL(12,2),
  metodoDePago VARCHAR(50),
  estado VARCHAR(50),
  FOREIGN KEY (idCliente) REFERENCES clientes_3fn(idCliente),
  FOREIGN KEY (idSucursal) REFERENCES sucursales_3fn(idSucursal)
);
CREATE INDEX idx_ord_cliente ON ordenes_3fn (idCliente);
CREATE INDEX idx_ord_sucursal ON ordenes_3fn (idSucursal);
CREATE INDEX idx_ord_fecha ON ordenes_3fn (fechaCompra);

-- 8. ORDENES_DETALLE normalizada (sin precioUnitario redundante — resuelve 2FN)
-- Verificado empíricamente: precioUnitario coincidía 100% con el de PRODUCTOS
-- en las 319.745 filas, confirmando que era una columna redundante.
CREATE TABLE ordenes_detalle_3fn (
  idOrden INT NOT NULL,
  idProducto INT NOT NULL,
  cantidad INT NOT NULL,
  PRIMARY KEY (idOrden, idProducto),
  FOREIGN KEY (idOrden) REFERENCES ordenes_3fn(idOrden),
  FOREIGN KEY (idProducto) REFERENCES productos_3fn(idProducto)
);
CREATE INDEX idx_od_orden ON ordenes_detalle_3fn (idOrden);
CREATE INDEX idx_od_producto ON ordenes_detalle_3fn (idProducto);

-- 9. DEVOLUCIONES con FK formales
CREATE TABLE devoluciones_3fn (
  idDevolucion INT AUTO_INCREMENT PRIMARY KEY,
  idOrden INT NOT NULL,
  idProducto INT NOT NULL,
  fechaDevolucion DATE,
  motivoDevolucion VARCHAR(200),
  resolucion VARCHAR(100),
  FOREIGN KEY (idOrden) REFERENCES ordenes_3fn(idOrden),
  FOREIGN KEY (idProducto) REFERENCES productos_3fn(idProducto)
);
CREATE INDEX idx_dev_orden ON devoluciones_3fn (idOrden);
CREATE INDEX idx_dev_producto ON devoluciones_3fn (idProducto);

-- Nota: la migración de datos desde las tablas originales a estas tablas
-- normalizadas requiere sentencias INSERT INTO ... SELECT adicionales,
-- no incluidas aquí porque dependen del estado puntual de cada carga.
