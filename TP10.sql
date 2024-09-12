
/*
TODOS LOS DATOS ESTAN DESORGANIZADOS Y DESNORMALIZADOS. 
Primero, tenemos que ordenar las tablas y luego normalizarlas
-- Reorganizar Tabla Maestra según:

Gestión de Publicaciones:
-Código de Publicación
-Descripcion de la publicacion
-Fecha de inicio
-Producto Publicado
-Stock
-Precio
-Vendedor
-Almacen
-Costo de publicacion
-Porcentaje por venta

Gestión de Ventas:
- Nro. de venta: Identificador único de cada venta
- Cliente: se registra el usuario correspondiente al cliente que hizo la compra.
	Tener en cuenta que los usuarios pueden ser clientes y/o vendedores. En el caso
	de los vendedores se registran datos adicionales como: nombre y apellido, fecha de nacimiento, DNI, etc.
- Fecha y Hora: Fecha y hora en que se realiza la venta.
- Detalle de la venta:
	- Publicación: Publicación a partir de la cual se genera la venta.
	- Precio: precio al cual se realizó la venta del producto de la publicación.
	- Cantidad: Cantidad del producto que se vendió.
	- Subtotal: Cantidad del producto que se vendió.
- Total

Gestión de Envíos:
- Nro de Envío: Identificador único de cada envío.
- Nro. de Venta: nro. de la venta a la cual está asociada el envío.
- Domicilio de envío. El usuario cliente tiene asociados uno o varios domicilios, previamente dados de alta. Al momento de la compra elige uno de ellos para recibir la compra.
- Fecha Programada: Fecha programada para el envío
- Horario de inicio: Horario de inicio del rango programado en el cuál se realizará el envío.
- Horario de fin: Horario de fin del rango programado en el cuál se realizará elenvío.
- Costo envio
- Fecha/Hora de entrega: Fecha y hora en que efectivamente se entregó el envío.
- Tipo de envío.

Gestion de Pagos:
-Nro de Pago: Identificador único de cada pago.
- Nro. de Venta: nro. de la venta a la cual está asociada el pago.
- Medio de Pago: Medio de Pago a través del cual se realiza el mismo. El sistema
	tiene previamente cargados todos los medios de pago habilitados (por ejemplo
	Tarjeta Banco Patagonia Crédito Visa).
- Detalle Pago Para los pagos que se realicen con tarjeta se guarda además detalle
	del pago con la siguiente información:
		- Nro Tarjeta
		- Fecha de Vencimiento de tarjeta
		- Cuotas
- Importe:


Facturación Marketplace:
- NroFactura: Identificador único de la factura
- Fecha de la factura: fecha de emisión de la misma.
- Usuario. Usuario al cual se le emite la factura.
- Detalle de la factura. En el detalle de la factura se registran los ítems o
	conceptos comprendidos dentro de la misma, como el costo de publicación y el
	importe por ventas. Entre la información que se registra se incluye:
		- Publicación: a la cual se asocian los costos.
		- Concepto: al cual pertenece el costo (costo de publicación, % por ventas, etc). Los mismos se encuentran previamente dados de alta en el sistema.
		- Cantidad. Cantidad sobre la cual aplican los costos, por ejemplo en el caso de % ventas será la cantidad de ventas.
		- Precio. Precio unitario del concepto.
- Total



*/

CREATE TABLE Publicaciones (
    Codigo_Publicacion DECIMAL(18, 0) PRIMARY KEY,
    Descripcion NVARCHAR(50),
    Fecha_Inicio DATE,
    Producto_Codigo NVARCHAR(50),
    Stock DECIMAL(18, 0),
    Precio DECIMAL(18, 2),
    Vendedor_CUIT NVARCHAR(50),
    Almacen_Codigo DECIMAL(18, 0),
    Costo_Publicacion DECIMAL(18, 2),
    Porcentaje_Venta DECIMAL(18, 2),
    CONSTRAINT FK_Vendedor FOREIGN KEY (Vendedor_CUIT) REFERENCES Vendedores(CUIT),
    CONSTRAINT FK_Almacen FOREIGN KEY (Almacen_Codigo) REFERENCES Almacenes(Codigo)
);

CREATE TABLE Ventas (
    Nro_Venta DECIMAL(18, 0) PRIMARY KEY,
    Cliente_DNI DECIMAL(18, 0),
    Fecha_Hora DATETIME,
    Publicacion_Codigo DECIMAL(18, 0),
    Precio DECIMAL(18, 2),
    Cantidad DECIMAL(18, 0),
    Subtotal DECIMAL(18, 2),
    Total DECIMAL(18, 2),
    CONSTRAINT FK_Cliente FOREIGN KEY (Cliente_DNI) REFERENCES Clientes(DNI),
    CONSTRAINT FK_Publicacion FOREIGN KEY (Publicacion_Codigo) REFERENCES Publicaciones(Codigo_Publicacion)
);

CREATE TABLE Envios (
    Nro_Envio DECIMAL(18, 0) PRIMARY KEY,
    Nro_Venta DECIMAL(18, 0),
    Domicilio_Envio NVARCHAR(100),
    Fecha_Programada DATE,
    Hora_Inicio DECIMAL(18, 0),
    Hora_Fin DECIMAL(18, 0),
    Costo_Envio DECIMAL(18, 2),
    Fecha_Entrega DATETIME,
    Tipo_Envio NVARCHAR(50),
    CONSTRAINT FK_Venta FOREIGN KEY (Nro_Venta) REFERENCES Ventas(Nro_Venta)
);

CREATE TABLE Pagos (
    Nro_Pago DECIMAL(18, 0) PRIMARY KEY,
    Nro_Venta DECIMAL(18, 0),
    Medio_Pago NVARCHAR(50),
    Nro_Tarjeta NVARCHAR(50),
    Fecha_Vencimiento_Tarjeta DATE,
    Cuotas DECIMAL(18, 0),
    Importe DECIMAL(18, 2),
    CONSTRAINT FK_Venta FOREIGN KEY (Nro_Venta) REFERENCES Ventas(Nro_Venta)
);

CREATE TABLE Facturacion (
    Nro_Factura DECIMAL(18, 0) PRIMARY KEY,
    Fecha_Factura DATE,
    Usuario_CUIT NVARCHAR(50),
    Total DECIMAL(18, 2),
    CONSTRAINT FK_Usuario FOREIGN KEY (Usuario_CUIT) REFERENCES Vendedores(CUIT)
);

CREATE TABLE Detalle_Factura (
    Nro_Factura DECIMAL(18, 0),
    Publicacion_Codigo DECIMAL(18, 0),
    Concepto NVARCHAR(50),
    Cantidad DECIMAL(18, 0),
    Precio DECIMAL(18, 2),
    Subtotal DECIMAL(18, 2),
    CONSTRAINT FK_Factura FOREIGN KEY (Nro_Factura) REFERENCES Facturacion(Nro_Factura),
    CONSTRAINT FK_Publicacion FOREIGN KEY (Publicacion_Codigo) REFERENCES Publicaciones(Codigo_Publicacion)
);

CREATE TABLE Clientes (
    DNI DECIMAL(18, 0) PRIMARY KEY,
    Nombre NVARCHAR(50),
    Apellido NVARCHAR(50),
    Fecha_Nacimiento DATE,
    Email NVARCHAR(50),
    Usuario NVARCHAR(50),
    Password NVARCHAR(50),
    Fecha_Creacion DATE,
    Domicilio NVARCHAR(100)
);

CREATE TABLE Vendedores (
    CUIT NVARCHAR(50) PRIMARY KEY,
    Razon_Social NVARCHAR(50),
    Email NVARCHAR(50),
    Usuario NVARCHAR(50),
    Password NVARCHAR(50),
    Fecha_Creacion DATE,
    Domicilio NVARCHAR(100)
);

CREATE TABLE Almacenes (
    Codigo DECIMAL(18, 0) PRIMARY KEY,
    Calle NVARCHAR(50),
    Numero DECIMAL(18, 0),
    Costo_Dia DECIMAL(18, 2),
    Localidad NVARCHAR(50),
    Provincia NVARCHAR(50)
);
