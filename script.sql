USE GD2C2024
GO

--============================================================================================================================
--    Creacion de schema
--============================================================================================================================

IF NOT EXISTS (SELECT schema_id FROM sys.schemas WHERE name = 'EXEL_ENTES')
BEGIN
	EXEC('CREATE SCHEMA EXEL_ENTES;');
	PRINT 'Schema EXEL_ENTES creado correctamente.';
END
ELSE
BEGIN
	PRINT 'Schema EXEL_ENTES ya existe.';
END

--============================================================================================================================



--============================================================================================================================
--    Creacion de tablas
--============================================================================================================================

-- dropeamos las tablas si existen -------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Envio')
DROP TABLE [EXEL_ENTES].[Envio]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Marca')
DROP TABLE [EXEL_ENTES].[Marca]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Modelo')
DROP TABLE [EXEL_ENTES].[Modelo]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Rubro')
DROP TABLE [EXEL_ENTES].[Rubro]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Subrubro')
DROP TABLE [EXEL_ENTES].[Subrubro]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Venta')
DROP TABLE [EXEL_ENTES].[Venta]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Publicacion')
DROP TABLE [EXEL_ENTES].[Publicacion]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Producto')
DROP TABLE [EXEL_ENTES].[Producto]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Usuario')
DROP TABLE [EXEL_ENTES].[Usuario]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Cliente')
DROP TABLE [EXEL_ENTES].[Cliente]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Vendedor')
DROP TABLE [EXEL_ENTES].[Vendedor]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Almacen')
DROP TABLE [EXEL_ENTES].[Almacen]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Factura')
DROP TABLE [EXEL_ENTES].[Factura]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Pago')
DROP TABLE [EXEL_ENTES].[Pago]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'MedioDePago')
DROP TABLE [EXEL_ENTES].[MedioDePago]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'TipoMedioDePago')
DROP TABLE [EXEL_ENTES].[TipoMedioDePago]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'TipoEnvio')
DROP TABLE [EXEL_ENTES].[TipoEnvio]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Localidad')
DROP TABLE [EXEL_ENTES].[Localidad]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Provincia')
DROP TABLE [EXEL_ENTES].[Provincia]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Detalle_Factura')
DROP TABLE [EXEL_ENTES].[Detalle_Factura]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Detalle_Pago')
DROP TABLE [EXEL_ENTES].[Detalle_Pago]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Detalle_Venta')
DROP TABLE [EXEL_ENTES].[Detalle_Venta]

-- creamos las tablas ------------------------------------------------------------------------------------------------------

SELECT *
FROM information_schema.tables
WHERE table_schema = 'EXEL_ENTES';

SELECT * FROM sys.schemas WHERE name = 'EXEL_ENTES';


SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM
    information_schema.columns
WHERE
    table_schema = 'EXEL_ENTES' AND
    table_name = 'Usuario';



CREATE TABLE [EXEL_ENTES].[Usuario] (
    Codigo_Usuario INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_Usuario] PRIMARY KEY (Codigo_Usuario),
    Nombre NVARCHAR(50),
    Apellido NVARCHAR(100),
    Email NVARCHAR(50),
    Fecha_Creacion DATETIME,
    Domicilio NVARCHAR(100),
    DNI DECIMAL(18, 0),
    Fecha_Nacimiento DATE
);

CREATE TABLE [EXEL_ENTES].[Cliente] (
    Codigo_Cliente INT IDENTITY(1,1) NOT NULL,
	Codigo_Usuario INT NOT NULL,
	CONSTRAINT [PK_Cliente] PRIMARY KEY (Codigo_Cliente),
    CONSTRAINT [FK_Cliente_Codigo_usuario] FOREIGN KEY (Codigo_Usuario) REFERENCES [EXEL_ENTES].[Usuario](Codigo_Usuario)
);

CREATE TABLE [EXEL_ENTES].[Vendedor] (
    Codigo_Vendedor INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_Vendedor] PRIMARY KEY (Codigo_Vendedor),
    Codigo_Usuario NVARCHAR(50),
    Razon_Social NVARCHAR(50),
    CUIT NVARCHAR(50),
	Mail NVARCHAR(50)
);

CREATE TABLE [EXEL_ENTES].[Producto] (
    Codigo_Producto NVARCHAR(50) NOT NULL,
	CONSTRAINT [PK_Producto] PRIMARY KEY (Codigo_Producto),
    Rubro NVARCHAR(50),
    Codigo_Marca DECIMAL(18, 0),
    Descripcion NVARCHAR(255),
    Modelo NVARCHAR(50)
);

CREATE TABLE [EXEL_ENTES].[Publicacion] (
    Codigo_Publicacion DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Publicacion] PRIMARY KEY (Codigo_Publicacion),
    CONSTRAINT [FK_Publicacion_Codigo_Producto] FOREIGN KEY (Codigo_Producto) REFERENCES [EXEL_ENTES].[Producto](Codigo_Producto),
    CONSTRAINT [FK_Publicacion_Codigo_Vendedor] FOREIGN KEY (Codigo_Vendedor) REFERENCES [EXEL_ENTES].[Vendedor](Codigo_Vendedor),
    Codigo_Almacen DECIMAL(18, 0),
    Codigo_Producto NVARCHAR(50),
    Codigo_Vendedor INT,
    Fecha_Inicio DATE,
    Fecha_Fin DATE,
    Stock DECIMAL(18, 0),
    Precio DECIMAL(18, 2)
);

CREATE TABLE [EXEL_ENTES].[Venta] (
    Numero_Venta DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Venta] PRIMARY KEY (Numero_Venta),
    CONSTRAINT [FK_Venta_Codigo_Cliente] FOREIGN KEY (Codigo_Cliente) REFERENCES [EXEL_ENTES].[Cliente](Codigo_Cliente),
    CONSTRAINT [FK_Venta_Codigo_Publicacion] FOREIGN KEY (Codigo_Publicacion) REFERENCES [EXEL_ENTES].[Publicacion](Codigo_Publicacion),
    Codigo_Cliente INT,
    Codigo_Publicacion DECIMAL(18, 0),
    Fecha_Venta DATETIME,
    Total DECIMAL(18, 2)
);

CREATE TABLE [EXEL_ENTES].[Almacen] (
    Codigo_Almacen DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Almacen] PRIMARY KEY (Codigo_Almacen),
    Calle NVARCHAR(50) NULL,
    Numero DECIMAL(18, 0) NULL,
    Costo DECIMAL(18, 2) NULL,
    Localidad NVARCHAR(50) NULL,
	Provincia NVARCHAR(50)
);

CREATE TABLE [EXEL_ENTES].[Factura] (
    Numero_Factura DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Factura] PRIMARY KEY (Numero_Factura),
    CONSTRAINT [FK_Factura_Codigo_Vendedor] FOREIGN KEY (Codigo_Vendedor) REFERENCES [EXEL_ENTES].[Vendedor](Codigo_Vendedor),
    CONSTRAINT [FK_Factura_Codigo_Cliente] FOREIGN KEY (Codigo_Cliente) REFERENCES [EXEL_ENTES].[Cliente](Codigo_Cliente),
    Codigo_Vendedor INT NOT NULL,
    Codigo_Cliente INT NOT NULL,
    Fecha_Factura DATE NULL,
    Total DECIMAL(18, 2) NULL
);

CREATE TABLE [EXEL_ENTES].[TipoMedioDePago] (
    Tipo_Medio_Pago_Codigo INT NOT NULL,
	CONSTRAINT [PK_TipoMedioDePago] PRIMARY KEY (Tipo_Medio_Pago_Codigo),
    Descripcion_tipo_medio_de_pago NVARCHAR(50) NULL
);

CREATE TABLE [EXEL_ENTES].[MedioDePago] (
    Codigo_MedioPago INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_MedioDePago] PRIMARY KEY (Codigo_MedioPago),
    Descripcion_medio_pago NVARCHAR(50) NULL,
	Tipo_Medio_Pago_Codigo INT,
	CONSTRAINT [FK_MedioDePago_Codigo_Tipo_Medio_De_Pago] FOREIGN KEY (Tipo_Medio_Pago_Codigo) REFERENCES [EXEL_ENTES].[TipoMedioDePago](Tipo_Medio_Pago_Codigo)
);

CREATE TABLE [EXEL_ENTES].[Pago] (
    Numero_Pago INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_Pago] PRIMARY KEY (Numero_Pago),
    CONSTRAINT [FK_Pago_Numero_Venta] FOREIGN KEY (Codigo_Numero_Venta) REFERENCES [EXEL_ENTES].[Venta](Numero_Venta),
    CONSTRAINT [FK_Pago_Codigo_Cliente] FOREIGN KEY (Codigo_Cliente) REFERENCES [EXEL_ENTES].[Cliente](Codigo_Cliente), ---
    CONSTRAINT [FK_Pago_Codigo_MedioPago] FOREIGN KEY (Codigo_MedioPago) REFERENCES [EXEL_ENTES].[MedioDePago](Codigo_MedioPago),    
	Codigo_Numero_Venta DECIMAL(18, 0) NOT NULL,
    Codigo_Cliente INT NOT NULL, ---------
	Codigo_MedioPago INT NOT NULL,
    Importe DECIMAL(18, 2) NOT NULL,
    Fecha DATE NULL
);

CREATE TABLE [EXEL_ENTES].[Detalle_Pago] (
    CONSTRAINT [FK_Nro_Pago] FOREIGN KEY (Nro_Pago) REFERENCES [EXEL_ENTES].[Pago](Numero_Pago),
    CONSTRAINT [FK_Medio_Pago] FOREIGN KEY (Medio_Pago) REFERENCES [EXEL_ENTES].[MedioDePago](Codigo_MedioPago),
    Nro_Pago INT NOT NULL,
    Medio_Pago INT NOT NULL,
    CONSTRAINT [FK_Codigo_Cliente] FOREIGN KEY (Codigo_Cliente) REFERENCES [EXEL_ENTES].[Cliente](Codigo_Cliente), 
    Fecha_Vencimiento_Tarjeta DATE NULL,
	Codigo_Cliente INT NOT NULL,
    Cuotas DECIMAL(18, 2) NULL,
    Nro_Tarjeta DECIMAL(16, 0) NULL
);

CREATE TABLE [EXEL_ENTES].[Detalle_Venta] (
    CONSTRAINT [FK_Detalle_Venta_Numero_Venta] FOREIGN KEY (Numero_Venta) REFERENCES [EXEL_ENTES].[Venta](Numero_Venta),
    CONSTRAINT [FK_Detalle_Venta_Codigo_Publicacion] FOREIGN KEY (Codigo_Publicacion) REFERENCES [EXEL_ENTES].[Publicacion](Codigo_Publicacion),
    Numero_Venta DECIMAL(18, 0) NOT NULL,
    Codigo_Publicacion DECIMAL(18, 0) NOT NULL,
    Cantidad DECIMAL(18, 0) NOT NULL,
    Precio DECIMAL(18, 2) NOT NULL,
	Subtotal DECIMAL(18,2) NOT NULL
);


CREATE TABLE [EXEL_ENTES].[TipoEnvio] (
    Codigo_TipoEnvio INT IDENTITY (1,1) NOT NULL,
	CONSTRAINT [PK_TipoEnvio] PRIMARY KEY (Codigo_TipoEnvio),
    Descripcion NVARCHAR(50) NULL
);

CREATE TABLE [EXEL_ENTES].[Envio] (
    Nro_Envio DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Envio] PRIMARY KEY (Nro_Envio),
    CONSTRAINT [FK_Envio_Nro_Venta] FOREIGN KEY (Nro_Venta) REFERENCES [EXEL_ENTES].[Venta](Numero_Venta),
    CONSTRAINT [FK_Envio_Tipo_Envio] FOREIGN KEY (Tipo_Envio) REFERENCES [EXEL_ENTES].[TipoEnvio](Codigo_TipoEnvio),
    Nro_Venta DECIMAL(18, 0) NOT NULL,
    Fecha_Programada DATE NULL,
	Hora_inicio DECIMAL(18, 0) NOT NULL,
	Hora_fin_inicio DECIMAL(18, 0) NOT NULL,
    Fecha_Entrega DATETIME NULL,
    Costo_Envio DECIMAL(18, 2) NULL,
    Tipo_Envio  INT NOT NULL
);

select distinct PRODUCTO_MARCA from gd_esquema.Maestra

CREATE TABLE [EXEL_ENTES].[Marca] (
    Codigo_Marca NVARCHAR(50) NOT NULL,
	CONSTRAINT [PK_Marca] PRIMARY KEY (Codigo_Marca),
    Descripcion NVARCHAR(50) NULL
);

CREATE TABLE [EXEL_ENTES].[Subrubro] (
    Codigo_Subrubro NVARCHAR(50) NOT NULL,
	CONSTRAINT [PK_Subrubro] PRIMARY KEY (Codigo_Subrubro),
    Descripcion NVARCHAR(255) NULL,
);

CREATE TABLE [EXEL_ENTES].[Rubro] (
    Codigo_Rubro NVARCHAR(50) NOT NULL,
	CONSTRAINT [PK_Rubro] PRIMARY KEY (Codigo_Rubro),
    Descripcion NVARCHAR(255) NULL
	CONSTRAINT [FK_Rubro_Codigo_Subrubro] FOREIGN KEY (Codigo_Subrubro) REFERENCES [EXEL_ENTES].[Subrubro](Codigo_Subrubro),
	Codigo_Subrubro NVARCHAR(50) NOT NULL
);

CREATE TABLE [EXEL_ENTES].[Provincia] (
    Codigo_Provincia INT IDENTITY (1,1) NOT NULL,
	CONSTRAINT [PK_Provincia] PRIMARY KEY (Codigo_Provincia),
    Nombre NVARCHAR(255) NULL
);

CREATE TABLE [EXEL_ENTES].[Localidad] (
    Codigo_Localidad DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Localidad] PRIMARY KEY (Codigo_Localidad),
    CONSTRAINT [FK_Localidad_Provincia] FOREIGN KEY (Codigo_Provincia) REFERENCES [EXEL_ENTES].[Provincia](Codigo_Provincia),
    Descripcion NVARCHAR(255) NULL,
    Codigo_Provincia  INT NOT NULL
);

CREATE TABLE [EXEL_ENTES].[Detalle_Factura] (
    CONSTRAINT [FK_Detalle_Factura_Nro_Factura] FOREIGN KEY (Nro_Factura) REFERENCES [EXEL_ENTES].[Factura](Numero_Factura),
    CONSTRAINT [FK_Detalle_Factura_Cod_Publicacion] FOREIGN KEY (Codigo_Publicacion) REFERENCES [EXEL_ENTES].[Publicacion](Codigo_Publicacion),
    Nro_Factura DECIMAL(18, 0) NOT NULL,
    Codigo_Publicacion DECIMAL(18, 0) NOT NULL,
	Concepto NVARCHAR(50),
    Cantidad DECIMAL(18, 0) NOT NULL,
    Precio DECIMAL(18, 2) NULL
);

CREATE TABLE [EXEL_ENTES].[Modelo] (
    Codigo_Modelo INT IDENTITY(1,1)  NOT NULL,
	CONSTRAINT [PK_Modelo] PRIMARY KEY (Codigo_Modelo),
    Descripcion NVARCHAR(255) NULL
);



--============================================================================================================================





--============================================================================================================================
--    Creacion de stored procedures
--============================================================================================================================

-- creamos los procedures ----------------------------------------------------------------------------------------------------
/*
IF EXISTS (SELECT [name] FROM sys.procedures WHERE [name] = 'migrar_cliente')
    DROP PROCEDURE [EXEL_ENTES].migrar_cliente;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_cliente
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Cliente] (Codigo_Cliente, Codigo_Usuario)
    SELECT DISTINCT Codigo_Cliente, Codigo_Usuario
    FROM gd_esquema.Maestra
    WHERE Codigo_Cliente IS NOT NULL
    ORDER BY Codigo_Cliente ASC;
END
GO*/
------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_vendedor')
    DROP PROCEDURE [EXEL_ENTES].migrar_vendedor;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_vendedor
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Vendedor] (Mail, Razon_Social, CUIT)
    SELECT DISTINCT VENDEDOR_MAIL,VENDEDOR_RAZON_SOCIAL, VENDEDOR_CUIT
    FROM gd_esquema.Maestra
END
GO

SELECT * FROM EXEL_ENTES.Vendedor
EXECUTE [EXEL_ENTES].migrar_vendedor;

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_producto')
    DROP PROCEDURE [EXEL_ENTES].migrar_producto;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_producto
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Producto] (Codigo_Producto, Rubro, Codigo_Marca, Descripcion, Modelo)
    SELECT DISTINCT PRODUCTO_CODIGO, PRODUCTO_SUB_RUBRO, PRODUCTO_MARCA, PRODUCTO_DESCRIPCION, PRODUCTO_MOD_CODIGO
    FROM gd_esquema.Maestra
    WHERE PRODUCTO_CODIGO IS NOT NULL
    ORDER BY PRODUCTO_CODIGO ASC;
    
    INSERT INTO [EXEL_ENTES].[Modelo] (Codigo_Modelo, Descripcion)
    SELECT DISTINCT PRODUCTO_MOD_CODIGO, PRODUCTO_MOD_DESCRIPCION
    FROM gd_esquema.Maestra
    WHERE PRODUCTO_MOD_CODIGO IS NOT NULL
    ORDER BY PRODUCTO_MOD_CODIGO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_publicacion')
    DROP PROCEDURE [EXEL_ENTES].migrar_publicacion;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_publicacion
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Publicacion] (Codigo_Publicacion, Codigo_Producto, Fecha_Inicio, Fecha_Fin, Stock, Precio)
    SELECT DISTINCT PUBLICACION_CODIGO, PRODUCTO_CODIGO, PUBLICACION_FECHA, PUBLICACION_FECHA_V, PUBLICACION_STOCK, PUBLICACION_PRECIO
    FROM gd_esquema.Maestra
    WHERE PUBLICACION_CODIGO IS NOT NULL
    ORDER BY PUBLICACION_CODIGO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_venta')
    DROP PROCEDURE [EXEL_ENTES].migrar_venta;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_venta
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Venta] (Numero_Venta, Codigo_Publicacion, Fecha_Venta, Total)
    SELECT DISTINCT VENTA_CODIGO, PUBLICACION_CODIGO, VENTA_FECHA, VENTA_TOTAL
    FROM gd_esquema.Maestra
    WHERE VENTA_CODIGO IS NOT NULL
    ORDER BY VENTA_CODIGO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_factura')
    DROP PROCEDURE [EXEL_ENTES].migrar_factura;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_factura
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Factura] (Numero_Factura, Fecha_Factura, Total)
    SELECT DISTINCT FACTURA_NUMERO, FACTURA_FECHA, FACTURA_TOTAL
    FROM gd_esquema.Maestra
    WHERE FACTURA_NUMERO IS NOT NULL
    ORDER BY FACTURA_NUMERO ASC;
    
    INSERT INTO [EXEL_ENTES].[Detalle_Factura] (Nro_Factura, Codigo_Publicacion, Cantidad, Precio)
    SELECT DISTINCT FACTURA_NUMERO, PUBLICACION_CODIGO, FACTURA_DET_CANTIDAD, FACTURA_DET_PRECIO
    FROM gd_esquema.Maestra
    WHERE FACTURA_NUMERO IS NOT NULL
    ORDER BY FACTURA_NUMERO ASC;
END
GO
------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_pago') ----- Sofi
    DROP PROCEDURE [EXEL_ENTES].migrar_pago;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_pago
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Pago] (Codigo_Numero_Venta, Importe, Fecha)
    SELECT DISTINCT VENTA_CODIGO, PAGO_IMPORTE, PAGO_FECHA
    FROM gd_esquema.Maestra
    
    INSERT INTO [EXEL_ENTES].[Detalle_Pago] (Fecha_Vencimiento_Tarjeta, Cuotas, Nro_Tarjeta)
    SELECT DISTINCT PAGO_FECHA_VENC_TARJETA, PAGO_CANT_CUOTAS, PAGO_NRO_TARJETA
    FROM gd_esquema.Maestra
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_almacen') -------- Sofi
    DROP PROCEDURE [EXEL_ENTES].migrar_almacen;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_almacen
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Almacen] (Codigo_Almacen, Calle, Numero, Costo, Localidad, Provincia)
    SELECT DISTINCT ALMACEN_CODIGO, ALMACEN_CALLE, ALMACEN_NRO_CALLE, ALMACEN_COSTO_DIA_AL, ALMACEN_Localidad, ALMACEN_PROVINCIA
    FROM gd_esquema.Maestra
    WHERE ALMACEN_CODIGO IS NOT NULL
    ORDER BY ALMACEN_CODIGO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_envio') ----- Sofi
    DROP PROCEDURE [EXEL_ENTES].migrar_envio;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_envio
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Envio] (Nro_Envio, Nro_Venta, Fecha_Programada, Hora_inicio, Hora_fin_inicio, Fecha_Entrega, Costo_Envio, Tipo_Envio)
    SELECT DISTINCT ENVIO_CODIGO, VENTA_CODIGO, ENVIO_FECHA_PROGAMADA, ENVIO_HORA_INICIO, ENVIO_HORA_FIN_INICIO, ENVIO_FECHA_ENTREGA, ENVIO_COSTO, ENVIO_TIPO
    FROM gd_esquema.Maestra
    WHERE ENVIO_CODIGO IS NOT NULL
    ORDER BY ENVIO_CODIGO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_medio_pago') ----- Sofi con dudas
    DROP PROCEDURE [EXEL_ENTES].migrar_medio_pago;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_medio_pago
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[MedioDePago] (Descripcion_medio_pago, Tipo_Medio_Pago_Codigo)
    SELECT DISTINCT PAGO_MEDIO_PAGO, PAGO_TIPO_MEDIO_PAGO
    FROM gd_esquema.Maestra
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_tipo_envio') ----- SOfi
    DROP PROCEDURE [EXEL_ENTES].migrar_tipo_envio;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_tipo_envio
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[TipoEnvio] (Descripcion)
    SELECT DISTINCT ENVIO_DESCRIPCION
    FROM gd_esquema.Maestra
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_marca')
    DROP PROCEDURE [EXEL_ENTES].migrar_marca;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_marca
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Marca] (Codigo_Marca, Descripcion)
    SELECT DISTINCT PRODUCTO_MARCA, PRODUCTO_MARCA_DESCRIPCION
    FROM gd_esquema.Maestra
    WHERE PRODUCTO_MARCA IS NOT NULL
    ORDER BY PRODUCTO_MARCA ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_rubro')
    DROP PROCEDURE [EXEL_ENTES].migrar_rubro;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_rubro
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Rubro] (Codigo_Rubro, Descripcion)
    SELECT DISTINCT PRODUCTO_SUB_RUBRO, PRODUCTO_RUBRO_DESCRIPCION
    FROM gd_esquema.Maestra
    WHERE PRODUCTO_SUB_RUBRO IS NOT NULL
    ORDER BY PRODUCTO_SUB_RUBRO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_localidad')
    DROP PROCEDURE [EXEL_ENTES].migrar_localidad;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_localidad
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Localidad] (Codigo_Localidad, Descripcion, Codigo_Provincia)
    SELECT DISTINCT CLI_USUARIO_DOMICILIO_LOCALIDAD, CLI_USUARIO_DOMICILIO_LOCALIDAD, CLI_USUARIO_DOMICILIO_PROVINCIA
    FROM gd_esquema.Maestra
    WHERE CLI_USUARIO_DOMICILIO_LOCALIDAD IS NOT NULL
    ORDER BY CLI_USUARIO_DOMICILIO_LOCALIDAD ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_modelo')
    DROP PROCEDURE [EXEL_ENTES].migrar_modelo;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_modelo
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Modelo] (Codigo_Modelo, Descripcion)
    SELECT DISTINCT PRODUCTO_MOD_CODIGO, PRODUCTO_MOD_DESCRIPCION
    FROM gd_esquema.Maestra
    WHERE PRODUCTO_MOD_CODIGO IS NOT NULL  
    ORDER BY PRODUCTO_MOD_CODIGO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_provincia')
    DROP PROCEDURE [EXEL_ENTES].migrar_provincia;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_provincia
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Provincia] (Codigo_Provincia, Nombre)
    SELECT DISTINCT CLI_USUARIO_DOMICILIO_PROVINCIA, CLI_USUARIO_DOMICILIO_PROVINCIA
    FROM gd_esquema.Maestra
    WHERE CLI_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL  
    ORDER BY CLI_USUARIO_DOMICILIO_PROVINCIA ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_tipo_medio_pago') ------- Sofi con dudas
    DROP PROCEDURE [EXEL_ENTES].migrar_tipo_medio_pago;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_tipo_medio_pago
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[TipoMedioDePago] (Tipo_Medio_Pago_Codigo, Descripcion)
    SELECT DISTINCT PAGO_TIPO_MEDIO_PAGO, PAGO_TIPO_MEDIO_PAGO
    FROM gd_esquema.Maestra
    WHERE PAGO_TIPO_MEDIO_PAGO IS NOT NULL  
    ORDER BY PAGO_TIPO_MEDIO_PAGO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_usuario')
    DROP PROCEDURE [EXEL_ENTES].migrar_usuario;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_usuario
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Usuario] (Codigo_Usuario, Nombre, Email, Fecha_Creacion, Domicilio, DNI, Fecha_Nacimiento)
    SELECT DISTINCT CLI_USUARIO_NOMBRE, CLIENTE_NOMBRE, CLIENTE_MAIL, CLI_USUARIO_FECHA_CREACION, 
                    CLI_USUARIO_DOMICILIO_CALLE + ' ' + CAST(CLI_USUARIO_DOMICILIO_NRO_CALLE AS NVARCHAR), CLIENTE_DNI, CLIENTE_FECHA_NAC
    FROM gd_esquema.Maestra
    WHERE CLI_USUARIO_NOMBRE IS NOT NULL
    ORDER BY CLI_USUARIO_NOMBRE ASC;
END
GO
------------------------------------------------------------------------------------------------------------------------------

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_subrubro')
    DROP PROCEDURE [EXEL_ENTES].migrar_subrubro;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_subrubro
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Subrubro] (Codigo_Subrubro, Descripcion, Codigo_Rubro)
    SELECT DISTINCT PRODUCTO_SUB_RUBRO, PRODUCTO_SUB_RUBRO_DESCRIPCION, PRODUCTO_RUBRO_DESCRIPCION
    FROM gd_esquema.Maestra
    WHERE PRODUCTO_SUB_RUBRO IS NOT NULL
    ORDER BY PRODUCTO_SUB_RUBRO ASC;
END
GO

-------------------------------------------------------------------------------------------------------
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_detalle_venta')
    DROP PROCEDURE [EXEL_ENTES].migrar_detalle_venta;
GO

CREATE PROCEDURE [EXEL_ENTES].migrar_detalle_venta
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Detalle_Venta] (Numero_Venta, Codigo_Publicacion, Cantidad, Precio)
    SELECT DISTINCT 
        VENTA_CODIGO, 
        PUBLICACION_CODIGO, 
        VENTA_DET_CANT, 
        VENTA_DET_PRECIO
    FROM 
        gd_esquema.Maestra
    WHERE 
        VENTA_CODIGO IS NOT NULL 
        AND PUBLICACION_CODIGO IS NOT NULL
    ORDER BY 
        VENTA_CODIGO ASC;
END
GO




/*--------------------------------FIN DE EJECUCION DE STORED PROCEDURES: MIGRACION--------------------------------*/
BEGIN TRANSACTION
BEGIN TRY
    -- Ejecutamos los stored procedures para migrar cada una de las tablas
    EXECUTE [EXEL_ENTES].migrar_usuario;
    EXECUTE [EXEL_ENTES].migrar_cliente;
    EXECUTE [EXEL_ENTES].migrar_vendedor;
    EXECUTE [EXEL_ENTES].migrar_producto;
    EXECUTE [EXEL_ENTES].migrar_publicacion;
    EXECUTE [EXEL_ENTES].migrar_venta;
    EXECUTE [EXEL_ENTES].migrar_factura;
    EXECUTE [EXEL_ENTES].migrar_detalle_factura;
    EXECUTE [EXEL_ENTES].migrar_pago;
    EXECUTE [EXEL_ENTES].migrar_detalle_pago;
    EXECUTE [EXEL_ENTES].migrar_almacen;
    EXECUTE [EXEL_ENTES].migrar_envio;
    EXECUTE [EXEL_ENTES].migrar_medio_pago;
    EXECUTE [EXEL_ENTES].migrar_tipo_envio;
    EXECUTE [EXEL_ENTES].migrar_marca;
    EXECUTE [EXEL_ENTES].migrar_rubro;
    EXECUTE [EXEL_ENTES].migrar_localidad;
    EXECUTE [EXEL_ENTES].migrar_modelo;
    EXECUTE [EXEL_ENTES].migrar_provincia;
    EXECUTE [EXEL_ENTES].migrar_tipo_medio_pago;
    EXECUTE [EXEL_ENTES].migrar_subrubro;
    EXECUTE [EXEL_ENTES].migrar_detalle_venta;

    -- Si todo está correcto, realizamos el commit de la transacción
    COMMIT TRANSACTION;
    PRINT 'Migración realizada correctamente.';
END TRY
BEGIN CATCH
    -- Si ocurre un error, realizamos el rollback de la transacción
    ROLLBACK TRANSACTION;
    THROW 50001, 'Error durante la migración. Transacción deshecha.', 1;
END CATCH;
GO