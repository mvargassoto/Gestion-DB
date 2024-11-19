USE GD1C2024
GO

/* ------- INICIO DE CREACION DE FUNCIONES AUXILIARES ------- */
CREATE FUNCTION [9999_ROWS_AFFECTED].getCuatrimestre (@fecha DATE)
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

CREATE FUNCTION [9999_ROWS_AFFECTED].getRangoEtario (@fecha_nacimiento DATE)
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

CREATE FUNCTION [9999_ROWS_AFFECTED].getTurno (@fecha DATETIME)
RETURNS NVARCHAR(14)
AS
BEGIN
	DECLARE @hora INT
	DECLARE @turno NVARCHAR(14) 

	SET @hora = CAST(REPLACE(CONVERT(NVARCHAR(255), @fecha, 108), ':', '') AS INT)

	SET @turno =
		CASE 
			WHEN @hora < 120000 THEN '08:00 - 12:00'
			WHEN @hora >= 120000 AND @hora < 160000 THEN '12:00 - 16:00'
			WHEN @hora >= 160000 THEN '16:00 - 20:00'
		END

	RETURN @turno
END
GO

/* ------- FIN DE FUNCIONES AUXILIARES ------- */

/* ------- INICIO DE CREACION DE LAS DIMENSIONES ------- */
CREATE TABLE [9999_ROWS_AFFECTED].BI_Tiempo (
	bi_tiempo_codigo INT IDENTITY(1,1) NOT NULL,
	bi_tiempo_anio DECIMAL(18,0),
	bi_tiempo_cuatri SMALLINT CHECK (bi_tiempo_cuatri BETWEEN 1 AND 3),
	bi_tiempo_mes DECIMAL(18,0) CHECK (bi_tiempo_mes BETWEEN 1 AND 12),
	CONSTRAINT [PK_BI_Tiempo] PRIMARY KEY (bi_tiempo_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Ubicacion(
	bi_ubi_codigo INT IDENTITY(1,1) NOT NULL,
	bi_ubi_provincia NVARCHAR(255),
	bi_ubi_localidad NVARCHAR(255),
	CONSTRAINT [PK_BI_Ubicacion] PRIMARY KEY (bi_ubi_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Sucursal(
	bi_sucu_codigo INT NOT NULL,
    bi_sucu_nombre NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_BI_Sucursal] PRIMARY KEY (bi_sucu_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Rango_Etario(
	bi_rango_etario_codigo INT IDENTITY(1,1) NOT NULL,
	bi_rango_etario_desc NVARCHAR(255),
	CONSTRAINT [PK_BI_Rango_Etario] PRIMARY KEY (bi_rango_etario_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Turno(
	bi_turno_codigo INT IDENTITY(1,1) NOT NULL,
	bi_turno_desc NVARCHAR(255),
	CONSTRAINT [PK_BI_Turno] PRIMARY KEY (bi_turno_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Medio_Pago(
	bi_mp_codigo INT NOT NULL,
	bi_mp_desc NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_BI_Medio_Pago] PRIMARY KEY (bi_mp_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Categoria_Subcategoria(
	bi_cate_subc_codigo INT IDENTITY(1,1) NOT NULL,
	bi_cate_subc_nombre_cate NVARCHAR(255) NOT NULL,
	bi_cate_subc_nombre_subc NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_BI_Categoria_Subcategoria] PRIMARY KEY (bi_cate_subc_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Tipo_Caja(
	bi_tipo_caja_codigo INT IDENTITY(1,1) NOT NULL,
	bi_tipo_caja_desc NVARCHAR(255) NOT NULL,
	CONSTRAINT [PK_BI_Tipo_Caja] PRIMARY KEY (bi_tipo_caja_codigo)
);
/* ------- FIN DE CREACION DE LAS DIMENSIONES ------- */

/* ------- INICIO DE CREACION DE HECHOS ------- */
CREATE TABLE [9999_ROWS_AFFECTED].BI_Hecho_Venta(
	codigo_ubicacion INT NOT NULL,
	codigo_tiempo INT NOT NULL,
	codigo_rango_etario_empleado INT NOT NULL,
	codigo_rango_etario_cliente INT NOT NULL,
	codigo_tipo_caja INT NOT NULL,
	codigo_turno INT NOT NULL,
	codigo_mp INT NOT NULL,
	codigo_sucursal INT NOT NULL,
	sumatoria_importe DECIMAL(18,2) NOT NULL,
	cantidad_ventas_totales DECIMAL(18,0) NOT NULL,
	sumatoria_importe_en_cuotas DECIMAL(18,2) NULL,
	sumatoria_importe_en_cuotas_cliente DECIMAL(18,2) NULL,
	cantidad_ventas_totales_cuotas_cliente DECIMAL(18,0) NULL,
	pago_total_bruto DECIMAL(18,2) NOT NULL,
	pago_total_desc_aplicado DECIMAL(18,2) NULL,
	CONSTRAINT [PK_BI_Hecho_Venta] PRIMARY KEY (codigo_ubicacion, codigo_tiempo, codigo_rango_etario_empleado, codigo_rango_etario_cliente, codigo_tipo_caja, codigo_turno, codigo_mp, codigo_sucursal),
	CONSTRAINT [FK_BI_Hecho_Venta_BI_Ubicacion] FOREIGN KEY (codigo_ubicacion) REFERENCES [9999_ROWS_AFFECTED].BI_Ubicacion(bi_ubi_codigo),
	CONSTRAINT [FK_BI_Hecho_Venta_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [9999_ROWS_AFFECTED].BI_Tiempo(bi_tiempo_codigo),
	CONSTRAINT [FK_BI_Hecho_Venta_BI_Rango_Etario_Empleado] FOREIGN KEY (codigo_rango_etario_empleado) REFERENCES [9999_ROWS_AFFECTED].BI_Rango_Etario(bi_rango_etario_codigo),
	CONSTRAINT [FK_BI_Hecho_Venta_BI_Rango_Etario_Cliente] FOREIGN KEY (codigo_rango_etario_cliente) REFERENCES [9999_ROWS_AFFECTED].BI_Rango_Etario(bi_rango_etario_codigo),
	CONSTRAINT [FK_BI_Hecho_Venta_BI_Tipo_Caja] FOREIGN KEY (codigo_tipo_caja) REFERENCES [9999_ROWS_AFFECTED].BI_Tipo_Caja(bi_tipo_caja_codigo),
	CONSTRAINT [FK_BI_Hecho_Venta_BI_Turno] FOREIGN KEY (codigo_turno) REFERENCES [9999_ROWS_AFFECTED].BI_Turno(bi_turno_codigo),
	CONSTRAINT [FK_BI_Hecho_Venta_BI_Medio_Pago] FOREIGN KEY (codigo_mp) REFERENCES [9999_ROWS_AFFECTED].BI_Medio_Pago(bi_mp_codigo),
	CONSTRAINT [FK_BI_Hecho_Venta_BI_Sucursal] FOREIGN KEY (codigo_sucursal) REFERENCES [9999_ROWS_AFFECTED].BI_Sucursal(bi_sucu_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Hecho_Compra(
	codigo_turno INT NOT NULL,
	codigo_tiempo INT NOT NULL,
	total_articulos_vendidos DECIMAL(18,0) NOT NULL,
	cantidad_tickets DECIMAL(18,0) NOT NULL,
	descuento_aplicado DECIMAL(18,2) NOT NULL,
	monto_total_ticket DECIMAL(18,2) NOT NULL,
	CONSTRAINT [PK_BI_Hecho_Compra] PRIMARY KEY (codigo_turno, codigo_tiempo),
	CONSTRAINT [FK_BI_Hecho_Compra_BI_Turno] FOREIGN KEY (codigo_turno) REFERENCES [9999_ROWS_AFFECTED].BI_Turno(bi_turno_codigo),
	CONSTRAINT [FK_BI_Hecho_Compra_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [9999_ROWS_AFFECTED].BI_Tiempo(bi_tiempo_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Hecho_Envio(
	codigo_sucursal INT NOT NULL,
	codigo_tiempo INT NOT NULL,
	codigo_rango_etario INT NOT NULL,
	codigo_ubicacion INT NOT NULL,
	cantidad_envios_cumplidos DECIMAL(18,0) NOT NULL,
	cantidad_envios DECIMAL(18,0) NOT NULL,
	costo_total DECIMAL(18,2) NOT NULL,
	CONSTRAINT [PK_BI_Hecho_Envio] PRIMARY KEY (codigo_sucursal, codigo_tiempo, codigo_rango_etario, codigo_ubicacion),
	CONSTRAINT [FK_BI_Hecho_Envio_BI_Sucursal] FOREIGN KEY (codigo_sucursal) REFERENCES [9999_ROWS_AFFECTED].BI_Sucursal(bi_sucu_codigo),
	CONSTRAINT [FK_BI_Hecho_Envio_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [9999_ROWS_AFFECTED].BI_Tiempo(bi_tiempo_codigo),
	CONSTRAINT [FK_BI_Hecho_Envio_BI_Rango_Etario] FOREIGN KEY (codigo_rango_etario) REFERENCES [9999_ROWS_AFFECTED].BI_Rango_Etario(bi_rango_etario_codigo),
	CONSTRAINT [FK_BI_Hecho_Envio_BI_Ubicacion] FOREIGN KEY (codigo_ubicacion) REFERENCES [9999_ROWS_AFFECTED].BI_Ubicacion(bi_ubi_codigo)
);

CREATE TABLE [9999_ROWS_AFFECTED].BI_Hecho_Promocion(
	codigo_tiempo INT NOT NULL,
	codigo_categoria_subcategoria INT NOT NULL,
	descuentos_aplicados DECIMAL(18,2),
	CONSTRAINT [PK_BI_Hecho_Promocion] PRIMARY KEY (codigo_tiempo, codigo_categoria_subcategoria),
	CONSTRAINT [FK_BI_Hecho_Promocion_BI_Tiempo] FOREIGN KEY (codigo_tiempo) REFERENCES [9999_ROWS_AFFECTED].BI_Tiempo(bi_tiempo_codigo),
	CONSTRAINT [FK_BI_Hecho_Promocion_BI_Categoria_Subcategoria] FOREIGN KEY (codigo_categoria_subcategoria) REFERENCES [9999_ROWS_AFFECTED].BI_Categoria_Subcategoria(bi_cate_subc_codigo)
);

/* ------- FIN DE CREACION DE HECHOS ------- */

/* ------- INICIO DE CARGA DE LAS DIMENSIONES ------- */
-- IMPORT BI_Tiempo

INSERT INTO [9999_ROWS_AFFECTED].BI_Tiempo (bi_tiempo_anio, bi_tiempo_cuatri, bi_tiempo_mes)
SELECT DISTINCT YEAR(tick_fecha_hora),
				[9999_ROWS_AFFECTED].getCuatrimestre(tick_fecha_hora),
				MONTH(tick_fecha_hora)
FROM [9999_ROWS_AFFECTED].Ticket
UNION
SELECT DISTINCT YEAR(envi_fecha_programada),
				[9999_ROWS_AFFECTED].getCuatrimestre(envi_fecha_programada),
				MONTH(envi_fecha_programada)
FROM [9999_ROWS_AFFECTED].Envio
UNION
SELECT DISTINCT YEAR(envi_fecha_hora_entrega),
				[9999_ROWS_AFFECTED].getCuatrimestre(envi_fecha_hora_entrega),
				MONTH(envi_fecha_hora_entrega)
FROM [9999_ROWS_AFFECTED].Envio
UNION
SELECT DISTINCT YEAR(pago_fecha_hora),
				[9999_ROWS_AFFECTED].getCuatrimestre(pago_fecha_hora),
				MONTH(pago_fecha_hora)
FROM [9999_ROWS_AFFECTED].Pago
-- FIN IMPORT BI_Tiempo

-- IMPORT BI_Ubicacion
INSERT INTO [9999_ROWS_AFFECTED].BI_Ubicacion (bi_ubi_provincia, bi_ubi_localidad)
SELECT DISTINCT prov_nombre, loca_nombre
FROM [9999_ROWS_AFFECTED].Localidad
JOIN [9999_ROWS_AFFECTED].Provincia ON loca_provincia_id = prov_codigo
-- FIN IMPORT BI_Ubicacion

-- IMPORT BI_Sucursal
INSERT INTO [9999_ROWS_AFFECTED].BI_Sucursal (bi_sucu_codigo, bi_sucu_nombre)
SELECT DISTINCT sucu_codigo, sucu_nombre
FROM [9999_ROWS_AFFECTED].Sucursal
-- FIN IMPORT BI_Sucursal

-- IMPORT BI_Rango_Etario
INSERT INTO [9999_ROWS_AFFECTED].BI_Rango_Etario (bi_rango_etario_desc)
VALUES ('< 25'), ('25 - 35'), ('35 - 50'), ('> 50'), ('Indefinido')
-- FIN IMPORT BI_Rango_Etario

-- IMPORT BI_Turno
INSERT INTO [9999_ROWS_AFFECTED].BI_Turno (bi_turno_desc)
VALUES ('08:00 - 12:00'), ('12:00 - 16:00'), ('16:00 - 20:00')
-- FIN IMPORT BI_Turno

-- IMPORT BI_Medio_Pago
INSERT INTO [9999_ROWS_AFFECTED].BI_Medio_Pago (bi_mp_codigo, bi_mp_desc)
SELECT DISTINCT medi_pago_codigo, medi_pago_descripcion
FROM [9999_ROWS_AFFECTED].MedioPago
-- FIN IMPORT BI_Medio_Pago

-- IMPORT BI_Categoria
INSERT INTO [9999_ROWS_AFFECTED].BI_Categoria_Subcategoria (bi_cate_subc_nombre_cate, bi_cate_subc_nombre_subc)
SELECT DISTINCT cate_nombre, subc_nombre 
FROM [9999_ROWS_AFFECTED].Categoria
JOIN [9999_ROWS_AFFECTED].Subcategoria ON cate_subcategoria = subc_codigo
-- FIN IMPORT BI_Categoria

-- IMPORT BI_Caja
INSERT INTO [9999_ROWS_AFFECTED].BI_Tipo_Caja (bi_tipo_caja_desc)
SELECT DISTINCT tipo_caja_tipo
FROM [9999_ROWS_AFFECTED].TipoCaja
-- FIN IMPORT BI_Caja
/* ------- FIN DE CARGA DE LAS DIMENSIONES ------- */

/* ------- INICIO DE CARGA DE LOS HECHOS ------- */
-- IMPORT BI_Hecho_Venta
INSERT INTO [9999_ROWS_AFFECTED].BI_Hecho_Venta (codigo_ubicacion, codigo_tiempo, codigo_rango_etario_empleado,
codigo_rango_etario_cliente, codigo_tipo_caja, codigo_turno, codigo_mp, codigo_sucursal, sumatoria_importe,
cantidad_ventas_totales, sumatoria_importe_en_cuotas, sumatoria_importe_en_cuotas_cliente,
cantidad_ventas_totales_cuotas_cliente, pago_total_bruto, pago_total_desc_aplicado)
	SELECT DISTINCT bi_ubi_codigo, b1.bi_tiempo_codigo, re.bi_rango_etario_codigo, rc.bi_rango_etario_codigo,
	bi_tipo_caja_codigo, bi_turno_codigo, bi_mp_codigo, s1.bi_sucu_codigo,
	SUM(pago_importe_bruto - pago_descuento_total_aplicado), COUNT(*),

	ISNULL((SELECT SUM(pago_importe_bruto - pago_descuento_total_aplicado) FROM [9999_ROWS_AFFECTED].Pago
	JOIN [9999_ROWS_AFFECTED].PagoDetalleTarjeta ON pago_codigo = pago_det_tarj_codigo_pago
	LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo ON bi_tiempo_anio = YEAR(pago_fecha_hora) AND bi_tiempo_mes = MONTH(pago_fecha_hora)
	WHERE pago_medio_pago = bi_mp_codigo AND bi_tiempo_codigo = b1.bi_tiempo_codigo
	AND pago_cod_sucursal_ticket = s1.bi_sucu_codigo),0),

	ISNULL((SELECT SUM(pago_importe_bruto - pago_descuento_total_aplicado) FROM [9999_ROWS_AFFECTED].Pago
	JOIN [9999_ROWS_AFFECTED].PagoDetalleTarjeta ON pago_codigo = pago_det_tarj_codigo_pago
	LEFT JOIN [9999_ROWS_AFFECTED].Cliente ON clie_codigo = pago_cliente
	LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo ON bi_tiempo_anio = YEAR(pago_fecha_hora) AND bi_tiempo_mes = MONTH(pago_fecha_hora)
	LEFT JOIN [9999_ROWS_AFFECTED].BI_Rango_Etario ON bi_rango_etario_desc = [9999_ROWS_AFFECTED].getRangoEtario(clie_nacimiento)
	WHERE pago_medio_pago = bi_mp_codigo AND bi_tiempo_codigo = b1.bi_tiempo_codigo	AND bi_rango_etario_codigo = rc.bi_rango_etario_codigo),0),
	
	(SELECT COUNT(*) FROM [9999_ROWS_AFFECTED].Pago
	JOIN [9999_ROWS_AFFECTED].PagoDetalleTarjeta ON pago_codigo = pago_det_tarj_codigo_pago
	LEFT JOIN [9999_ROWS_AFFECTED].Cliente ON clie_codigo = pago_cliente
	LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo ON bi_tiempo_anio = YEAR(pago_fecha_hora) AND bi_tiempo_mes = MONTH(pago_fecha_hora)
	LEFT JOIN [9999_ROWS_AFFECTED].BI_Rango_Etario ON bi_rango_etario_desc = [9999_ROWS_AFFECTED].getRangoEtario(clie_nacimiento)
	WHERE pago_medio_pago = bi_mp_codigo AND bi_tiempo_codigo = b1.bi_tiempo_codigo AND bi_rango_etario_codigo = rc.bi_rango_etario_codigo),
	
	SUM(pago_importe_bruto), SUM(pago_descuento_total_aplicado)

FROM [9999_ROWS_AFFECTED].Pago
JOIN [9999_ROWS_AFFECTED].Ticket ON pago_cod_sucursal_ticket = tick_cod_sucursal
								AND pago_nro_caja_ticket = tick_nro_caja
								AND pago_codigo_ticket = tick_codigo
								AND pago_comprobante_ticket = tick_comprobante
JOIN [9999_ROWS_AFFECTED].Caja ON caja_numero = tick_nro_caja AND caja_cod_sucursal = tick_cod_sucursal
JOIN [9999_ROWS_AFFECTED].TipoCaja ON caja_tipo = tipo_caja_codigo
JOIN [9999_ROWS_AFFECTED].Empleado ON tick_legajo_empleado = empl_legajo
JOIN [9999_ROWS_AFFECTED].Sucursal ON pago_cod_sucursal_ticket = sucu_codigo
JOIN [9999_ROWS_AFFECTED].Direccion ON sucu_direccion = dire_codigo
JOIN [9999_ROWS_AFFECTED].Localidad ON dire_localidad_id = loca_codigo
JOIN [9999_ROWS_AFFECTED].Provincia ON loca_provincia_id = prov_codigo
LEFT JOIN [9999_ROWS_AFFECTED].Cliente ON clie_codigo = pago_cliente
LEFT JOIN [9999_ROWS_AFFECTED].BI_Ubicacion ON bi_ubi_provincia = prov_nombre AND bi_ubi_localidad = loca_nombre
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo b1 ON b1.bi_tiempo_anio = YEAR(pago_fecha_hora) AND b1.bi_tiempo_mes = MONTH(pago_fecha_hora)
LEFT JOIN [9999_ROWS_AFFECTED].BI_Rango_Etario re ON re.bi_rango_etario_desc = [9999_ROWS_AFFECTED].getRangoEtario(empl_fecha_nacimiento)
LEFT JOIN [9999_ROWS_AFFECTED].BI_Rango_Etario rc ON rc.bi_rango_etario_desc = [9999_ROWS_AFFECTED].getRangoEtario(clie_nacimiento)
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tipo_Caja ON bi_tipo_caja_desc = tipo_caja_tipo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Turno ON bi_turno_desc = [9999_ROWS_AFFECTED].getTurno(tick_fecha_hora)
LEFT JOIN [9999_ROWS_AFFECTED].BI_Medio_Pago ON bi_mp_codigo = pago_medio_pago
LEFT JOIN [9999_ROWS_AFFECTED].BI_Sucursal s1 ON s1.bi_sucu_codigo = sucu_codigo
GROUP BY bi_ubi_codigo, b1.bi_tiempo_codigo, re.bi_rango_etario_codigo, rc.bi_rango_etario_codigo, bi_tipo_caja_codigo, bi_turno_codigo, bi_mp_codigo, s1.bi_sucu_codigo
-- FIN IMPORT BI_Hecho_Venta

-- IMPORT BI_Hecho_Compra
INSERT INTO [9999_ROWS_AFFECTED].BI_Hecho_Compra (codigo_turno, codigo_tiempo, total_articulos_vendidos, cantidad_tickets,
descuento_aplicado, monto_total_ticket)
	SELECT DISTINCT bi_turno_codigo, bi_tiempo_codigo, SUM(item_cantidad), (SELECT COUNT(*) FROM [9999_ROWS_AFFECTED].Ticket),
	SUM(tick_descuento_total_aplicado), SUM(tick_subtotal)
FROM [9999_ROWS_AFFECTED].Ticket
JOIN [9999_ROWS_AFFECTED].ItemTicket ON tick_codigo = item_ticket_codigo
								AND tick_comprobante = item_ticket_comprobante
								AND tick_cod_sucursal = item_ticket_cod_sucursal
								AND tick_nro_caja = item_ticket_nro_caja
LEFT JOIN [9999_ROWS_AFFECTED].BI_Turno ON bi_turno_desc = [9999_ROWS_AFFECTED].getTurno(tick_fecha_hora)
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo ON bi_tiempo_anio = YEAR(tick_fecha_hora) AND bi_tiempo_mes = MONTH(tick_fecha_hora)
GROUP BY bi_turno_codigo, bi_tiempo_codigo
-- FIN IMPORT BI_Hecho_Compra

-- IMPORT BI_Hecho_Envio
INSERT INTO [9999_ROWS_AFFECTED].BI_Hecho_Envio(codigo_sucursal, codigo_tiempo, codigo_rango_etario, codigo_ubicacion,
cantidad_envios_cumplidos, cantidad_envios, costo_total)
	SELECT DISTINCT bi_sucu_codigo, bi_tiempo_codigo, bi_rango_etario_codigo, bi_ubi_codigo,
	SUM (CASE
	WHEN DATEDIFF(DAY, envi_fecha_hora_entrega, envi_fecha_programada) = 0 THEN 1
	ELSE 0
	END),
	COUNT(*),
	SUM(envi_costo)
FROM [9999_ROWS_AFFECTED].Envio
JOIN [9999_ROWS_AFFECTED].Cliente ON clie_codigo = envi_cliente
JOIN [9999_ROWS_AFFECTED].Direccion ON clie_direccion = dire_codigo
JOIN [9999_ROWS_AFFECTED].Localidad ON dire_localidad_id = loca_codigo
JOIN [9999_ROWS_AFFECTED].Provincia ON loca_provincia_id = prov_codigo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Sucursal ON bi_sucu_codigo = envi_ticket_cod_sucursal
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo ON bi_tiempo_anio = YEAR(envi_fecha_hora_entrega) AND bi_tiempo_mes = MONTH(envi_fecha_hora_entrega)
LEFT JOIN [9999_ROWS_AFFECTED].BI_Rango_Etario ON bi_rango_etario_desc = [9999_ROWS_AFFECTED].getRangoEtario(clie_nacimiento)
LEFT JOIN [9999_ROWS_AFFECTED].BI_Ubicacion ON bi_ubi_provincia = prov_nombre AND bi_ubi_localidad = loca_nombre
GROUP BY bi_sucu_codigo, bi_tiempo_codigo, bi_rango_etario_codigo, bi_ubi_codigo
-- FIN IMPORT BI_Hecho_Envio

-- IMPORT BI_Hecho_Promocion
INSERT INTO [9999_ROWS_AFFECTED].BI_Hecho_Promocion(codigo_tiempo, codigo_categoria_subcategoria, descuentos_aplicados)
	SELECT DISTINCT bi_tiempo_codigo, bi_cate_subc_codigo, SUM(prom_apli_dto)
FROM [9999_ROWS_AFFECTED].Promocion
JOIN [9999_ROWS_AFFECTED].PromocionAplicada ON prom_apli_promocion = prom_codigo
JOIN [9999_ROWS_AFFECTED].Producto ON prom_apli_producto = prod_codigo
JOIN [9999_ROWS_AFFECTED].Categoria ON prod_cod_categoria = cate_codigo
JOIN [9999_ROWS_AFFECTED].Subcategoria ON cate_subcategoria = subc_codigo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo ON bi_tiempo_anio = YEAR(prom_fecha_fin) AND bi_tiempo_mes = MONTH(prom_fecha_fin)
LEFT JOIN [9999_ROWS_AFFECTED].BI_Categoria_Subcategoria ON bi_cate_subc_nombre_cate = cate_nombre AND bi_cate_subc_nombre_subc = subc_nombre
GROUP BY bi_tiempo_codigo, bi_cate_subc_codigo
-- FIN IMPORT BI_Hecho_Promocion

GO
/* ------- FIN DE CARGA DE LOS HECHOS ------- */

/* ------- INICIO DE LAS VISTAS ------- */

-- VISTA 1
CREATE VIEW [9999_ROWS_AFFECTED].BI_ticket_promedio_mensual AS
SELECT
	bi_u.bi_ubi_localidad localidad,
	bi_t.bi_tiempo_anio anio,
	bi_t.bi_tiempo_mes mes,
	(SUM(bi_hv.sumatoria_importe) / SUM(bi_hv.cantidad_ventas_totales)) ticket_promedio
FROM [9999_ROWS_AFFECTED].BI_Hecho_Venta bi_hv
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_hv.codigo_tiempo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Ubicacion bi_u ON bi_u.bi_ubi_codigo = bi_hv.codigo_ubicacion
GROUP BY bi_u.bi_ubi_localidad, bi_t.bi_tiempo_anio, bi_t.bi_tiempo_mes
GO
-- FIN VISTA 1

-- VISTA 2
CREATE VIEW [9999_ROWS_AFFECTED].BI_cantidad_unidades_promedio AS
SELECT
	bi_t.bi_tiempo_anio anio,
	bi_t.bi_tiempo_cuatri cuatrimestre,
	bi_turno.bi_turno_desc turno,
	(SUM(bi_hc.total_articulos_vendidos) / SUM(distinct bi_hc.cantidad_tickets)) promedio_articulos
FROM [9999_ROWS_AFFECTED].BI_Hecho_Compra bi_hc
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_hc.codigo_tiempo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Turno bi_turno ON bi_turno.bi_turno_codigo = bi_hc.codigo_turno
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_cuatri, bi_turno.bi_turno_desc
GO
-- FIN VISTA 2

-- VISTA 3
CREATE VIEW [9999_ROWS_AFFECTED].BI_porcentaje_anual_ventas AS
SELECT
	bi_t.bi_tiempo_anio anio,
	bi_t.bi_tiempo_cuatri cuatrimestre,
	bi_r.bi_rango_etario_desc rango_etario,
	bi_c.bi_tipo_caja_desc tipo_caja,
	SUM(bi_hv.cantidad_ventas_totales) /
	(SELECT SUM(cantidad_ventas_totales) FROM [9999_ROWS_AFFECTED].BI_Hecho_Venta
	LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo ON bi_tiempo_codigo = codigo_tiempo
	WHERE bi_tiempo_anio = bi_t.bi_tiempo_anio) * 100 porcentaje
FROM [9999_ROWS_AFFECTED].BI_Hecho_Venta bi_hv
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_hv.codigo_tiempo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Rango_Etario bi_r ON bi_r.bi_rango_etario_codigo = bi_hv.codigo_rango_etario_empleado
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tipo_Caja bi_c ON bi_c.bi_tipo_caja_codigo = bi_hv.codigo_tipo_caja
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_cuatri, bi_r.bi_rango_etario_desc, bi_c.bi_tipo_caja_desc
GO
-- FIN VISTA 3

-- VISTA 4
CREATE VIEW [9999_ROWS_AFFECTED].BI_cant_ventas_por_turno AS
SELECT
	bi_turno.bi_turno_desc turno,
	bi_u.bi_ubi_localidad localidad,
	bi_t.bi_tiempo_mes mes,
	bi_t.bi_tiempo_anio anio,
	SUM(bi_hv.cantidad_ventas_totales) cantidad_ventas
FROM [9999_ROWS_AFFECTED].BI_Hecho_Venta bi_hv
LEFT JOIN [9999_ROWS_AFFECTED].BI_Ubicacion bi_u ON bi_u.bi_ubi_codigo = bi_hv.codigo_ubicacion
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_hv.codigo_tiempo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Turno bi_turno ON bi_turno.bi_turno_codigo = bi_hv.codigo_turno
GROUP BY bi_turno.bi_turno_desc, bi_u.bi_ubi_localidad, bi_t.bi_tiempo_mes, bi_t.bi_tiempo_anio
GO
-- FIN VISTA 4

-- VISTA 5
CREATE VIEW [9999_ROWS_AFFECTED].BI_porcentaje_desc_aplicado AS
SELECT
	bi_t.bi_tiempo_anio anio,
	bi_t.bi_tiempo_mes mes,
	SUM(bi_hc.descuento_aplicado) / SUM(bi_hc.monto_total_ticket) * 100 porcentaje
FROM [9999_ROWS_AFFECTED].BI_Hecho_Compra bi_hc
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_hc.codigo_tiempo
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_mes
GO
-- FIN VISTA 5

-- VISTA 6
CREATE VIEW [9999_ROWS_AFFECTED].BI_top_categorias_mayor_desc_aplicado AS
SELECT TOP 3
	bi_c.bi_cate_subc_nombre_cate categoria,
	bi_t.bi_tiempo_anio anio,
	bi_t.bi_tiempo_cuatri cuatrimestre,
	MAX(bi_hp.descuentos_aplicados) descuentos_aplicados
FROM [9999_ROWS_AFFECTED].BI_Hecho_Promocion bi_hp
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_hp.codigo_tiempo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Categoria_Subcategoria bi_c ON bi_c.bi_cate_subc_codigo = bi_hp.codigo_categoria_subcategoria
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_cuatri, bi_c.bi_cate_subc_nombre_cate
ORDER BY MAX(bi_hp.descuentos_aplicados) DESC
GO
-- FIN VISTA 6

-- VISTA 7
CREATE VIEW [9999_ROWS_AFFECTED].BI_porcentaje_cumplimiento_envios AS
SELECT
	bi_t.bi_tiempo_anio anio,
	bi_t.bi_tiempo_mes mes,
	bi_s.bi_sucu_nombre sucursal,
	SUM(bi_he.cantidad_envios_cumplidos) / SUM(bi_he.cantidad_envios) * 100 porcentaje
FROM [9999_ROWS_AFFECTED].BI_Hecho_Envio bi_he
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_he.codigo_tiempo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Sucursal bi_s ON bi_s.bi_sucu_codigo = bi_he.codigo_sucursal
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_mes, bi_s.bi_sucu_nombre
GO
-- FIN VISTA 7

-- VISTA 8
CREATE VIEW [9999_ROWS_AFFECTED].BI_cant_envios_por_rango_cliente AS
SELECT
	bi_t.bi_tiempo_anio anio,
	bi_t.bi_tiempo_cuatri cuatrimestre,
	bi_r.bi_rango_etario_desc rango_etario,
	SUM(bi_he.cantidad_envios) cantidad_envios
FROM [9999_ROWS_AFFECTED].BI_Hecho_Envio bi_he
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_he.codigo_tiempo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Rango_Etario bi_r ON bi_r.bi_rango_etario_codigo = bi_he.codigo_rango_etario
GROUP BY bi_t.bi_tiempo_anio, bi_t.bi_tiempo_cuatri, bi_r.bi_rango_etario_desc
GO
-- FIN VISTA 8

-- VISTA 9
CREATE VIEW [9999_ROWS_AFFECTED].BI_localidades_con_mayor_costo AS
SELECT TOP 5
	bi_u.bi_ubi_localidad localidad,
	MAX(bi_he.costo_total) costo
FROM [9999_ROWS_AFFECTED].BI_Hecho_Envio bi_he
LEFT JOIN [9999_ROWS_AFFECTED].BI_Ubicacion bi_u ON bi_u.bi_ubi_codigo = bi_he.codigo_ubicacion
GROUP BY bi_u.bi_ubi_localidad
ORDER BY MAX(bi_he.costo_total) DESC
GO
-- FIN VISTA 9

-- VISTA 10
CREATE VIEW [9999_ROWS_AFFECTED].BI_sucursales_mayor_importe_cuotas AS
SELECT TOP 3
	bi_s.bi_sucu_nombre sucursal,
	bi_t.bi_tiempo_anio anio,
	bi_t.bi_tiempo_mes mes,
	bi_m.bi_mp_desc medio_pago,
	MAX(bi_hv.sumatoria_importe_en_cuotas) mayor_pagos_en_cuotas
FROM [9999_ROWS_AFFECTED].BI_Hecho_Venta bi_hv
LEFT JOIN [9999_ROWS_AFFECTED].BI_Sucursal bi_s ON bi_s.bi_sucu_codigo = bi_hv.codigo_sucursal
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_hv.codigo_tiempo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Medio_Pago bi_m ON bi_m.bi_mp_codigo = bi_hv.codigo_mp
GROUP BY  bi_s.bi_sucu_nombre, bi_t.bi_tiempo_anio, bi_t.bi_tiempo_mes, bi_m.bi_mp_desc
ORDER BY MAX(bi_hv.sumatoria_importe_en_cuotas) DESC
GO
-- FIN VISTA 10

-- VISTA 11
CREATE VIEW [9999_ROWS_AFFECTED].BI_promedio_importe_cuotas_por_rango_etario AS
SELECT
	bi_r.bi_rango_etario_desc rango_etario,
	SUM(bi_hv.sumatoria_importe_en_cuotas_cliente) / SUM(bi_hv.cantidad_ventas_totales_cuotas_cliente) promedio
FROM [9999_ROWS_AFFECTED].BI_Hecho_Venta bi_hv
LEFT JOIN [9999_ROWS_AFFECTED].BI_Rango_Etario bi_r ON bi_r.bi_rango_etario_codigo = bi_hv.codigo_rango_etario_cliente
GROUP BY bi_r.bi_rango_etario_desc
GO
-- FIN VISTA 11

-- VISTA 12
CREATE VIEW [9999_ROWS_AFFECTED].BI_porcentaje_desc_aplicado_por_mp AS
SELECT
	bi_t.bi_tiempo_cuatri cuatrimestre,
	bi_m.bi_mp_desc medio_pago,
	SUM(bi_hv.pago_total_desc_aplicado) / SUM(bi_hv.pago_total_bruto) * 100 porcentaje
FROM [9999_ROWS_AFFECTED].BI_Hecho_Venta bi_hv
LEFT JOIN [9999_ROWS_AFFECTED].BI_Tiempo bi_t ON bi_t.bi_tiempo_codigo = bi_hv.codigo_tiempo
LEFT JOIN [9999_ROWS_AFFECTED].BI_Medio_Pago bi_m ON bi_m.bi_mp_codigo = bi_hv.codigo_mp
GROUP BY bi_t.bi_tiempo_cuatri, bi_m.bi_mp_desc
GO
-- FIN VISTA 12

/* ------- FIN DE LAS VISTAS ------- */