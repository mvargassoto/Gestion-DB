USE GD2C2024
GO

-- Obtener el cuatrimestre
IF OBJECT_ID('[EXEL_ENTES].getCuatrimestre', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [EXEL_ENTES].getCuatrimestre;
END

GO
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
IF OBJECT_ID('[EXEL_ENTES].getRangoEtario', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [EXEL_ENTES].getRangoEtario;
END

go
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
IF OBJECT_ID('[EXEL_ENTES].getHorario', 'FN') IS NOT NULL
BEGIN
    DROP FUNCTION [EXEL_ENTES].getHorario;
END

GO
CREATE FUNCTION [EXEL_ENTES].getHorario (@fecha DATETIME)
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

IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Hecho_Facturacion')
DROP TABLE [EXEL_ENTES].BI_Hecho_Facturacion
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Hecho_Envio')
DROP TABLE [EXEL_ENTES].BI_Hecho_Envio
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Hecho_Publicacion')
DROP TABLE [EXEL_ENTES].BI_Hecho_Publicacion
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
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Hecho_Stock')
DROP TABLE [EXEL_ENTES].BI_Hecho_Stock
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Marca')
DROP TABLE [EXEL_ENTES].BI_Marca
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'BI_Tiempo')
DROP TABLE [EXEL_ENTES].BI_Tiempo

/* ------- INICIO DE CREACION DE LAS DIMENSIONES ------- */
-- Tabla de dimension Tiempo
CREATE TABLE [EXEL_ENTES].BI_Tiempo (
	bi_tiempo_codigo INT IDENTITY(1,1) NOT NULL,
	bi_tiempo_anio DECIMAL(18,0),
	bi_tiempo_cuatri SMALLINT CHECK (bi_tiempo_cuatri BETWEEN 1 AND 3),
	bi_tiempo_mes DECIMAL(18,0) CHECK (bi_tiempo_mes BETWEEN 1 AND 12),
	CONSTRAINT [PK_BI_Tiempo] PRIMARY KEY (bi_tiempo_codigo)
);

-- Tabla de dimension Ubicacion
CREATE TABLE [EXEL_ENTES].BI_Ubicacion (
	bi_ubi_codigo INT IDENTITY(1,1) NOT NULL,
	bi_ubi_provincia NVARCHAR(255),
	bi_ubi_localidad NVARCHAR(255),
	CONSTRAINT [PK_BI_Ubicacion] PRIMARY KEY (bi_ubi_codigo)
);

-- Tabla de dimension Rango etario
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

-- Tabla de Dimension Marca necesaria para vista 2
CREATE TABLE [EXEL_ENTES].[BI_Marca] (
    bi_marca_codigo INT NOT NULL,
    descripcion NVARCHAR(50),
    CONSTRAINT [PK_BI_Marca] PRIMARY KEY (bi_marca_codigo)
);


/* ------- INICIO DE CREACION DE LOS HECHOS------- */

CREATE TABLE [EXEL_ENTES].[BI_Hecho_Venta] (
    codigo_ubicacion INT NOT NULL,
    codigo_tiempo INT NOT NULL,
    codigo_rango_etario_cliente INT NOT NULL,
	codigo_rango_horario_venta INT NOT NULL,
    codigo_medio_pago INT NOT NULL,
    codigo_rubrosubrubro INT NOT NULL,
    cantidad_ventas INT NULL,
    sumatoria_importe DECIMAL(18, 2) NULL,
    importe_cuotas DECIMAL(18, 2) NULL,
    CONSTRAINT [PK_BI_Hecho_Venta] PRIMARY KEY (codigo_ubicacion, codigo_tiempo, codigo_rango_etario_cliente, codigo_medio_pago, codigo_rubrosubrubro),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_Ubicacion] FOREIGN KEY (codigo_ubicacion) REFERENCES [EXEL_ENTES].[BI_Ubicacion](bi_ubi_codigo),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [EXEL_ENTES].[BI_Tiempo](bi_tiempo_codigo),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_Rango_Etario] FOREIGN KEY (codigo_rango_etario_cliente) REFERENCES [EXEL_ENTES].[BI_Rango_Etario](bi_rango_etario_codigo),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_Medio_Pago] FOREIGN KEY (codigo_medio_pago) REFERENCES [EXEL_ENTES].[BI_TipoMedioPago](bi_tipoMedioPago_Codigo),
    CONSTRAINT [FK_BI_Hecho_Venta_BI_RubroSubrubro] FOREIGN KEY (codigo_rubrosubrubro) REFERENCES [EXEL_ENTES].[BI_RubroSubrubro](bi_rubro_subrubro_codigo)
);

/* 
NO SE UTILIZA PARA NINGUNA VISTA
CREATE TABLE [EXEL_ENTES].[BI_Hecho_Compra] (
    codigo_tiempo INT NOT NULL,
    codigo_horario INT NOT NULL,
    cantidad_articulos INT NOT NULL,
    cantidad_compras INT NOT NULL,
    monto_total DECIMAL(18, 2) NOT NULL,
    -- descuento_total DECIMAL(18, 2),
    CONSTRAINT [PK_BI_Hecho_Compra] PRIMARY KEY (codigo_horario, codigo_tiempo),
    CONSTRAINT [FK_BI_Hecho_Compra_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [EXEL_ENTES].[BI_Tiempo](bi_tiempo_codigo),
    CONSTRAINT [FK_BI_Hecho_Compra_BI_Horario] FOREIGN KEY (codigo_horario) REFERENCES [EXEL_ENTES].[BI_RangoHorario](rango_horario_id)
); */

-- NECESARIA PARA LA VISTA 1 Y 2
CREATE TABLE [EXEL_ENTES].[BI_Hecho_Publicacion] (
    codigo_tiempo INT NOT NULL,
    codigo_rubro_subrubro INT NOT NULL,
    tiempo_vigencia DECIMAL(18, 2) NOT NULL,
    CONSTRAINT [PK_BI_Hecho_Publicacion] PRIMARY KEY (codigo_tiempo, codigo_rubro_subrubro),
    CONSTRAINT [FK_BI_Hecho_Publicacion_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [EXEL_ENTES].[BI_Tiempo](bi_tiempo_codigo),
    CONSTRAINT [FK_BI_Hecho_Publicacion_BI_RubroSubrubro] FOREIGN KEY (codigo_rubro_subrubro) REFERENCES [EXEL_ENTES].[BI_RubroSubrubro](bi_rubro_subrubro_codigo)
);

-- NECESARIO PARA LA VISTA 2 
CREATE TABLE [EXEL_ENTES].[BI_Hecho_Stock] (
    codigo_tiempo INT NOT NULL,
    codigo_marca INT NOT NULL,
    stock_inicial_promedio DECIMAL(18, 2) NOT NULL,
    CONSTRAINT [PK_BI_Hecho_Stock] PRIMARY KEY (codigo_tiempo, codigo_marca),
    CONSTRAINT [FK_BI_Hecho_Stock_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [EXEL_ENTES].[BI_Tiempo](bi_tiempo_codigo),
    CONSTRAINT [FK_BI_Hecho_Stock_BI_Marca] FOREIGN KEY (codigo_marca) REFERENCES [EXEL_ENTES].[BI_Marca](bi_marca_codigo)
);


CREATE TABLE [EXEL_ENTES].[BI_Hecho_Envio] (
    codigo_tiempo INT NOT NULL,
    codigo_ubicacion_cliente INT NOT NULL,
    cantidad_envios INT NOT NULL,
    envios_cumplidos INT NOT NULL,
    costo_total_envios DECIMAL(18, 2) NOT NULL,
    CONSTRAINT [PK_BI_Hecho_Envio] PRIMARY KEY (codigo_tiempo, codigo_ubicacion_cliente), /* saque codigo_sucursal*/
    CONSTRAINT [FK_BI_Hecho_Envio_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [EXEL_ENTES].[BI_Tiempo](bi_tiempo_codigo),
    CONSTRAINT [FK_BI_Hecho_Envio_BI_Ubicacion] FOREIGN KEY (codigo_ubicacion_cliente) REFERENCES [EXEL_ENTES].[BI_Ubicacion](bi_ubi_codigo)
);

-- NECESARIO PARA VISTA 9
CREATE TABLE [EXEL_ENTES].[BI_Hecho_Facturacion] (
    codigo_tiempo INT NOT NULL,
	codigo_ubicacion INT NOT NULL,
    total_facturado DECIMAL(18, 2) NOT NULL,
    CONSTRAINT [PK_BI_Hecho_Facturacion] PRIMARY KEY (codigo_tiempo, codigo_ubicacion),
    CONSTRAINT [FK_BI_Hecho_Facturacion_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [EXEL_ENTES].[BI_Tiempo](bi_tiempo_codigo),
	CONSTRAINT [FK_BI_Hecho_Facturacion_BI_Ubicacion] FOREIGN KEY (codigo_ubicacion) REFERENCES [EXEL_ENTES].[BI_Ubicacion](bi_ubi_codigo),
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
) as Fechas
order by year(Fechas.fecha) asc, [EXEL_ENTES].getCuatrimestre(Fechas.fecha) asc, month(Fechas.fecha) asc

-- Carga de dimensión Ubicación	  NOTA: va a ser necesario hacer un union de las ubicaciones que existen para almacenes con las de cliente

INSERT INTO [EXEL_ENTES].[BI_Ubicacion] (bi_ubi_provincia, bi_ubi_localidad)
SELECT DISTINCT 
    ubi.provincia, ubi.localidad
FROM (
	select usuario.Domicilio_Provincia as provincia,
		   usuario.Domicilio_Localidad as localidad
	from [EXEL_ENTES].Usuario usuario

	union

	select prov.Descripcion as provincia,
		   loc.Descripcion as localidad
	from EXEL_ENTES.Localidad loc
	join EXEL_ENTES.Provincia prov on
		loc.Codigo_Provincia = prov.Codigo_Provincia
) as ubi

-- Cargar Dimensiones de Rangos		OK
INSERT INTO [EXEL_ENTES].BI_Rango_Etario (bi_rango_etario_desc)
VALUES ('< 25'), ('25 - 35'), ('35 - 50'), ('> 50');

INSERT INTO [EXEL_ENTES].BI_RangoHorario (rango)
VALUES ('00:00 - 06:00'), ('06:00 - 12:00'), ('12:00 - 18:00'), ('18:00 - 24:00');

-- Carga de dimensión Tipo Medio de Pago			OK
INSERT INTO [EXEL_ENTES].[BI_TipoMedioPago] (bi_tipoMedioPago_Codigo, descripcion_tipo_medio_pago)
SELECT DISTINCT t.Tipo_Medio_Pago_Codigo, Descripcion_tipo_medio_de_pago
FROM [EXEL_ENTES].TipoMedioDePago AS t

-- Carga de dimensión Rubro y Subrubro (en una tabla BI_Rubro)		OK
INSERT INTO [EXEL_ENTES].[BI_RubroSubrubro] (rubro, subrubro)
SELECT DISTINCT 
    rubro.Codigo_Rubro AS rubro,
    subrubro.Codigo_Subrubro AS subrubro
FROM [EXEL_ENTES].Subrubro AS subrubro
left JOIN [EXEL_ENTES].Rubro AS rubro ON rubro.Codigo_Rubro = subrubro.Codigo_Rubro;

-- Carga de dimension Tipo Envio		OK
INSERT INTO EXEL_ENTES.BI_TipoEnvio (bi_tipo_envio_codigo, bi_tipo_envio_descripcion)
SELECT DISTINCT tipo.Codigo_TipoEnvio, tipo.Descripcion
FROM EXEL_ENTES.TipoEnvio tipo

-- Carga de dimension Marca
INSERT INTO [EXEL_ENTES].[BI_Marca] (bi_marca_codigo,descripcion)
SELECT DISTINCT Marca.Codigo_Marca, Marca.Descripcion
FROM [EXEL_ENTES].Marca;


/* ------- FIN DE CARGA DE LAS DIMENSIONES ------- */

/* ------- INICIO DE CARGA DE LOS HECHOS ------- */

 ------- INICIO DE CARGA DE HECHOS PARA BI_Hecho_Venta ------- 

INSERT INTO [EXEL_ENTES].[BI_Hecho_Venta] (
    codigo_ubicacion,
    codigo_tiempo,
    codigo_rango_etario_cliente,
    codigo_medio_pago,
    codigo_rubrosubrubro,
    codigo_rango_horario_venta,
    cantidad_ventas,
    sumatoria_importe,
    importe_cuotas
)
SELECT 
    ubicacion.bi_ubi_codigo,
    tiempo.bi_tiempo_codigo,
    rango_etario.bi_rango_etario_codigo,
    bi_tipoMedioPago.bi_tipoMedioPago_Codigo,
    rubroSubrubro.bi_rubro_subrubro_codigo,
    rango_horario.rango_horario_id,
    COUNT(DISTINCT venta.Numero_Venta) AS cantidad_ventas,
    SUM(venta.Total) AS sumatoria_importe,
    ISNULL(SUM(pago.Importe), 0) AS importe_cuotas
FROM [EXEL_ENTES].Venta venta
JOIN [EXEL_ENTES].Cliente cliente ON venta.Codigo_Cliente = cliente.Codigo_Usuario
JOIN [EXEL_ENTES].Usuario usuario ON usuario.Codigo_Usuario = cliente.Codigo_Usuario
JOIN [EXEL_ENTES].Pago pago ON pago.Codigo_Numero_Venta = venta.Numero_Venta
JOIN [EXEL_ENTES].MedioDePago medioDePago on medioDePago.Codigo_MedioPago = pago.Codigo_MedioPago
JOIN [EXEL_ENTES].TipoMedioDePago tipoMedioPago on tipoMedioPago.Tipo_Medio_Pago_Codigo = medioDePago.Tipo_Medio_Pago_Codigo
JOIN [EXEL_ENTES].Detalle_Venta detalle_venta ON detalle_venta.Numero_Venta = venta.Numero_Venta
JOIN [EXEL_ENTES].Publicacion publicacion ON publicacion.Codigo_Publicacion = detalle_venta.Codigo_Publicacion
JOIN [EXEL_ENTES].Producto producto ON producto.Codigo_Publicacion = publicacion.Codigo_Publicacion
JOIN [EXEL_ENTES].Subrubro subrubro ON subrubro.Codigo_Subrubro = producto.Codigo_Subrubro
-- LEFT JOIN EXEL_ENTES.Rubro rubro ON rubro.Codigo_Rubro = subrubro.Codigo_Subrubro
LEFT JOIN [EXEL_ENTES].BI_RubroSubrubro rubroSubrubro ON subrubro.Codigo_Subrubro = rubroSubrubro.subrubro
LEFT JOIN [EXEL_ENTES].BI_RangoHorario rango_horario ON rango_horario.rango = EXEL_ENTES.getHorario(venta.Fecha_Venta)
LEFT JOIN [EXEL_ENTES].BI_Ubicacion ubicacion ON ubicacion.bi_ubi_localidad = usuario.Domicilio_Localidad AND ubicacion.bi_ubi_provincia = usuario.Domicilio_Provincia
LEFT JOIN [EXEL_ENTES].BI_Tiempo tiempo ON tiempo.bi_tiempo_anio = YEAR(venta.Fecha_Venta) AND tiempo.bi_tiempo_cuatri = EXEL_ENTES.getCuatrimestre(venta.Fecha_Venta) AND tiempo.bi_tiempo_mes = MONTH(venta.Fecha_Venta)
LEFT JOIN [EXEL_ENTES].BI_Rango_Etario rango_etario ON rango_etario.bi_rango_etario_desc = EXEL_ENTES.getRangoEtario(cliente.Cliente_Fecha_Nac)
LEFT JOIN [EXEL_ENTES].BI_TipoMedioPago bi_tipoMedioPago on bi_tipoMedioPago.bi_tipoMedioPago_Codigo = tipoMedioPago.Tipo_Medio_Pago_Codigo
GROUP BY ubicacion.bi_ubi_codigo, tiempo.bi_tiempo_codigo, rango_etario.bi_rango_etario_codigo, rubroSubrubro.bi_rubro_subrubro_codigo, rango_horario.rango_horario_id, bi_tipoMedioPago.bi_tipoMedioPago_Codigo

GO

-- select * from [EXEL_ENTES].[BI_Hecho_Venta]

/*
WITH Ventas_Cuatrimestre AS (
    SELECT 
        ubicacion.bi_ubi_codigo,
        ubicacion.bi_ubi_localidad,
        ubicacion.bi_ubi_provincia,
        tiempo.bi_tiempo_anio,
        tiempo.bi_tiempo_cuatri,
        rango_etario.bi_rango_etario_desc,
        rubroSubrubro.rubro,
        SUM(hecho.cantidad_ventas) AS cantidad_ventas,
        ROW_NUMBER() OVER(PARTITION BY ubicacion.bi_ubi_localidad, tiempo.bi_tiempo_anio, tiempo.bi_tiempo_cuatri, rango_etario.bi_rango_etario_desc ORDER BY SUM(hecho.cantidad_ventas) DESC) AS rn
    FROM 
        [EXEL_ENTES].[BI_Hecho_Venta] hecho
    JOIN 
        [EXEL_ENTES].[BI_Ubicacion] ubicacion ON hecho.codigo_ubicacion = ubicacion.bi_ubi_codigo
    JOIN 
        [EXEL_ENTES].[BI_Tiempo] tiempo ON hecho.codigo_tiempo = tiempo.bi_tiempo_codigo
    JOIN 
        [EXEL_ENTES].[BI_Rango_Etario] rango_etario ON hecho.codigo_rango_etario_cliente = rango_etario.bi_rango_etario_codigo
    JOIN 
        [EXEL_ENTES].[BI_RubroSubrubro] rubroSubrubro ON hecho.codigo_rubrosubrubro = rubroSubrubro.bi_rubro_subrubro_codigo
	where rubroSubrubro.rubro is not null
    GROUP BY 
        ubicacion.bi_ubi_codigo,
        ubicacion.bi_ubi_localidad,
        ubicacion.bi_ubi_provincia,
        tiempo.bi_tiempo_anio,
        tiempo.bi_tiempo_cuatri,
        rango_etario.bi_rango_etario_desc,
        rubroSubrubro.rubro
)
SELECT 
    bi_ubi_localidad,
    bi_ubi_provincia,
    bi_tiempo_anio,
    bi_tiempo_cuatri,
    bi_rango_etario_desc,
    rubro,
    cantidad_ventas
FROM 
    Ventas_Cuatrimestre
WHERE 
    rn <= 5;



WITH Ventas_Cuatrimestre AS (
    SELECT 
        tiempo.bi_tiempo_anio,
        tiempo.bi_tiempo_cuatri,
        hecho.codigo_rubrosubrubro,
        SUM(hecho.cantidad_ventas) AS total_cantidad_ventas,
        ROW_NUMBER() OVER(PARTITION BY tiempo.bi_tiempo_anio, tiempo.bi_tiempo_cuatri ORDER BY SUM(hecho.cantidad_ventas) DESC) AS rn
    FROM 
        [EXEL_ENTES].[BI_Hecho_Venta] hecho
    JOIN 
        [EXEL_ENTES].[BI_Tiempo] tiempo ON hecho.codigo_tiempo = tiempo.bi_tiempo_codigo
    GROUP BY 
        tiempo.bi_tiempo_anio,
        tiempo.bi_tiempo_cuatri,
        hecho.codigo_rubrosubrubro
)
SELECT 
    bi_tiempo_anio,
    bi_tiempo_cuatri,
    codigo_rubrosubrubro,
    total_cantidad_ventas
FROM 
    Ventas_Cuatrimestre
WHERE 
    rn <= 5;
*/



--select * from EXEL_ENTES.BI_Hecho_Venta

 ------- FIN DE CARGA DE HECHOS PARA BI_Hecho_Venta ------- 


/* Carga de Hecho BI_Hecho_Envio */
INSERT INTO [EXEL_ENTES].[BI_Hecho_Envio] (
    codigo_tiempo,
    codigo_ubicacion_cliente,
    envios_cumplidos,
	cantidad_envios,
    costo_total_envios
)
SELECT distinct
    tiempo.bi_tiempo_codigo,
    ubicacion.bi_ubi_codigo,
    SUM(CASE WHEN DATEDIFF(DAY, e.fecha_entrega, e.fecha_programada) = 0 THEN 1 ELSE NULL END) AS envios_cumplidos,
	COUNT(distinct e.Nro_Envio) AS cantidad_envios,
    SUM(e.Costo_Envio) AS costo_total_envios
FROM [EXEL_ENTES].Envio e
JOIN [EXEL_ENTES].Venta v ON e.Nro_Venta = v.Numero_Venta
JOIN [EXEL_ENTES].Usuario u ON u.Codigo_Usuario = v.Codigo_Cliente  -- saque el join con cliente xq direcramente lo hago con venta
LEFT JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON YEAR(e.fecha_programada) = tiempo.bi_tiempo_anio AND MONTH(e.fecha_programada) = tiempo.bi_tiempo_mes
LEFT JOIN [EXEL_ENTES].BI_Ubicacion ubicacion ON ubicacion.bi_ubi_localidad = u.Domicilio_Localidad AND ubicacion.bi_ubi_provincia = u.Domicilio_Provincia
GROUP BY 
    tiempo.bi_tiempo_codigo,
    ubicacion.bi_ubi_codigo;
GO


-- HECHO_PUBLICACION SE RELACIONA CON VISTA 1 Y 2
INSERT INTO [EXEL_ENTES].[BI_Hecho_Publicacion] (
    codigo_tiempo,
    codigo_rubro_subrubro,
    tiempo_vigencia
)
SELECT
    tiempo.bi_tiempo_codigo,
    rubroSubrubro.bi_rubro_subrubro_codigo,
    AVG(DATEDIFF(DAY, pub.fecha_inicio, pub.fecha_fin)) AS tiempo_vigencia
FROM 
    [EXEL_ENTES].Publicacion pub
JOIN 
    [EXEL_ENTES].Producto producto ON pub.Codigo_Publicacion = producto.Codigo_Publicacion
left JOIN 
    [EXEL_ENTES].[BI_Tiempo] tiempo ON YEAR(pub.fecha_inicio) = tiempo.bi_tiempo_anio AND MONTH(pub.fecha_inicio) = tiempo.bi_tiempo_mes
left JOIN 
    [EXEL_ENTES].[BI_RubroSubrubro] rubroSubrubro on producto.Codigo_Subrubro = rubroSubrubro.subrubro
GROUP BY 
    tiempo.bi_tiempo_codigo,
    rubroSubrubro.bi_rubro_subrubro_codigo,
	bi_tiempo_cuatri;
GO

-- HECHO STOCK RELACIONADO CON VISTA 2
INSERT INTO [EXEL_ENTES].[BI_Hecho_Stock] (
    codigo_tiempo,
    codigo_marca,
    stock_inicial_promedio
)
SELECT
    tiempo.bi_tiempo_codigo,
    marca.bi_marca_codigo,
    round(AVG(pub.Stock),3) AS stock_inicial_promedio -- despues chequear si dejamos con decimales o enteros
FROM 
    [EXEL_ENTES].Publicacion pub
join 
	EXEL_ENTES.Producto prod on prod.Codigo_Publicacion = pub.Codigo_Publicacion
JOIN 
    [EXEL_ENTES].Marca m ON prod.Codigo_Marca = m.Codigo_Marca
left JOIN 
    [EXEL_ENTES].[BI_Tiempo] tiempo ON YEAR(pub.fecha_inicio) = tiempo.bi_tiempo_anio AND MONTH(pub.fecha_inicio) = tiempo.bi_tiempo_mes
left JOIN 
    [EXEL_ENTES].[BI_Marca] marca ON m.Descripcion = marca.descripcion
GROUP BY 
    tiempo.bi_tiempo_codigo,
    marca.bi_marca_codigo;
GO


-- HECHO FACT PARA VISTA 9
INSERT INTO [EXEL_ENTES].[BI_Hecho_Facturacion] (
    codigo_tiempo,
	codigo_ubicacion,
    total_facturado
)
SELECT
    tiempo.bi_tiempo_codigo,
	ubicacion.bi_ubi_codigo,
    SUM(factura.Total) AS total_facturado
FROM [EXEL_ENTES].Factura factura
join EXEL_ENTES.Usuario usuario on usuario.Codigo_Usuario = factura.Codigo_Vendedor
left JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON YEAR(factura.Fecha_Factura) = tiempo.bi_tiempo_anio AND MONTH(factura.Fecha_Factura) = tiempo.bi_tiempo_mes
left join EXEL_ENTES.BI_Ubicacion ubicacion on usuario.Domicilio_Provincia = ubicacion.bi_ubi_provincia
GROUP BY 
    tiempo.bi_tiempo_codigo,
	ubicacion.bi_ubi_codigo
GO


/* ------- FIN DE CARGA DE LOS HECHOS ------- */


IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_tiempo_promedio_publicaciones')
DROP VIEW [EXEL_ENTES].BI_tiempo_promedio_publicaciones
IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_promedio_stock_inicial')
DROP VIEW [EXEL_ENTES].BI_promedio_stock_inicial
IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_venta_promedio_mensual')
DROP VIEW [EXEL_ENTES].BI_venta_promedio_mensual
IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_rendimiento_rubros')
DROP VIEW [EXEL_ENTES].BI_rendimiento_rubros
IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_volumen_ventas')
DROP VIEW [EXEL_ENTES].BI_volumen_ventas 
IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_pago_en_cuotas')
DROP VIEW [EXEL_ENTES].BI_pago_en_cuotas
IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_porcentaje_cumplimiento_envios')
DROP VIEW [EXEL_ENTES].BI_porcentaje_cumplimiento_envios
IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_localidades_mayor_costo_envio')
DROP VIEW [EXEL_ENTES].BI_localidades_mayor_costo_envio
IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_porcentaje_facturacion_mensual')
DROP VIEW [EXEL_ENTES].BI_porcentaje_facturacion_mensual
IF EXISTS (SELECT name FROM sys.views WHERE name = 'BI_facturacion_por_provincia')
DROP VIEW [EXEL_ENTES].BI_facturacion_por_provincia
GO -- puse el go xq sino se quejaba (no se si esta bien) SOFI

/* ------- CREACIÓN DE VISTAS ------- */

-- 1. Promedio de tiempo de publicaciones
CREATE VIEW [EXEL_ENTES].BI_tiempo_promedio_publicaciones AS
SELECT
    tiempo.bi_tiempo_anio AS anio,
    tiempo.bi_tiempo_cuatri AS cuatrimestre,
    rubroSubrubro.subrubro,
    publicacion.tiempo_vigencia

FROM [EXEL_ENTES].[BI_Hecho_Publicacion] publicacion
	LEFT JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON publicacion.codigo_tiempo = tiempo.bi_tiempo_codigo
	LEFT JOIN [EXEL_ENTES].[BI_RubroSubrubro] rubroSubrubro ON publicacion.codigo_rubro_subrubro = rubroSubrubro.bi_rubro_subrubro_codigo
GROUP BY 
    tiempo.bi_tiempo_anio,
    tiempo.bi_tiempo_cuatri,
    rubroSubrubro.subrubro,
	publicacion.tiempo_vigencia;
GO
-- select * from [EXEL_ENTES].BI_tiempo_promedio_publicaciones


-- 2. Promedio de Stock Inicial
CREATE VIEW [EXEL_ENTES].BI_promedio_stock_inicial AS
SELECT
    tiempo.bi_tiempo_anio AS anio,
    marca.descripcion AS nombre_marca,
	stock.stock_inicial_promedio 
FROM [EXEL_ENTES].[BI_Hecho_Stock] stock
	LEFT JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON stock.codigo_tiempo = tiempo.bi_tiempo_codigo
	LEFT JOIN [EXEL_ENTES].[BI_Marca] marca ON stock.codigo_marca = marca.bi_marca_codigo
GROUP BY 
    tiempo.bi_tiempo_anio,
    marca.descripcion,
	stock.stock_inicial_promedio;
GO
-- select * from [EXEL_ENTES].BI_promedio_stock_inicial


-- 3. Venta promedio mensual -- CAMBIADA POR HECHO VENTA
CREATE VIEW [EXEL_ENTES].BI_venta_promedio_mensual AS
SELECT
	bi_tiempo.bi_tiempo_anio as [Anio],
	bi_tiempo.bi_tiempo_mes as [Mes],
	bi_ubi.bi_ubi_provincia as [Provincia],
	isnull(isnull(sum(hv.sumatoria_importe),0)/hv.cantidad_ventas,0) as [Importe]
FROM EXEL_ENTES.BI_Hecho_Venta hv
	LEFT JOIN EXEL_ENTES.BI_Ubicacion bi_ubi on hv.codigo_ubicacion = bi_ubi_codigo
	LEFT JOIN EXEL_ENTES.BI_Tiempo bi_tiempo on hv.codigo_tiempo = bi_tiempo.bi_tiempo_codigo
GROUP BY bi_tiempo.bi_tiempo_anio, bi_tiempo.bi_tiempo_mes ,bi_ubi.bi_ubi_provincia, hv.cantidad_ventas
GO
-- select * from [EXEL_ENTES].BI_venta_promedio_mensual


-- 4. Rendimiento de rubros
CREATE VIEW [EXEL_ENTES].BI_rendimiento_rubros AS
SELECT TOP 5
    tiempo.bi_tiempo_anio AS anio,
    tiempo.bi_tiempo_cuatri AS cuatrimestre,
    ubicacion.bi_ubi_localidad AS localidad,
    rango_etario.bi_rango_etario_desc AS rango_etario,
    rubroSubrubro.rubro AS rubro_subrubro,
    SUM(venta.sumatoria_importe) AS total_ventas
FROM [EXEL_ENTES].[BI_Hecho_Venta] venta
	LEFT JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON venta.codigo_tiempo = tiempo.bi_tiempo_codigo
	LEFT JOIN [EXEL_ENTES].[BI_Ubicacion] ubicacion ON venta.codigo_ubicacion = ubicacion.bi_ubi_codigo
	LEFT JOIN [EXEL_ENTES].[BI_Rango_Etario] rango_etario ON venta.codigo_rango_etario_cliente = rango_etario.bi_rango_etario_codigo
	LEFT JOIN [EXEL_ENTES].[BI_RubroSubrubro] rubroSubrubro ON venta.codigo_rubrosubrubro = rubroSubrubro.bi_rubro_subrubro_codigo
GROUP BY 
    tiempo.bi_tiempo_anio,
    tiempo.bi_tiempo_cuatri,
    ubicacion.bi_ubi_localidad,
    rango_etario.bi_rango_etario_desc,
    rubroSubrubro.rubro
GO
-- select * from [EXEL_ENTES].BI_rendimiento_rubros

-- 5. Volumen de ventas
CREATE VIEW [EXEL_ENTES].BI_volumen_ventas AS
SELECT
    rango_horario.rango AS rango_horario,
    tiempo.bi_tiempo_anio AS anio,
    tiempo.bi_tiempo_mes AS mes,
    SUM(hv.cantidad_ventas) AS volumen_ventas
FROM [EXEL_ENTES].[BI_Hecho_Venta] hv
	LEFT JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON hv.codigo_tiempo = tiempo.bi_tiempo_codigo
	LEFT JOIN [EXEL_ENTES].[BI_RangoHorario] rango_horario ON hv.codigo_rango_horario_venta = rango_horario.rango_horario_id
GROUP BY 
    rango_horario.rango, 
    tiempo.bi_tiempo_anio, 
    tiempo.bi_tiempo_mes;
GO
-- select * from [EXEL_ENTES].BI_volumen_ventas

-- 6. Pago en cuotas
CREATE VIEW [EXEL_ENTES].BI_pago_en_cuotas AS
SELECT TOP 3
    ubicacion.bi_ubi_localidad AS localidad,
    tiempo.bi_tiempo_anio AS anio,
    tiempo.bi_tiempo_mes AS mes,
    medio_pago.descripcion_tipo_medio_pago AS medio_pago,
	MAX(hv.sumatoria_importe) AS importe_total_cuotas
    --SUM(hv.importe_cuotas) AS importe_total_cuotas
FROM [EXEL_ENTES].[BI_Hecho_Venta] hv
	LEFT JOIN [EXEL_ENTES].[BI_Ubicacion] ubicacion ON hv.codigo_ubicacion = ubicacion.bi_ubi_codigo
	LEFT JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON hv.codigo_tiempo = tiempo.bi_tiempo_codigo
	LEFT JOIN [EXEL_ENTES].[BI_TipoMedioPago] medio_pago ON hv.codigo_medio_pago = medio_pago.bi_tipoMedioPago_Codigo
GROUP BY 
    ubicacion.bi_ubi_localidad, 
    tiempo.bi_tiempo_anio, 
    tiempo.bi_tiempo_mes, 
    medio_pago.descripcion_tipo_medio_pago
ORDER BY 
    importe_total_cuotas DESC;
GO
-- select * from [EXEL_ENTES].BI_pago_en_cuotas

	
-- 7. Porcentaje de cumplimiento de envíos en tiempos programados
CREATE VIEW [EXEL_ENTES].BI_porcentaje_cumplimiento_envios AS
SELECT
    tiempo.bi_tiempo_anio AS anio,
    tiempo.bi_tiempo_mes AS mes,
    ubicacion.bi_ubi_provincia AS provincia,
   (SUM(envio.envios_cumplidos) * 100.0 / (SUM(envio.cantidad_envios))) AS porcentaje_cumplimiento
FROM [EXEL_ENTES].[BI_Hecho_Envio] envio
	LEFT JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON envio.codigo_tiempo = tiempo.bi_tiempo_codigo
	LEFT JOIN [EXEL_ENTES].[BI_Ubicacion] ubicacion ON envio.codigo_ubicacion_cliente = ubicacion.bi_ubi_codigo
GROUP BY 
    tiempo.bi_tiempo_anio,
    tiempo.bi_tiempo_mes,
    ubicacion.bi_ubi_provincia;
GO
-- select * from [EXEL_ENTES].BI_porcentaje_cumplimiento_envios


-- 8. Localidades que pagan mayor costo de envío
CREATE VIEW [EXEL_ENTES].BI_localidades_mayor_costo_envio AS
SELECT TOP 5
    ubicacion.bi_ubi_localidad AS localidad,
    MAX(envio.costo_total_envios) AS costo_total_envios
FROM [EXEL_ENTES].[BI_Hecho_Envio] envio
	LEFT JOIN [EXEL_ENTES].[BI_Ubicacion] ubicacion ON envio.codigo_ubicacion_cliente = ubicacion.bi_ubi_codigo
GROUP BY ubicacion.bi_ubi_localidad
ORDER BY MAX(envio.costo_total_envios) DESC;
GO

-- select * from [EXEL_ENTES].BI_localidades_mayor_costo_envio


-- 9. Porcentaje de facturación por concepto
CREATE VIEW [EXEL_ENTES].BI_porcentaje_facturacion_mensual AS
SELECT
    tiempo.bi_tiempo_anio AS anio,
    tiempo.bi_tiempo_mes AS mes,
    (SUM(facturacion.total_facturado) * 100.0) / (SELECT SUM(total_facturado) FROM [EXEL_ENTES].[BI_Hecho_Facturacion]) AS porcentaje_facturacion
FROM [EXEL_ENTES].[BI_Hecho_Facturacion] facturacion
	LEFT JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON facturacion.codigo_tiempo = tiempo.bi_tiempo_codigo
GROUP BY 
    tiempo.bi_tiempo_anio,
    tiempo.bi_tiempo_mes
GO
-- select * from [EXEL_ENTES].BI_porcentaje_facturacion_mensual


-- 10. Facturación por provincia
CREATE VIEW [EXEL_ENTES].BI_facturacion_por_provincia AS
SELECT
    tiempo.bi_tiempo_anio AS anio,
    tiempo.bi_tiempo_cuatri AS cuatrimestre,
    ubicacion.bi_ubi_provincia AS provincia,
    SUM(venta.sumatoria_importe) AS total_facturado
FROM [EXEL_ENTES].[BI_Hecho_Venta] venta
	LEFT JOIN [EXEL_ENTES].[BI_Tiempo] tiempo ON venta.codigo_tiempo = tiempo.bi_tiempo_codigo
	LEFT JOIN [EXEL_ENTES].[BI_Ubicacion] ubicacion ON venta.codigo_ubicacion = ubicacion.bi_ubi_codigo
GROUP BY 
    tiempo.bi_tiempo_anio,
    tiempo.bi_tiempo_cuatri,
    ubicacion.bi_ubi_provincia
ORDER BY
	tiempo.bi_tiempo_anio,
    tiempo.bi_tiempo_cuatri,
    ubicacion.bi_ubi_provincia
GO
-- select * from [EXEL_ENTES].BI_facturacion_por_provincia



/* ------- FIN DE CREACION DE VISTAS ------- */



-- hay q dropear las vistas
