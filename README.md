# Gestión de Datos
Este trabajo práctico, denominado **Marketplace**, para la materia Gestión de Datos (UTN.BA), consiste en el diseño, migración y análisis de una plataforma que conecta vendedores y clientes. El objetivo central es transformar una base de datos desnormalizada en un sistema transaccional eficiente y, posteriormente, en un modelo de inteligencia de negocios (BI).

### Arquitectura y Alcance del Proyecto
El desarrollo se divide en dos grandes etapas técnicas que deben ejecutarse exclusivamente mediante T-SQL en SQL Server 2019:

Modelo Transaccional (Relacional):
 - **Normalización**: Se debe analizar una "tabla maestra" única y desorganizada para diseñar un nuevo modelo que cumpla con las formas normales.
 - **Estructura**: Incluye la creación de tablas, claves primarias/foráneas, constraints, triggers e índices para optimizar el acceso.
 - **Migración**: Implementación de Stored Procedures para trasladar los datos originales al nuevo esquema sin inventar información.


Modelo de Inteligencia de Negocios (BI):
 - **Modelo Dimensional**: Creación de un esquema (estrella o copo de nieve) con dimensiones como Tiempo, Ubicación, Rango Etario y Rubros.
 - **Indicadores de Gestión**: Desarrollo de 10 vistas específicas que resuelven consultas complejas, como el promedio de tiempo de publicaciones, rendimiento de rubros y porcentaje de cumplimiento de envíos.

   
Funcionalidades del Sistema
El sistema debe gestionar el ciclo completo de un Marketplace, abordando los siguientes módulos:
 - **Publicaciones**: Registro de productos, stock, costos fijos y porcentajes por venta.
 - **Ventas**: Gestión de transacciones entre clientes y vendedores.
 - **Envíos**: Seguimiento de domicilios, costos, tipos de envío y fechas de entrega.
 - **Pagos**: Registro de medios de pago y detalles de cuotas para tarjetas.
 - **Facturación**: Emisión de facturas a vendedores por costos de publicación e importes de venta.


# Programa de la materia "Gestión de Datos"
### Programa Sintético
- Bases de Datos: Conceptos básicos, arquitectura, componentes.

- Sistemas de Archivos.

- Modelos Conceptuales Básicos (Jerárquico, Red, Relacional, Objetos)

- Seguridad, Privacidad y Concurrencia.

- Modelos Conceptuales de Datos.

- Álgebra y Cálculo Relacional.

- Lenguajes de Definición y Manipulación de Datos (SQL, QBE)

- Normalización.

- Integridad de Datos, transacciones

### Programa Analítico

**UNIDAD TEMATICA 1: ESTRUCTURAS DE DATOS**

Concepto de Nodo y Relación. Relaciones Algebraicas. Tipos de Relaciones. Grafos. Grafos restríctos e irrestrictos. Representación de grafos. Matriz de Adyacencia. Estructura de Pfaultz. Estructura de Graal. Álgebra relacional. Concepto de paso y camino. Algoritmos de búsqueda de paso. Estructuras de datos básicas. Pilas, colas, listas, arboles. Aplicaciones. Representación computacional de las estructuras de datos. Representación estática. Representación dinámica.

**UNIDAD TEMATICA 2: MANIPULACION DE DATOS**

Algoritmos de Clasificación. Algoritmos de Búsqueda. Métodos de Ordenamiento. Arboles Binarios. Árboles n-arios. Árbol B. Hashing. Algoritmos de Compactación. Algoritmos de encriptamiento de datos.

**UNIDAD TEMATICA 3: DISEÑO DE DATOS**

Modelo Semántico. Análisis de Datos. Modelo de Datos. Entidad-Relación. Identificadores y atributos. Definición de claves. Redundancia y consistencia. Dependencia Funcional. Normalización de Datos. Arquitectura de Datos. Nivel externo. Nivel conceptual. Nivel interno. Concepto Cliente Servidor. Modelo de Objetos. Propiedades de los Objetos. Análisis de Datos Orientado a Objetos.

**UNIDAD TEMATICA 4: BASES DE DATOS**

Concepto de Base de Datos. Tipos de Bases de Datos. Modelo en Red (IDMS). Modelo Jerárquico (IMS). Modelo de lista invertida (DATACOM/DB). Modelo Relacional. Modelo orientado a objetos. Concepto de SQL. Concepto de PL-SQL. Recuperación y Concurrencia, Seguridad e integridad de los datos. Aplicaciones con SQL y PL-SQL.

# Mi Wiki
### Teoría
- https://www.notion.so/Apunte-te-rico-143a4de292cf80debe46f2e6c519611e?source=copy_link
### Práctica
- https://www.notion.so/GDD-Apunte-14ba4de292cf8065a793d571ae289a44
