USE GD2C2024
GO

-- Obtener el cuatrimestre

CREATE FUNCTION [EXEL_ENTES].getCuatrimestre (@fecha DATE)
RETURNS SMALLINT
AS BEGIN
DECLARE @nro_cuatrimestre SMALLINT
SET @nro_cuatrimestre =
	CASE
		WHEN MONTH(@fecha) BETWEEN 1 AND 4 THEN 1
		WHEN MONTH(@fecha) BETWEEN 5 AND 8 THEN 2
		WHEN MONTH(@fecha) BETWEEN 9 AND 12 THEN 3
	END

RETURN @nro_cuatrimestre

END
GO



-- Obtener el rango etario
CREATE FUNCTION [EXEL_ENTES].getRangoEtario (@fecha_nacimiento DATE)
RETURNS NVARCHAR(11)
AS
BEGIN
DECLARE @edad_actual INT
DECLARE @rango NVARCHAR(11)
IF (@fecha_nacimiento IS NULL)
	RETURN 'Indefinido'

SET @edad_actual = CAST(DATEDIFF(DAY, @fecha_nacimiento, GETDATE()) / 365.25 AS INT)

SET @rango =
	CASE
		WHEN @edad_actual < 25 THEN '< 25'
		WHEN @edad_actual >= 25 AND @edad_actual < 35 THEN '25 - 35'
		WHEN @edad_actual >= 35 AND @edad_actual < 50 THEN '35 - 50'
		WHEN @edad_actual >= 50 THEN '> 50'
	END

RETURN @rango
END
GO

-- Obtener turno
CREATE FUNCTION [EXEL_ENTES].getTurno (@fecha DATETIME)
RETURNS NVARCHAR(14)
AS
BEGIN
	DECLARE @hora INT
	DECLARE @turno NVARCHAR(14) 

	SET @hora = CAST(REPLACE(CONVERT(NVARCHAR(255), @fecha, 108), ':', '') AS INT)

	SET @turno =
		CASE 
			WHEN @hora < 60000 THEN '00:00 - 06:00'
			WHEN @hora >= 60000 AND @hora < 120000 THEN '06:00 - 12:00'
			WHEN @hora >= 120000 AND @hora < 180000 THEN '12:00 - 18:00'
			WHEN @hora >= 180000 AND @hora < 240000 THEN '18:00 - 24:00'
		END

	RETURN @turno
END
GO

/* ------- FIN DE FUNCIONES AUXILIARES ------- */

IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Hecho_Envio')
DROP TABLE [EXEL_ENTES].BI_Hecho_Envio
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Hecho_Compra')
DROP TABLE [EXEL_ENTES].BI_Hecho_Compra
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Hecho_Venta')
DROP TABLE [EXEL_ENTES].BI_Hecho_Venta
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_RubroSubrubro')
DROP TABLE [EXEL_ENTES].BI_RubroSubrubro
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_TipoMedioPago')
DROP TABLE [EXEL_ENTES].BI_TipoMedioPago
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_TipoEnvio')
DROP TABLE [EXEL_ENTES].BI_TipoEnvio
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_RangoHorario')
DROP TABLE [EXEL_ENTES].BI_RangoHorario
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Rango_Etario')
DROP TABLE [EXEL_ENTES].BI_Rango_Etario
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Ubicacion')
DROP TABLE [EXEL_ENTES].BI_Ubicacion
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Tiempo')
DROP TABLE [EXEL_ENTES].BI_Tiempo


/* ------- INICIO DE CREACION DE LAS DIMENSIONES ------- */
CREATE TABLE [EXEL_ENTES].BI_Tiempo (
	bi_tiempo_codigo INT IDENTITY(1,1) NOT NULL,
	bi_tiempo_anio DECIMAL(18,0),
	bi_tiempo_cuatri SMALLINT CHECK (bi_tiempo_cuatri BETWEEN 1 AND 3),
	bi_tiempo_mes DECIMAL(18,0) CHECK (bi_tiempo_mes BETWEEN 1 AND 12),
	CONSTRAINT [PK_BI_Tiempo] PRIMARY KEY (bi_tiempo_codigo)
);

CREATE TABLE [EXEL_ENTES].BI_Ubicacion (
	bi_ubi_codigo INT IDENTITY(1,1) NOT NULL,
	bi_ubi_provincia NVARCHAR(255),
	bi_ubi_localidad NVARCHAR(255),
	CONSTRAINT [PK_BI_Ubicacion] PRIMARY KEY (bi_ubi_codigo)
);

CREATE TABLE [EXEL_ENTES].BI_Rango_Etario (
	bi_rango_etario_codigo INT IDENTITY(1,1) NOT NULL,
	bi_rango_etario_desc NVARCHAR(255),
	CONSTRAINT [PK_BI_Rango_Etario] PRIMARY KEY (bi_rango_etario_codigo)
);
-- Tabla de Dimensión Rango Horario (Ventas)
CREATE TABLE [EXEL_ENTES].BI_RangoHorario (
	rango_horario_id INT IDENTITY(1,1) NOT NULL,
	rango NVARCHAR(15),
	CONSTRAINT [PK_BI_RangoHorario] PRIMARY KEY (rango_horario_id)
);

-- Tabla de Dimensión TipoEnvío
CREATE TABLE [EXEL_ENTES].BI_TipoEnvio (
	bi_tipo_envio_codigo INT NOT NULL,
	bi_tipo_envio_descripcion NVARCHAR(255),
	CONSTRAINT [PK_BI_Envio] PRIMARY KEY (bi_tipo_envio_codigo)
);

-- Tabla de Dimensión Tipo Medio de Pago
	CREATE TABLE [EXEL_ENTES].BI_TipoMedioPago (
	bi_tipoMedioPago_Codigo INT NOT NULL,
	descripcion_tipo_medio_pago NVARCHAR(255),
	CONSTRAINT [PK_BI_MedioPago] PRIMARY KEY (bi_tipoMedioPago_Codigo)
);

-- Tabla de Dimensión Rubro/Subrubro
CREATE TABLE [EXEL_ENTES].BI_RubroSubrubro (
	bi_rubro_subrubro_codigo INT IDENTITY(1,1) NOT NULL,
	rubro NVARCHAR(255),
	subrubro NVARCHAR(255),
	CONSTRAINT [PK_BI_Rubro_Subrubro] PRIMARY KEY (bi_rubro_subrubro_codigo)
);

/* ------- INICIO DE CREACION DE LOS HECHOS------- */

CREATE TABLE [EXEL_ENTES].[BI_Hecho_Venta] (
    codigo_ubicacion INT NOT NULL,
    codigo_tiempo INT NOT NULL,
    codigo_rango_etario_cliente INT NOT NULL,
    codigo_medio_pago INT NOT NULL,
    codigo_rubro INT NOT NULL,
    cantidad_ventas INT NOT NULL,
    sumatoria_importe DECIMAL(18, 2) NOT NULL,
    importe_cuotas DECIMAL(18, 2) NULL,
    cantidad_ventas_cuotas INT NULL,
    CONSTRAINT [PK_BI_Hecho_Venta] PRIMARY KEY (codigo_ubicacion, codigo_tiempo, codigo_rango_etario_cliente, codigo_medio_pago, codigo_rubro),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_Ubicacion] FOREIGN KEY (codigo_ubicacion) REFERENCES [EXEL_ENTES].[BI_Ubicacion](bi_ubi_codigo),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [EXEL_ENTES].[BI_Tiempo](bi_tiempo_codigo),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_Rango_Etario] FOREIGN KEY (codigo_rango_etario_cliente) REFERENCES [EXEL_ENTES].[BI_Rango_Etario](bi_rango_etario_codigo),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_Medio_Pago] FOREIGN KEY (codigo_medio_pago) REFERENCES [EXEL_ENTES].[BI_TipoMedioPago](bi_tipoMedioPago_Codigo),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_Rubro] FOREIGN KEY (codigo_rubro) REFERENCES [EXEL_ENTES].[BI_Rubro](rubro_id)
);

CREATE TABLE [EXEL_ENTES].[BI_Hecho_Compra] (
    codigo_tiempo INT NOT NULL,
    codigo_turno INT NOT NULL,
    cantidad_articulos INT NOT NULL,
    cantidad_tickets INT NOT NULL,
    monto_total DECIMAL(18, 2) NOT NULL,
    descuento_total DECIMAL(18, 2),
    CONSTRAINT [PK_BI_Hecho_Compra] PRIMARY KEY (codigo_turno, codigo_tiempo),
    CONSTRAINT [FK_BI_Hecho_Compra_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [EXEL_ENTES].[BI_Tiempo](bi_tiempo_codigo),
    CONSTRAINT [FK_BI_Hecho_Compra_BI_Turno] FOREIGN KEY (codigo_turno) REFERENCES [EXEL_ENTES].[BI_Turno](bi_turno_codigo)
);


CREATE TABLE [EXEL_ENTES].[BI_Hecho_Envio] (
    codigo_sucursal INT NOT NULL,
    codigo_tiempo INT NOT NULL,
    codigo_ubicacion_cliente INT NOT NULL,
    cantidad_envios INT NOT NULL,
    envios_cumplidos INT NOT NULL,
    costo_total_envios DECIMAL(18, 2) NOT NULL,
    CONSTRAINT [PK_BI_Hecho_Envio] PRIMARY KEY (codigo_sucursal, codigo_tiempo, codigo_ubicacion_cliente),
    CONSTRAINT [FK_BI_Hecho_Envio_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [EXEL_ENTES].[BI_Tiempo](bi_tiempo_codigo),
    CONSTRAINT [FK_BI_Hecho_Envio_BI_Ubicacion] FOREIGN KEY (codigo_ubicacion_cliente) REFERENCES [EXEL_ENTES].[BI_Ubicacion](bi_ubi_codigo)
);

/* ------- FIN DE CREACION DE HECHOS ------- */



/* ------- INICIO DE CARGA DE LAS DIMENSIONES ------- */

-- Carga de dimensión Tiempo		OK
INSERT INTO [EXEL_ENTES].[BI_Tiempo] (bi_tiempo_anio, bi_tiempo_cuatri, bi_tiempo_mes)
SELECT DISTINCT 
    YEAR(fecha) AS anio,
    [EXEL_ENTES].getCuatrimestre(fecha) AS cuatri,
    MONTH(fecha) AS mes
FROM (
    SELECT Fecha_Programada AS fecha 
	FROM [EXEL_ENTES].Envio
    
	UNION

    SELECT Fecha_Entrega AS fecha 
	FROM [EXEL_ENTES].Envio

    UNION

    SELECT p.Fecha AS fecha 
	FROM [EXEL_ENTES].Pago p
) AS fechas;

-- Carga de dimensión Ubicación		OK
INSERT INTO [EXEL_ENTES].[BI_Ubicacion] (bi_ubi_provincia, bi_ubi_localidad)
SELECT DISTINCT 
    provincia.Descripcion,
    localidad.Descripcion
FROM [EXEL_ENTES].Localidad AS localidad
JOIN [EXEL_ENTES].Provincia AS provincia ON localidad.Codigo_Provincia = provincia.Codigo_Provincia;

-- Cargar Dimensiones de Rangos		OK
INSERT INTO [EXEL_ENTES].BI_Rango_Etario (bi_rango_etario_desc)
VALUES ('< 25'), ('25 - 35'), ('35 - 50'), ('> 50');

INSERT INTO [EXEL_ENTES].BI_RangoHorario (rango)
VALUES ('00:00 - 06:00'), ('06:00 - 12:00'), ('12:00 - 18:00'), ('18:00 - 24:00');

-- Carga de dimensión Turno		OK
INSERT INTO [EXEL_ENTES].[BI_Turno] (bi_turno_desc)
VALUES ('00:00 - 06:00'), ('06:00 - 12:00'), ('12:00 - 18:00'), ('18:00 - 24:00');

-- Carga de dimensión Tipo Medio de Pago			OK
INSERT INTO [EXEL_ENTES].[BI_TipoMedioPago] (bi_tipoMedioPago_Codigo, descripcion_tipo_medio_pago)
SELECT DISTINCT t.Tipo_Medio_Pago_Codigo, Descripcion_tipo_medio_de_pago
FROM [EXEL_ENTES].TipoMedioDePago AS t

-- Carga de dimensión Rubro y Subrubro (en una tabla BI_Rubro)		OK
INSERT INTO [EXEL_ENTES].[BI_Rubro] (rubro, subrubro)
SELECT DISTINCT 
    rubro.Descripcion AS rubro,
    subrubro.Descripcion AS subrubro
FROM [EXEL_ENTES].Rubro AS rubro
JOIN [EXEL_ENTES].Subrubro AS subrubro ON rubro.Codigo_Rubro = subrubro.Codigo_Rubro;

-- Carga de dimension Tipo Envio		OK
INSERT INTO EXEL_ENTES.BI_TipoEnvio (bi_tipo_envio_codigo, bi_tipo_envio_descripcion)
SELECT DISTINCT tipo.Codigo_TipoEnvio, tipo.Descripcion
FROM EXEL_ENTES.TipoEnvio tipo


/* ------- FIN DE CARGA DE LAS DIMENSIONES ------- */

/* ------- INICIO DE CARGA DE LOS HECHOS ------- */

 ------- INICIO DE CARGA DE HECHOS PARA BI_Hecho_Venta ------- /

INSERT INTO [EXEL_ENTES].[BI_Hecho_Venta] (
    codigo_ubicacion, 
    codigo_tiempo, 
    codigo_rango_etario_cliente, 
    codigo_medio_pago, 
    codigo_rubro
)
SELECT 
    bi_ubi.bi_ubi_codigo, 
    bi_tiempo.bi_tiempo_codigo, 
    bi_re.bi_rango_etario_codigo, 
    bi_mp.bi_tipoMedioPago_Codigo, 
    bi_rubrosubrubro.bi_rubro_subrubro_codigo
FROM [EXEL_ENTES].Venta v
JOIN [EXEL_ENTES].Cliente c ON v.codigo_cliente = c.Codigo_Usuario
join EXEL_ENTES.Publicacion publi on publi.Codigo_Publicacion = v.Codigo_Publicacion 
join EXEL_ENTES.Almacen almacen on almacen.Codigo_Almacen = publi.Codigo_Almacen
join EXEL_ENTES.Localidad localidad on almacen.Codigo_Localidad = localidad.Codigo_Localidad
join EXEL_ENTES.Provincia provincia on provincia.Codigo_Provincia = localidad.Codigo_Provincia
JOIN [EXEL_ENTES].[BI_Ubicacion] bi_ubi on bi_ubi.bi_ubi_localidad = localidad.Descripcion and bi_ubi.bi_ubi_provincia = provincia.Descripcion
JOIN [EXEL_ENTES].[BI_Tiempo] bi_tiempo ON YEAR(v.fecha_venta) = bi_tiempo.bi_tiempo_anio AND MONTH(v.fecha_venta) = bi_tiempo.bi_tiempo_mes
JOIN [EXEL_ENTES].[BI_Rango_Etario] bi_re ON [EXEL_ENTES].getRangoEtario(c.Cliente_Fecha_Nac) = bi_re.bi_rango_etario_desc
join EXEL_ENTES.Pago pago on pago.Codigo_Numero_Venta = v.Numero_Venta
join EXEL_ENTES.MedioDePago medioPago on pago.Codigo_MedioPago = medioPago.Codigo_MedioPago
join EXEL_ENTES.TipoMedioDePago tipoPago on medioPago.Tipo_Medio_Pago_Codigo = tipoPago.Tipo_Medio_Pago_Codigo
JOIN [EXEL_ENTES].[BI_TipoMedioPago] bi_mp ON tipoPago.Tipo_Medio_Pago_Codigo = bi_mp.bi_tipoMedioPago_Codigo
join EXEL_ENTES.Producto producto on publi.Codigo_Publicacion = producto.Codigo_Publicacion
join EXEL_ENTES.Subrubro subrubro on producto.Codigo_Subrubro = subrubro.Codigo_Subrubro
join EXEL_ENTES.Rubro rubro on rubro.Codigo_Rubro = subrubro.Codigo_Rubro
JOIN [EXEL_ENTES].[BI_RubroSubrubro] bi_rubrosubrubro ON rubro.Descripcion = bi_rubrosubrubro.rubro and subrubro.Descripcion = bi_rubrosubrubro.subrubro
GROUP BY 
    bi_ubi.bi_ubi_codigo, 
    bi_tiempo.bi_tiempo_codigo, 
    bi_re.bi_rango_etario_codigo, 
    bi_mp.bi_tipoMedioPago_Codigo, 
    bi_rubrosubrubro.bi_rubro_subrubro_codigo

 ------- FIN DE CARGA DE HECHOS PARA BI_Hecho_Venta ------- 


/* Carga de Hecho BI_Hecho_Compra */
INSERT INTO [EXEL_ENTES].[BI_Hecho_Compra] (
    codigo_turno, codigo_tiempo, total_articulos_vendidos,
    cantidad_tickets, descuento_aplicado, monto_total_ticket
)
SELECT 
    bi_turno.bi_turno_codigo,
    bi_tiempo.bi_tiempo_codigo,
    SUM(item.cantidad),
    COUNT(DISTINCT c.codigo),
    SUM(c.descuento_aplicado),
    SUM(c.monto_total)
FROM [EXEL_ENTES].Compra c
JOIN [EXEL_ENTES].ItemCompra item ON c.codigo = item.codigo_compra
JOIN [EXEL_ENTES].[BI_Tiempo] bi_tiempo ON YEAR(c.fecha) = bi_tiempo.bi_tiempo_anio AND MONTH(c.fecha) = bi_tiempo.bi_tiempo_mes
JOIN [EXEL_ENTES].[BI_Turno] bi_turno ON [EXEL_ENTES].getTurno(c.fecha) = bi_turno.bi_turno_desc
GROUP BY 
    bi_turno.bi_turno_codigo,
    bi_tiempo.bi_tiempo_codigo;
GO

/* Carga de Hecho BI_Hecho_Envio */
INSERT INTO [EXEL_ENTES].[BI_Hecho_Envio] (
    codigo_tiempo, codigo_rango_etario, codigo_ubicacion,
    cantidad_envios_cumplidos, cantidad_envios, costo_total
)
SELECT 
    bi_tiempo.bi_tiempo_codigo,
    bi_re.bi_rango_etario_codigo,
    bi_ubi.bi_ubi_codigo,
    COUNT(CASE WHEN DATEDIFF(DAY, e.fecha_entrega, e.fecha_programada) = 0 THEN 1 ELSE NULL END),
    COUNT(*),
    SUM(e.costo)
FROM [EXEL_ENTES].Envio e
JOIN [EXEL_ENTES].Cliente c ON e.codigo_cliente = c.codigo
JOIN [EXEL_ENTES].[BI_Ubicacion] bi_ubi ON c.codigo_ubicacion = bi_ubi.bi_ubi_codigo
JOIN [EXEL_ENTES].[BI_Tiempo] bi_tiempo ON YEAR(e.fecha_programada) = bi_tiempo.bi_tiempo_anio AND MONTH(e.fecha_programada) = bi_tiempo.bi_tiempo_mes
JOIN [EXEL_ENTES].[BI_Rango_Etario] bi_re ON [EXEL_ENTES].getRangoEtario(c.fecha_nacimiento) = bi_re.bi_rango_etario_desc
GROUP BY 
    bi_tiempo.bi_tiempo_codigo,
    bi_re.bi_rango_etario_codigo,
    bi_ubi.bi_ubi_codigo;
GO

/* ------- FIN DE CARGA DE LOS HECHOS ------- */

/* ------- CREACIÓN DE VISTAS ------- */

-- 1. Promedio de tiempo de publicaciones
CREATE VIEW [EXEL_ENTES].BI_promedio_tiempo_publicacion AS
SELECT
    bi_t.bi_tiempo_anio AS anio,
    bi_t.bi_tiempo_cuatri AS cuatrimestre,
    bi_cs.bi_cate_subc_nombre_subc AS subrubro,
    AVG(DATEDIFF(DAY, p.fecha_inicio, p.fecha_fin)) AS promedio_tiempo
FROM [EXEL_ENTES].Publicacion p
JOIN [EXEL_ENTES].[BI_Tiempo] bi_t ON YEAR(p.fecha_inicio) = bi_t.bi_tiempo_anio AND [EXEL_ENTES].getCuatrimestre(p.fecha_inicio) = bi_t.bi_tiempo_cuatri
JOIN [EXEL_ENTES].[BI_Categoria_Subcategoria] bi_cs ON p.codigo_subcategoria = bi_cs.bi_cate_subc_codigo
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_cuatri, bi_cs.bi_cate_subc_nombre_subc;
GO

-- 2. Promedio de Stock Inicial
CREATE VIEW [EXEL_ENTES].BI_promedio_stock_inicial AS
SELECT
    bi_t.bi_tiempo_anio AS anio,
    m.marca_nombre AS marca,
    AVG(p.stock_inicial) AS promedio_stock
FROM [EXEL_ENTES].Publicacion p
JOIN [EXEL_ENTES].Producto prod ON p.codigo_producto = prod.codigo_producto
JOIN [EXEL_ENTES].Marca m ON prod.codigo_marca = m.codigo_marca
JOIN [EXEL_ENTES].[BI_Tiempo] bi_t ON YEAR(p.fecha_inicio) = bi_t.bi_tiempo_anio
GROUP BY bi_t.bi_tiempo_anio, m.marca_nombre;
GO

-- 3. Venta promedio mensual
CREATE VIEW [EXEL_ENTES].BI_venta_promedio_mensual AS
SELECT
    bi_u.bi_ubi_provincia AS provincia,
    bi_t.bi_tiempo_anio AS anio,
    bi_t.bi_tiempo_mes AS mes,
    SUM(v.total) / NULLIF(COUNT(v.codigo), 0) AS venta_promedio
FROM [EXEL_ENTES].Venta v
JOIN [EXEL_ENTES].[BI_Ubicacion] bi_u ON v.codigo_ubicacion_almacen = bi_u.bi_ubi_codigo
JOIN [EXEL_ENTES].[BI_Tiempo] bi_t ON YEAR(v.fecha) = bi_t.bi_tiempo_anio AND MONTH(v.fecha) = bi_t.bi_tiempo_mes
GROUP BY bi_u.bi_ubi_provincia, bi_t.bi_tiempo_anio, bi_t.bi_tiempo_mes;
GO

-- 4. Rendimiento de rubros
CREATE VIEW [EXEL_ENTES].BI_rendimiento_rubros AS
SELECT TOP 5
    bi_t.bi_tiempo_anio AS anio,
    bi_t.bi_tiempo_cuatri AS cuatrimestre,
    bi_u.bi_ubi_localidad AS localidad,
    bi_re.bi_rango_etario_desc AS rango_etario,
    r.rubro_nombre AS rubro,
    COUNT(v.codigo) AS ventas_totales
FROM [EXEL_ENTES].Venta v
JOIN [EXEL_ENTES].[BI_Tiempo] bi_t ON YEAR(v.fecha) = bi_t.bi_tiempo_anio AND [EXEL_ENTES].getCuatrimestre(v.fecha) = bi_t.bi_tiempo_cuatri
JOIN [EXEL_ENTES].[BI_Ubicacion] bi_u ON v.codigo_ubicacion_cliente = bi_u.bi_ubi_codigo
JOIN [EXEL_ENTES].[BI_Rango_Etario] bi_re ON [EXEL_ENTES].getRangoEtario(v.codigo_cliente) = bi_re.bi_rango_etario_codigo
JOIN [EXEL_ENTES].Producto prod ON v.codigo_producto = prod.codigo_producto
JOIN [EXEL_ENTES].Rubro r ON prod.codigo_rubro = r.codigo_rubro
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_cuatri, bi_u.bi_ubi_localidad, bi_re.bi_rango_etario_desc, r.rubro_nombre
ORDER BY ventas_totales DESC;
GO

-- 5. Volumen de ventas
CREATE VIEW [EXEL_ENTES].BI_volumen_ventas AS
SELECT
    bi_turno.bi_turno_desc AS rango_horario,
    bi_t.bi_tiempo_anio AS anio,
    bi_t.bi_tiempo_mes AS mes,
    COUNT(v.codigo) AS volumen_ventas
FROM [EXEL_ENTES].Venta v
JOIN [EXEL_ENTES].[BI_Tiempo] bi_t ON YEAR(v.fecha) = bi_t.bi_tiempo_anio AND MONTH(v.fecha) = bi_t.bi_tiempo_mes
JOIN [EXEL_ENTES].[BI_Turno] bi_turno ON [EXEL_ENTES].getTurno(v.fecha) = bi_turno.bi_turno_desc
GROUP BY bi_turno.bi_turno_desc, bi_t.bi_tiempo_anio, bi_t.bi_tiempo_mes;
GO

-- 6. Pago en cuotas
CREATE VIEW [EXEL_ENTES].BI_pago_en_cuotas AS
SELECT TOP 3
    bi_u.bi_ubi_localidad AS localidad,
    bi_t.bi_tiempo_anio AS anio,
    bi_t.bi_tiempo_mes AS mes,
    bi_mp.bi_mp_desc AS medio_pago,
    SUM(v.total) AS importe_total_cuotas
FROM [EXEL_ENTES].Venta v
JOIN [EXEL_ENTES].[BI_Ubicacion] bi_u ON v.codigo_ubicacion_cliente = bi_u.bi_ubi_codigo
JOIN [EXEL_ENTES].[BI_Tiempo] bi_t ON YEAR(v.fecha) = bi_t.bi_tiempo_anio AND MONTH(v.fecha) = bi_t.bi_tiempo_mes
JOIN [EXEL_ENTES].[BI_Medio_Pago] bi_mp ON v.codigo_medio_pago = bi_mp.bi_mp_codigo
WHERE v.tipo_pago = 'Cuotas'
GROUP BY bi_u.bi_ubi_localidad, bi_t.bi_tiempo_anio, bi_t.bi_tiempo_mes, bi_mp.bi_mp_desc
ORDER BY importe_total_cuotas DESC;
GO

-- 7. Porcentaje de cumplimiento de envíos en tiempos programados
CREATE VIEW [EXEL_ENTES].BI_porcentaje_cumplimiento_envios AS
SELECT
    bi_t.bi_tiempo_anio AS anio,
    bi_t.bi_tiempo_mes AS mes,
    bi_u.bi_ubi_provincia AS provincia,
    COUNT(CASE WHEN e.fecha_entrega <= e.fecha_programada THEN 1 ELSE NULL END) * 100.0 / NULLIF(COUNT(e.codigo), 0) AS porcentaje_cumplimiento
FROM [EXEL_ENTES].Envio e
JOIN [EXEL_ENTES].[BI_Tiempo] bi_t ON YEAR(e.fecha_programada) = bi_t.bi_tiempo_anio AND MONTH(e.fecha_programada) = bi_t.bi_tiempo_mes
JOIN [EXEL_ENTES].[BI_Ubicacion] bi_u ON e.codigo_ubicacion_almacen = bi_u.bi_ubi_codigo
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_mes, bi_u.bi_ubi_provincia;
GO

-- 8. Localidades que pagan mayor costo de envío
CREATE VIEW [EXEL_ENTES].BI_localidades_mayor_costo_envio AS
SELECT TOP 5
    bi_u.bi_ubi_localidad AS localidad,
    SUM(e.costo) AS costo_total_envio
FROM [EXEL_ENTES].Envio e
JOIN [EXEL_ENTES].[BI_Ubicacion] bi_u ON e.codigo_ubicacion_cliente = bi_u.bi_ubi_codigo
GROUP BY bi_u.bi_ubi_localidad
ORDER BY costo_total_envio DESC;
GO

-- 9. Porcentaje de facturación por concepto
CREATE VIEW [EXEL_ENTES].BI_porcentaje_facturacion_concepto AS
SELECT
    bi_t.bi_tiempo_anio AS anio,
    bi_t.bi_tiempo_mes AS mes,
    c.concepto_nombre AS concepto,
    SUM(f.total_factura) * 100.0 / NULLIF((SELECT SUM(total_factura) FROM [EXEL_ENTES].Factura WHERE YEAR(fecha) = bi_t.bi_tiempo_anio AND MONTH(fecha) = bi_t.bi_tiempo_mes), 0) AS porcentaje_facturacion
FROM [EXEL_ENTES].Factura f
JOIN [EXEL_ENTES].[BI_Tiempo] bi_t ON YEAR(f.fecha) = bi_t.bi_tiempo_anio AND MONTH(f.fecha) = bi_t.bi_tiempo_mes
JOIN [EXEL_ENTES].Concepto c ON f.codigo_concepto = c.codigo_concepto
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_mes, c.concepto_nombre;
GO

-- 10. Facturación por provincia
CREATE VIEW [EXEL_ENTES].BI_facturacion_por_provincia AS
SELECT
    bi_t.bi_tiempo_anio AS anio,
    bi_t.bi_tiempo_cuatri AS cuatrimestre,
    bi_u.bi_ubi_provincia AS provincia,
    SUM(f.total_factura) AS total_facturacion
FROM [EXEL_ENTES].Factura f
JOIN [EXEL_ENTES].[BI_Ubicacion] bi_u ON f.codigo_provincia_vendedor = bi_u.bi_ubi_codigo
JOIN [EXEL_ENTES].[BI_Tiempo] bi_t ON YEAR(f.fecha) = bi_t.bi_tiempo_anio AND [EXEL_ENTES].getCuatrimestre(f.fecha) = bi_t.bi_tiempo_cuatri
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_cuatri, bi_u.bi_ubi_provincia;
GO

/* ------- FIN DE CREACION DE VISTAS ------- */
