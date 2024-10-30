
--============================================================================================================================
--    Creacion de schema
--============================================================================================================================
-- para eliminar el schema ---------------------------------------------
/*IF EXISTS (SELECT schema_id FROM sys.schemas WHERE name = 'EXEL_ENTES')
BEGIN
	EXEC('DROP SCHEMA EXEL_ENTES;');
	PRINT 'Schema EXEL_ENTES eliminado correctamente.';
END
ELSE
BEGIN
	PRINT 'Schema EXEL_ENTES no existe.';
END*/
------------------------------------------------------------------------

USE GD2C2024
GO

--    Creacion de schema

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
--    Creacion de tablas
--============================================================================================================================

-- dropeamos las tablas si existen -------------------------------------------------------------------------------------------

-- orden segun creacion
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Envio')
DROP TABLE [EXEL_ENTES].[Envio]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'TipoEnvio')
DROP TABLE [EXEL_ENTES].[TipoEnvio]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Detalle_Venta')
DROP TABLE [EXEL_ENTES].[Detalle_Venta]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Detalle_Pago')
DROP TABLE [EXEL_ENTES].[Detalle_Pago]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Pago')
DROP TABLE [EXEL_ENTES].[Pago]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'MedioDePago')
DROP TABLE [EXEL_ENTES].[MedioDePago]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'TipoMedioDePago')
DROP TABLE [EXEL_ENTES].[TipoMedioDePago]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Detalle_Factura')
DROP TABLE [EXEL_ENTES].[Detalle_Factura]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Factura')
DROP TABLE [EXEL_ENTES].[Factura]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Venta')
DROP TABLE [EXEL_ENTES].[Venta]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Cliente')
DROP TABLE [EXEL_ENTES].[Cliente]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Producto')
DROP TABLE [EXEL_ENTES].[Producto]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Publicacion')
DROP TABLE [EXEL_ENTES].[Publicacion]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Vendedor')
DROP TABLE [EXEL_ENTES].[Vendedor]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Usuario')
DROP TABLE [EXEL_ENTES].[Usuario]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Modelo')
DROP TABLE [EXEL_ENTES].[Modelo]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Marca')
DROP TABLE [EXEL_ENTES].[Marca]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Subrubro')
DROP TABLE [EXEL_ENTES].[Subrubro]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Rubro')
DROP TABLE [EXEL_ENTES].[Rubro]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Almacen')
DROP TABLE [EXEL_ENTES].[Almacen]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Localidad')
DROP TABLE [EXEL_ENTES].[Localidad]
IF EXISTS (SELECT name FROM sys.tables WHERE name = 'Provincia')
DROP TABLE [EXEL_ENTES].[Provincia]


-- creamos las tablas ------------------------------------------------------------------------------------------------------

CREATE TABLE [EXEL_ENTES].[Usuario] (
    Codigo_Usuario INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_Usuario] PRIMARY KEY (Codigo_Usuario),
    Nombre NVARCHAR(50),
    Pass NVARCHAR(50),
    Fecha_Creacion DATE,
    Domicilio_Calle NVARCHAR(50),
	Domicilio_Nro_Calle DECIMAL(18,0),
	Domicilio_Piso DECIMAL(18,0),
	Domicilio_Depto NVARCHAR(50),
	Domicilio_CP NVARCHAR(50),
	Domicilio_Localidad NVARCHAR(50),
	Domicilio_Provincia NVARCHAR(50),
	Mail NVARCHAR(50)
);

CREATE TABLE [EXEL_ENTES].[Cliente] (
    -- Codigo_Cliente INT IDENTITY(1,1) NOT NULL,    LA IDEA VA A SER COMPARTIR CODIGO CON USUARIO
	Codigo_Usuario INT NOT NULL,
	CONSTRAINT [PK_Cliente] PRIMARY KEY (Codigo_Usuario),
    CONSTRAINT [FK_Cliente_Codigo_usuario] FOREIGN KEY (Codigo_Usuario) REFERENCES [EXEL_ENTES].[Usuario](Codigo_Usuario),
	Cliente_Nombre NVARCHAR(50),
	Cliente_Apellido NVARCHAR(50),
	Cliente_Fecha_Nac DATE,
	Cliente_DNI DECIMAL(18,0)
);

CREATE TABLE [EXEL_ENTES].[Vendedor] (
    Codigo_Usuario INT NOT NULL,
--    Codigo_Vendedor INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_Vendedor] PRIMARY KEY (Codigo_Usuario),
	CONSTRAINT [FK_Vendedor_Codigo_usuario] FOREIGN KEY (Codigo_Usuario) REFERENCES [EXEL_ENTES].[Usuario](Codigo_Usuario),
    Vendedor_Razon_Social NVARCHAR(50),
    Vendedor_CUIT NVARCHAR(50)
);


CREATE TABLE [EXEL_ENTES].[Publicacion] (
    Codigo_Publicacion DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Publicacion] PRIMARY KEY (Codigo_Publicacion),
	CONSTRAINT [FK_Publicacion_Codigo_Vendedor] FOREIGN KEY (Codigo_Vendedor) REFERENCES [EXEL_ENTES].[Vendedor](Codigo_Usuario),
    Codigo_Almacen DECIMAL(18, 0),
    Codigo_Vendedor INT,
    Fecha_Inicio DATE,
    Fecha_Fin DATE,
    Stock DECIMAL(18, 0),
    Precio DECIMAL(18, 2)
);

CREATE TABLE [EXEL_ENTES].[Marca] (
    Codigo_Marca INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_Marca] PRIMARY KEY (Codigo_Marca),
    Descripcion NVARCHAR(50) NULL
);

CREATE TABLE [EXEL_ENTES].[Modelo] (
    Codigo_Modelo DECIMAL(18,0)  NOT NULL,
	CONSTRAINT [PK_Modelo] PRIMARY KEY (Codigo_Modelo),
    Descripcion NVARCHAR(50) NULL
);

CREATE TABLE [EXEL_ENTES].[Rubro] ( 
    Codigo_Rubro INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_Rubro] PRIMARY KEY (Codigo_Rubro),
    Descripcion NVARCHAR(50) NULL
);

CREATE TABLE [EXEL_ENTES].[Subrubro] (
    Codigo_Subrubro INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_Subrubro] PRIMARY KEY (Codigo_Subrubro),
    Descripcion NVARCHAR(50) NULL,
	Codigo_Rubro INT NOT NULL,
	CONSTRAINT [FK_Rubro_Codigo_Subrubro] FOREIGN KEY (Codigo_Rubro) REFERENCES [EXEL_ENTES].[Rubro](Codigo_Rubro)
);

CREATE TABLE [EXEL_ENTES].[Producto] (
    Codigo_Producto NVARCHAR(50) NOT NULL ,
	Codigo_Publicacion DECIMAL(18,0) NOT NULL,
	CONSTRAINT [PK_Producto] PRIMARY KEY (Codigo_Producto, Codigo_Publicacion, Codigo_Subrubro),
    CONSTRAINT [FK_Producto_Codigo_Publicacion] FOREIGN KEY (Codigo_Publicacion) REFERENCES [EXEL_ENTES].[Publicacion](Codigo_Publicacion),
	CONSTRAINT [FK_Producto_Codigo_Subrubro] FOREIGN KEY (Codigo_Subrubro) REFERENCES [EXEL_ENTES].[Subrubro](Codigo_Subrubro),
    Codigo_Subrubro INT,
	CONSTRAINT [FK_Publicacion_Codigo_Marca] FOREIGN KEY (Codigo_Marca) REFERENCES [EXEL_ENTES].[Marca](Codigo_Marca),
    Codigo_Marca INT,
    Descripcion NVARCHAR(50),
	CONSTRAINT [FK_Publicacion_Codigo_Modelo] FOREIGN KEY (Codigo_Modelo) REFERENCES [EXEL_ENTES].[Modelo](Codigo_Modelo),
    Codigo_Modelo DECIMAL(18,0)
);

CREATE TABLE [EXEL_ENTES].[Venta] (
    Numero_Venta DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Venta] PRIMARY KEY (Numero_Venta),
    CONSTRAINT [FK_Venta_Codigo_Cliente] FOREIGN KEY (Codigo_Cliente) REFERENCES [EXEL_ENTES].[Cliente](Codigo_Usuario),
    CONSTRAINT [FK_Venta_Codigo_Publicacion] FOREIGN KEY (Codigo_Publicacion) REFERENCES [EXEL_ENTES].[Publicacion](Codigo_Publicacion),
    Codigo_Cliente INT,
    Codigo_Publicacion DECIMAL(18, 0),
    Fecha_Venta DATETIME,
    Total DECIMAL(18, 2)
);

CREATE TABLE [EXEL_ENTES].[Provincia] (
    Codigo_Provincia INT IDENTITY (1,1) NOT NULL,
	CONSTRAINT [PK_Provincia] PRIMARY KEY (Codigo_Provincia),
    Descripcion NVARCHAR(50) NULL
);

CREATE TABLE [EXEL_ENTES].[Localidad] (
    Codigo_Localidad INT IDENTITY(1,1) NOT NULL,
	CONSTRAINT [PK_Localidad] PRIMARY KEY (Codigo_Localidad),
    CONSTRAINT [FK_Localidad_Provincia] FOREIGN KEY (Codigo_Provincia) REFERENCES [EXEL_ENTES].[Provincia](Codigo_Provincia),
    Descripcion NVARCHAR(50) NULL,
    Codigo_Provincia  INT NOT NULL
);

CREATE TABLE [EXEL_ENTES].[Almacen] (
    Codigo_Almacen DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Almacen] PRIMARY KEY (Codigo_Almacen),
    Calle NVARCHAR(50) NULL,
    Numero DECIMAL(18, 0) NULL,
    Costo DECIMAL(18, 2) NULL,
	CONSTRAINT [FK_Almacen_Provincia] FOREIGN KEY (Codigo_Provincia) REFERENCES [EXEL_ENTES].[Provincia](Codigo_Provincia),
	CONSTRAINT [FK_Almacen_Localidad] FOREIGN KEY (Codigo_Localidad) REFERENCES [EXEL_ENTES].[Localidad](Codigo_Localidad),
    Codigo_Localidad INT,
	Codigo_Provincia INT
);

CREATE TABLE [EXEL_ENTES].[Factura] (
    Numero_Factura DECIMAL(18, 0) NOT NULL,
	CONSTRAINT [PK_Factura] PRIMARY KEY (Numero_Factura),
    CONSTRAINT [FK_Factura_Codigo_Vendedor] FOREIGN KEY (Codigo_Vendedor) REFERENCES [EXEL_ENTES].[Vendedor](Codigo_Usuario),
    CONSTRAINT [FK_Factura_Codigo_Cliente] FOREIGN KEY (Codigo_Cliente) REFERENCES [EXEL_ENTES].[Cliente](Codigo_Usuario),
    Codigo_Vendedor INT NULL,
    Codigo_Cliente INT NULL,
    Fecha_Factura DATE NULL,
    Total DECIMAL(18, 2) NULL
);

CREATE TABLE [EXEL_ENTES].[TipoMedioDePago] (
    Tipo_Medio_Pago_Codigo INT IDENTITY(1,1) NOT NULL,
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
    CONSTRAINT [FK_Pago_Codigo_Cliente] FOREIGN KEY (Codigo_Cliente) REFERENCES [EXEL_ENTES].[Cliente](Codigo_Usuario), 
    CONSTRAINT [FK_Pago_Codigo_MedioPago] FOREIGN KEY (Codigo_MedioPago) REFERENCES [EXEL_ENTES].[MedioDePago](Codigo_MedioPago),    
	Codigo_Numero_Venta DECIMAL(18, 0) NOT NULL,
    Codigo_Cliente INT NOT NULL, 
	Codigo_MedioPago INT NOT NULL,
    Importe DECIMAL(18, 2) NOT NULL,
    Fecha DATE NULL
);

CREATE TABLE [EXEL_ENTES].[Detalle_Pago] (
    CONSTRAINT [FK_Nro_Pago] FOREIGN KEY (Nro_Pago) REFERENCES [EXEL_ENTES].[Pago](Numero_Pago),
    Nro_Pago INT NOT NULL,
    CONSTRAINT [FK_Codigo_Cliente] FOREIGN KEY (Codigo_Cliente) REFERENCES [EXEL_ENTES].[Cliente](Codigo_Usuario), 
	CONSTRAINT [FK_Codigo_MedioPago] FOREIGN KEY (Codigo_MedioPago) REFERENCES [EXEL_ENTES].[MedioDePago](Codigo_MedioPago),
	Codigo_MedioPago INT,
    Fecha_Vencimiento_Tarjeta DATE NULL,
	Codigo_Cliente INT NOT NULL,
    Cuotas DECIMAL(18, 2) NULL,
    Nro_Tarjeta NVARCHAR(50) NULL
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
    Nro_Envio INT IDENTITY(1,1) NOT NULL,
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

CREATE TABLE [EXEL_ENTES].[Detalle_Factura] (
    CONSTRAINT [FK_Detalle_Factura_Nro_Factura] FOREIGN KEY (Nro_Factura) REFERENCES [EXEL_ENTES].[Factura](Numero_Factura),
    CONSTRAINT [FK_Detalle_Factura_Cod_Publicacion] FOREIGN KEY (Codigo_Publicacion) REFERENCES [EXEL_ENTES].[Publicacion](Codigo_Publicacion),
    Nro_Factura DECIMAL(18, 0) NOT NULL,
    Codigo_Publicacion DECIMAL(18, 0) NOT NULL,
	Tipo NVARCHAR(50),
    Cantidad DECIMAL(18, 0) NOT NULL,
    Precio DECIMAL(18, 2) NOT NULL,
	Subtotal DECIMAL(18, 2) NOT NULL
);


--============================================================================================================================
--    Creacion de stored procedures
--============================================================================================================================
-- Dropeo de procedures

IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_usuario')
	DROP PROCEDURE [EXEL_ENTES].migrar_usuario;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_cliente')
    DROP PROCEDURE [EXEL_ENTES].migrar_cliente;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_vendedor')
    DROP PROCEDURE [EXEL_ENTES].migrar_vendedor;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_publicacion') 
    DROP PROCEDURE [EXEL_ENTES].migrar_publicacion;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_rubro')
    DROP PROCEDURE [EXEL_ENTES].migrar_rubro;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_subrubro')  
    DROP PROCEDURE [EXEL_ENTES].migrar_subrubro;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_marca')
    DROP PROCEDURE [EXEL_ENTES].migrar_marca;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_modelo')
    DROP PROCEDURE [EXEL_ENTES].migrar_modelo;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_producto')  
    DROP PROCEDURE [EXEL_ENTES].migrar_producto;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_venta')
    DROP PROCEDURE [EXEL_ENTES].migrar_venta;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_factura')
    DROP PROCEDURE [EXEL_ENTES].migrar_factura;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_medio_pago')  
    DROP PROCEDURE [EXEL_ENTES].migrar_medio_pago;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_pago')
    DROP PROCEDURE [EXEL_ENTES].migrar_pago;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_provincia')  
    DROP PROCEDURE [EXEL_ENTES].migrar_provincia;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_localidad')
    DROP PROCEDURE [EXEL_ENTES].migrar_localidad;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_almacen')  
    DROP PROCEDURE [EXEL_ENTES].migrar_almacen;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_tipo_envio')  
    DROP PROCEDURE [EXEL_ENTES].migrar_tipo_envio;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_envio') 
    DROP PROCEDURE [EXEL_ENTES].migrar_envio;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_tipo_medio_pago')  
    DROP PROCEDURE [EXEL_ENTES].migrar_tipo_medio_pago;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_detalle_venta')
    DROP PROCEDURE [EXEL_ENTES].migrar_detalle_venta;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_detalle_factura')
    DROP PROCEDURE [EXEL_ENTES].migrar_detalle_factura;
IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'migrar_detalle_pago')
    DROP PROCEDURE [EXEL_ENTES].migrar_detalle_pago;

--    Creamos los procedures

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_usuario
AS
BEGIN
    -- Inserta los datos combinados de CLI_USUARIO y VEN_USUARIO en la tabla Usuario
    INSERT INTO [EXEL_ENTES].[Usuario] (Nombre, Pass, Fecha_Creacion, Domicilio_Calle, Domicilio_Nro_Calle, Domicilio_Piso, Domicilio_Depto, Domicilio_CP, Domicilio_Localidad, Domicilio_Provincia, Mail)
    SELECT DISTINCT 
        CLI_USUARIO_NOMBRE as Nombre, 
        CLI_USUARIO_PASS as Pass, 
        CLI_USUARIO_FECHA_CREACION as Fecha_Creacion, 
        CLI_USUARIO_DOMICILIO_CALLE as Domicilio_Calle, 
        CLI_USUARIO_DOMICILIO_NRO_CALLE as Domicilio_Nro_Calle, 
        CLI_USUARIO_DOMICILIO_PISO as Domicilio_Piso, 
        CLI_USUARIO_DOMICILIO_DEPTO as Domicilio_Depto,
		CLI_USUARIO_DOMICILIO_CP as Domicilio_CP,
		CLI_USUARIO_DOMICILIO_LOCALIDAD as Domicilio_Localidad,
		CLI_USUARIO_DOMICILIO_PROVINCIA as Domicilio_Provincia,
		CLIENTE_MAIL as Mail
    FROM gd_esquema.Maestra
    WHERE CLI_USUARIO_NOMBRE IS NOT NULL

    UNION 

    SELECT DISTINCT 
        VEN_USUARIO_NOMBRE as Nombre, 
        VEN_USUARIO_PASS as Pass, 
        VEN_USUARIO_FECHA_CREACION as Fecha_Creacion, 
        VEN_USUARIO_DOMICILIO_CALLE as Domicilio_Calle, 
        VEN_USUARIO_DOMICILIO_NRO_CALLE as Domicilio_Nro_Calle, 
        VEN_USUARIO_DOMICILIO_PISO as Domicilio_Piso, 
        VEN_USUARIO_DOMICILIO_DEPTO as Domicilio_Depto,
		VEN_USUARIO_DOMICILIO_CP as Domicilio_CP,
		VEN_USUARIO_DOMICILIO_LOCALIDAD as Domicilio_Localidad,
		VEN_USUARIO_DOMICILIO_PROVINCIA as Domicilio_Provincia,
		VENDEDOR_MAIL as Mail
    FROM gd_esquema.Maestra
    WHERE VEN_USUARIO_NOMBRE IS NOT NULL
    ORDER BY Nombre ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_cliente
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Cliente] (Codigo_Usuario, Cliente_Nombre, Cliente_Apellido, Cliente_DNI, Cliente_Fecha_Nac)
    SELECT DISTINCT Codigo_Usuario, CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DNI, CLIENTE_FECHA_NAC
    FROM gd_esquema.Maestra maes
	join EXEL_ENTES.Usuario usu on usu.Mail = maes.CLIENTE_MAIL and usu.Fecha_Creacion = maes.CLI_USUARIO_FECHA_CREACION 
	WHERE CLIENTE_NOMBRE IS NOT NULL
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_vendedor
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Vendedor] (Codigo_Usuario, Vendedor_Razon_Social, Vendedor_CUIT)
    SELECT DISTINCT Codigo_Usuario, VENDEDOR_RAZON_SOCIAL, VENDEDOR_CUIT
    FROM gd_esquema.Maestra maes
	join EXEL_ENTES.Usuario usu on usu.Mail = maes.VENDEDOR_MAIL and usu.Fecha_Creacion = maes.VEN_USUARIO_FECHA_CREACION
	where maes.VENDEDOR_RAZON_SOCIAL is not null
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_publicacion
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Publicacion] (Codigo_Publicacion, Codigo_Almacen, Codigo_Vendedor , Fecha_Inicio, Fecha_Fin, Stock, Precio)
    SELECT DISTINCT PUBLICACION_CODIGO, ALMACEN_CODIGO, ven.Codigo_Usuario , PUBLICACION_FECHA, PUBLICACION_FECHA_V, PUBLICACION_STOCK, PUBLICACION_PRECIO
    FROM gd_esquema.Maestra maes
	join EXEL_ENTES.Vendedor ven on ven.Vendedor_Razon_Social = maes.VENDEDOR_RAZON_SOCIAL and ven.Vendedor_CUIT = maes.VENDEDOR_CUIT
    WHERE PUBLICACION_CODIGO IS NOT NULL
    ORDER BY PUBLICACION_CODIGO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_rubro
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Rubro] (Descripcion)
    SELECT DISTINCT PRODUCTO_RUBRO_DESCRIPCION
    FROM gd_esquema.Maestra
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_subrubro
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Subrubro] (Codigo_Rubro, Descripcion)
    SELECT DISTINCT rub.Codigo_Rubro, PRODUCTO_SUB_RUBRO
    FROM gd_esquema.Maestra maes
	join EXEL_ENTES.Rubro rub on
			maes.PRODUCTO_RUBRO_DESCRIPCION = rub.Descripcion
    WHERE PRODUCTO_SUB_RUBRO IS NOT NULL
    ORDER BY maes.PRODUCTO_SUB_RUBRO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_marca
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Marca] (Descripcion) -- , Descripcion)   No existe una descripcion como tal TENEMOS QUE REVISAR EL DER
    SELECT DISTINCT PRODUCTO_MARCA -- PRODUCTO_MARCA_DESCRIPCION
    FROM gd_esquema.Maestra
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_modelo
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Modelo] (Codigo_Modelo, Descripcion)
    SELECT DISTINCT PRODUCTO_MOD_CODIGO , PRODUCTO_MOD_DESCRIPCION
    FROM gd_esquema.Maestra
	WHERE PRODUCTO_MOD_CODIGO is not null
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO

CREATE PROCEDURE [EXEL_ENTES].migrar_producto
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Producto] (Codigo_Producto, Codigo_Publicacion, Codigo_Subrubro, Descripcion, Codigo_Marca, Codigo_Modelo)
    SELECT DISTINCT PRODUCTO_CODIGO, PUBLICACION_CODIGO, sub.Codigo_Subrubro, PRODUCTO_DESCRIPCION, marca.Codigo_Marca, PRODUCTO_MOD_CODIGO
    FROM gd_esquema.Maestra maes
	join EXEL_ENTES.Subrubro sub on
		maes.PRODUCTO_SUB_RUBRO = sub.Descripcion
	join EXEL_ENTES.Marca marca on
		maes.PRODUCTO_MARCA = marca.Descripcion
    WHERE maes.PRODUCTO_CODIGO IS NOT NULL
END
GO

------------------------------------------------------------------------------------------------------------------------------

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

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_factura
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Factura] (Numero_Factura, Fecha_Factura, Total, Codigo_Cliente, Codigo_Vendedor)
    SELECT DISTINCT FACTURA_NUMERO, FACTURA_FECHA, FACTURA_TOTAL,
			(
				select top 1 (
						select top 1 usu2.Codigo_Usuario from EXEL_ENTES.Usuario usu2 
						where usu2.Mail = maes1.CLIENTE_MAIL
				)
				from gd_esquema.Maestra maes1 
				where maes1.PUBLICACION_CODIGO = maes.PUBLICACION_CODIGO
			) as Codigo_Cliente,
			(
				select top 1 pub.Codigo_Vendedor
				from EXEL_ENTES.Publicacion pub
				where pub.Codigo_Publicacion = maes.PUBLICACION_CODIGO
			) as Codigo_Vendedor
    FROM gd_esquema.Maestra maes
	WHERE FACTURA_NUMERO IS NOT NULL
    ORDER BY FACTURA_NUMERO ASC;
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_medio_pago
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[MedioDePago] (Descripcion_medio_pago)
    SELECT DISTINCT PAGO_MEDIO_PAGO
    FROM gd_esquema.Maestra
END
GO


------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_pago
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Pago] (Codigo_Cliente, Codigo_Numero_Venta, Importe, Fecha, Codigo_MedioPago)
    SELECT DISTINCT clie.Codigo_Usuario, VENTA_CODIGO, PAGO_IMPORTE, PAGO_FECHA, mediopago.Codigo_MedioPago
    FROM gd_esquema.Maestra maes
	join EXEL_ENTES.Cliente clie on
			clie.Cliente_Apellido = maes.CLIENTE_APELLIDO and
			clie.Cliente_Nombre = maes.CLIENTE_NOMBRE and
			clie.Cliente_DNI = maes.CLIENTE_DNI
	join EXEL_ENTES.MedioDePago mediopago on
		maes.PAGO_MEDIO_PAGO = mediopago.Descripcion_medio_pago
	where maes.VENTA_CODIGO is not null
	order by clie.Codigo_Usuario asc
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_provincia
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Provincia] (Descripcion)
    SELECT DISTINCT CLI_USUARIO_DOMICILIO_PROVINCIA
    FROM gd_esquema.Maestra
    WHERE CLI_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL  
    ORDER BY CLI_USUARIO_DOMICILIO_PROVINCIA ASC;
END
GO


------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_localidad
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Localidad] (Codigo_Provincia, Descripcion)
    SELECT DISTINCT prov.Codigo_Provincia , ALMACEN_Localidad
    FROM gd_esquema.Maestra maes
	JOIN EXEL_ENTES.Provincia prov on
			maes.ALMACEN_PROVINCIA = prov.Descripcion
    WHERE maes.ALMACEN_PROVINCIA IS NOT NULL
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_almacen
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Almacen] (Codigo_Almacen, Calle, Numero, Costo, Codigo_Localidad, Codigo_Provincia)
    SELECT DISTINCT ALMACEN_CODIGO, ALMACEN_CALLE, ALMACEN_NRO_CALLE, ALMACEN_COSTO_DIA_AL, loc.Codigo_Localidad, prov.Codigo_Provincia
    FROM gd_esquema.Maestra maes
	join EXEL_ENTES.Localidad loc on
			maes.ALMACEN_Localidad = loc.Descripcion
	join EXEL_ENTES.Provincia prov on
			maes.ALMACEN_PROVINCIA = prov.Descripcion
    WHERE ALMACEN_CODIGO IS NOT NULL
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_tipo_envio
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[TipoEnvio] (Descripcion)
    SELECT DISTINCT ENVIO_TIPO
    FROM gd_esquema.Maestra
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_envio
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Envio] (Nro_Venta, Fecha_Programada, Hora_inicio, Hora_fin_inicio, Fecha_Entrega, Costo_Envio, Tipo_Envio)
    SELECT DISTINCT ven.Numero_Venta, ENVIO_FECHA_PROGAMADA, ENVIO_HORA_INICIO, ENVIO_HORA_FIN_INICIO, ENVIO_FECHA_ENTREGA, ENVIO_COSTO, tipoenv.Codigo_TipoEnvio
    FROM gd_esquema.Maestra maes
	join EXEL_ENTES.Venta ven on 
			ven.Numero_Venta = maes.VENTA_CODIGO
	join EXEL_ENTES.TipoEnvio tipoenv on
			tipoenv.Descripcion = maes.ENVIO_TIPO
	where VENTA_CODIGO is not null
END
GO

------------------------------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_tipo_medio_pago
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[TipoMedioDePago] (Descripcion_tipo_medio_de_pago)
    SELECT DISTINCT PAGO_TIPO_MEDIO_PAGO
    FROM gd_esquema.Maestra
    WHERE PAGO_TIPO_MEDIO_PAGO IS NOT NULL
END
GO

-------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_detalle_venta
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Detalle_Venta] (Numero_Venta, Codigo_Publicacion, Cantidad, Precio, Subtotal)
    SELECT DISTINCT 
        VENTA_CODIGO, 
        PUBLICACION_CODIGO, 
        VENTA_DET_CANT, 
        VENTA_DET_PRECIO,
		VENTA_DET_SUB_TOTAL
    FROM 
        gd_esquema.Maestra
    WHERE 
        VENTA_CODIGO IS NOT NULL 
        AND PUBLICACION_CODIGO IS NOT NULL
    ORDER BY 
        VENTA_CODIGO ASC;
END
GO

-------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_detalle_factura
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Detalle_Factura] (Nro_Factura, Codigo_Publicacion, Tipo, Cantidad, Precio, Subtotal)
    SELECT DISTINCT FACTURA_NUMERO, PUBLICACION_CODIGO, FACTURA_DET_TIPO, FACTURA_DET_CANTIDAD, FACTURA_DET_PRECIO, FACTURA_DET_SUBTOTAL
    FROM gd_esquema.Maestra
    WHERE FACTURA_DET_PRECIO IS NOT NULL
END
GO

-------------------------------------------------------------------------------------------------------

GO
CREATE PROCEDURE [EXEL_ENTES].migrar_detalle_pago
AS
BEGIN
    INSERT INTO [EXEL_ENTES].[Detalle_Pago] (Nro_Pago, Codigo_Cliente, Codigo_MedioPago ,Fecha_Vencimiento_Tarjeta, Cuotas, Nro_Tarjeta)
    SELECT DISTINCT pag.Numero_Pago, clie.Codigo_Usuario, pag.Codigo_MedioPago , PAGO_FECHA_VENC_TARJETA, PAGO_CANT_CUOTAS, PAGO_NRO_TARJETA
    FROM gd_esquema.Maestra maes
	join EXEL_ENTES.Cliente clie on
			clie.Cliente_DNI = maes.CLIENTE_DNI
	join EXEL_ENTES.Pago pag on
			clie.Codigo_Usuario = pag.Codigo_Cliente 
    WHERE PAGO_NRO_TARJETA IS NOT NULL
END
GO

/*--------------------------------FIN DE EJECUCION DE STORED PROCEDURES: MIGRACION------------------------- -------*/
BEGIN TRANSACTION
BEGIN TRY
    -- Ejecutamos los stored procedures para migrar cada una de las tablas
    EXECUTE [EXEL_ENTES].migrar_usuario;
    EXECUTE [EXEL_ENTES].migrar_cliente;
    EXECUTE [EXEL_ENTES].migrar_vendedor;
    EXECUTE [EXEL_ENTES].migrar_publicacion;
    EXECUTE [EXEL_ENTES].migrar_rubro;
    EXECUTE [EXEL_ENTES].migrar_subrubro;
    EXECUTE [EXEL_ENTES].migrar_marca;
    EXECUTE [EXEL_ENTES].migrar_modelo;
    EXECUTE [EXEL_ENTES].migrar_producto;
    EXECUTE [EXEL_ENTES].migrar_venta;
    EXECUTE [EXEL_ENTES].migrar_factura;
    EXECUTE [EXEL_ENTES].migrar_medio_pago;
    EXECUTE [EXEL_ENTES].migrar_pago;
    EXECUTE [EXEL_ENTES].migrar_provincia;
    EXECUTE [EXEL_ENTES].migrar_localidad;
    EXECUTE [EXEL_ENTES].migrar_almacen;
    EXECUTE [EXEL_ENTES].migrar_tipo_envio;
    EXECUTE [EXEL_ENTES].migrar_envio;
    EXECUTE [EXEL_ENTES].migrar_tipo_medio_pago;
    EXECUTE [EXEL_ENTES].migrar_detalle_venta;
    EXECUTE [EXEL_ENTES].migrar_detalle_factura;
    EXECUTE [EXEL_ENTES].migrar_detalle_pago;


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