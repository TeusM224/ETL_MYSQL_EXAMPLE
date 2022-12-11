use henry_m3;

												-- Normalización

	-- Cambio nombre de campos de las tablas:

alter table calendario change id IdFecha int not null; /*alter table cliente rename column id to IdFecha;*/
alter table cliente change ID IdCliente int not null;
alter table empleado change IDEmpleado IdEmpleado int not null;
alter table proveedor change IDProveedor IdProveedor int not null;
alter table sucursal change ID IdSucursal int not null;
alter table tipo_gasto change Descripcion Tipo_Gasto varchar(100) character set utf8mb4 collate utf8mb4_spanish_ci NOT NULL;
alter table producto change IdProdcuto IdProducto int not null;
alter table producto change Concepto Producto varchar(100) character set utf8mb4 collate utf8mb4_spanish_ci not null;

	-- Cambio de nombres y tipos de datos
-- cliente

alter table cliente rename column X to Longitud;
alter table cliente rename column Y to Latitud;

UPDATE cliente SET Latitud = REPLACE(Latitud,',','.');
UPDATE cliente SET Longitud = REPLACE(Longitud,',','.');

update cliente SET Latitud = '0' WHERE Latitud = '';
update cliente SET Longitud = '0' WHERE Longitud = '';

alter table cliente change column Latitud Latitud decimal(13,10);
alter table cliente change Longitud Longitud decimal(13,10);

alter table cliente drop col10;
/*
ALTER TABLE `cliente` 	ADD `Latitud` DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER `Y`, 
						ADD `Longitud` DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER `Latitud`;
UPDATE cliente SET Y = '0' WHERE Y = '';
UPDATE cliente SET X = '0' WHERE X = '';
UPDATE `cliente` SET Latitud = REPLACE(Y,',','.');
UPDATE `cliente` SET Longitud = REPLACE(X,',','.');
SELECT * FROM `cliente`;
ALTER TABLE `cliente` DROP `Y`;
ALTER TABLE `cliente` DROP `X`; */

-- Empleado

alter table empleado drop Salario;

alter table empleado add Salario decimal(10,2) not null default '0' after Salario2;
update empleado set Salario = replace(Salario2,',','.');
alter table empleado drop Salario2;

-- Compra

update compra set Precio = replace(Precio,',','.');

-- select distinct precio from compra where precio=''; verifica si hay duplicados
-- update compra set Precio = '0' where Precio = ''; si hubieran duplicados se usa esto

-- Producto

update producto set Precio = replace(Precio,',','.');

-- Sucursal

alter table sucursal add Latitud decimal(13,10) not null default'0' after Latitud2,
					 add Longitud decimal (13,10) not null default '0' after Longitud2;
update sucursal set Latitud = replace(Latitud2,',','.');
update sucursal set Longitud = replace(Longitud2,',','.');
alter table sucursal drop Latitud2;
alter table sucursal drop Longitud2;

-- Venta
update venta set Precio = 0 where Precio='';
alter table venta change Precio Precio  decimal(15,3) not null; -- default '0';

SELECT * FROM henry_m3.venta order by Precio asc; -- retorna la tabla venta ordenada de forma ascendente segun los valores de precio


							/*Imputar Valores Faltantes*/

UPDATE cliente SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE cliente SET Localidad = 'Sin Dato' WHERE TRIM(Localidad) = "" OR ISNULL(Localidad);
UPDATE cliente SET Nombre_y_Apellido = 'Sin Dato' WHERE TRIM(Nombre_y_Apellido) = "" OR ISNULL(Nombre_y_Apellido);
UPDATE cliente SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);

UPDATE empleado SET Apellido = 'Sin Dato' WHERE TRIM(Apellido) = "" OR ISNULL(Apellido);
UPDATE empleado SET Nombre = 'Sin Dato' WHERE TRIM(Nombre) = "" OR ISNULL(Nombre);
UPDATE empleado SET Sucursal = 'Sin Dato' WHERE TRIM(Sucursal) = "" OR ISNULL(Sucursal);
UPDATE empleado SET Sector = 'Sin Dato' WHERE TRIM(Sector) = "" OR ISNULL(Sector);
UPDATE empleado SET Cargo = 'Sin Dato' WHERE TRIM(Cargo) = "" OR ISNULL(Cargo);

UPDATE producto SET Producto = 'Sin Dato' WHERE TRIM(Producto) = "" OR ISNULL(Producto);
UPDATE producto SET Tipo = 'Sin Dato' WHERE TRIM(Tipo) = "" OR ISNULL(Tipo);

UPDATE proveedor SET Nombre = 'Sin Dato' WHERE TRIM(Nombre) = "" OR ISNULL(Nombre);
UPDATE proveedor SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE proveedor SET Ciudad = 'Sin Dato' WHERE TRIM(Ciudad) = "" OR ISNULL(Ciudad);
UPDATE proveedor SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);
UPDATE proveedor SET Pais = 'Sin Dato' WHERE TRIM(Pais) = "" OR ISNULL(Pais);
UPDATE proveedor SET Departamento = 'Sin Dato' WHERE TRIM(Departamento) = "" OR ISNULL(Departamento);

update sucursal set Sucursal ='Sin Dato' where trim(Sucursal)='' or isnull(Sucursal);
update sucursal set Domicilio ='Sin Dato' where trim(Domicilio)='' or isnull(Domicilio);
update sucursal set Localidad ='Sin Dato' where trim(Localidad)='' or isnull(Localidad);
update sucursal set Provincia ='Sin Dato' where trim(Provincia)='' or isnull(Provincia);

/*
SELECT DISTINCT Domicilio
FROM sucursal
WHERE Domicilio = 'Sin Dato';
*/

/* Tabla venta limpieza y normalizacion */
select * from venta
where Precio = '' or Cantidad = '';

UPDATE venta v 
JOIN producto p ON (v.IdProducto = p.IdProducto) 
SET v.Precio = p.Precio
WHERE v.Precio = 0;

/*Tabla auxiliar donde se guardarán registros con problemas:
1-Cantidad en Cero
*/
DROP TABLE IF EXISTS aux_venta;
CREATE TABLE IF NOT EXISTS aux_venta (
IdVenta	int,
Fecha DATE NOT NULL,
Fecha_Entrega DATE NOT NULL,
IdCliente INTEGER, 
IdSucursal INTEGER,
IdEmpleado INTEGER,
IdProducto INTEGER,
Precio FLOAT,
Cantidad INTEGER,
Motivo	INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

UPDATE venta SET Cantidad = REPLACE(Cantidad, '\r', '');

INSERT INTO aux_venta (IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Motivo)
SELECT IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, 0, 1 -- 0 por ser la cantida que no habia inicialmente y uno por ser el motivo de la ausencia
FROM venta WHERE Cantidad = '' or Cantidad is null;

-- le doy cantidad 1 donde cantidad esta vacio o es nulo

UPDATE venta SET Cantidad = '1' WHERE Cantidad = '' or Cantidad is null;
ALTER TABLE `venta` CHANGE `Cantidad` `Cantidad` INTEGER NOT NULL DEFAULT '0';

/*Normalizacion a Letra Capital*/

UPDATE cliente SET 	Provincia = UC_Words(TRIM(Provincia)),
					Localidad = UC_Words(TRIM(Localidad)),
                    Domicilio = UC_Words(TRIM(Domicilio)),
                    Nombre_y_Apellido = UC_Words(TRIM(Nombre_y_Apellido));
					
UPDATE sucursal SET Provincia = UC_Words(TRIM(Provincia)),
					Localidad = UC_Words(TRIM(Localidad)),
                    Domicilio = UC_Words(TRIM(Domicilio)),
                    Sucursal = UC_Words(TRIM(Sucursal));
					
UPDATE proveedor SET Provincia = UC_Words(TRIM(Provincia)),
					Ciudad = UC_Words(TRIM(Ciudad)),
                    Departamento = UC_Words(TRIM(Departamento)),
                    Pais = UC_Words(TRIM(Pais)),
                    Nombre = UC_Words(TRIM(Nombre)),
                    Domicilio = UC_Words(TRIM(Domicilio));

UPDATE producto SET Producto = UC_Words(TRIM(Producto)),
					Tipo = UC_Words(TRIM(Tipo));
					
UPDATE empleado SET Sucursal = UC_Words(TRIM(Sucursal)),
                    Sector = UC_Words(TRIM(Sector)),
                    Cargo = UC_Words(TRIM(Cargo)),
                    Nombre = UC_Words(TRIM(Nombre)),
                    Apellido = UC_Words(TRIM(Apellido));

/*Chequeo de claves duplicadas*/
SELECT IdCliente, COUNT(*) FROM cliente GROUP BY IdCliente HAVING COUNT(*) > 1;

SELECT IdSucursal, COUNT(*) FROM sucursal GROUP BY IdSucursal HAVING COUNT(*) > 1;

SELECT IdEmpleado, COUNT(*) FROM empleado GROUP BY IdEmpleado HAVING COUNT(*) > 1; -- tiene claves duplicadas

SELECT IdProveedor, COUNT(*) FROM proveedor GROUP BY IdProveedor HAVING COUNT(*) > 1;

SELECT IdProducto, COUNT(*) FROM producto GROUP BY IdProducto HAVING COUNT(*) > 1;

-- empleado tratamiento claves duplicadas

select count(*) from empleado;

SELECT e.*, s.IdSucursal, s.Sucursal
FROM empleado e
JOIN sucursal s	ON (e.Sucursal = s.Sucursal);

select distinct Sucursal from empleado
where Sucursal NOT IN (select Sucursal from sucursal); -- muestra los valores de columna sucursal de la tabla empleado que no estan en la tabla sucursal en la columna sucursal



			/*Generacion de clave única tabla empleado mediante creacion de clave subrogada*/
-- aqui voy a dejar sin espacios 
UPDATE empleado SET Sucursal = 'Mendoza1' WHERE Sucursal = 'Mendoza 1';
UPDATE empleado SET Sucursal = 'Mendoza2' WHERE Sucursal = 'Mendoza 2';
-- UPDATE empleado SET Sucursal = 'Córdoba Quiroz' WHERE Sucursal = 'Cordoba Quiroz';



/* aqui lo que hace es que crea una columna nueva llamada idsucursal en la tabla empreado y 
despues actualiza la tabla empreado uniendo sucursal de la tabla sucursal con el comun de sucursal de la tabla empresa y y adctualiza el idde la columan nueva que creo
con el idsucursal de la tabla sucursal*/
ALTER TABLE empleado ADD IdSucursal INT NULL DEFAULT '0' AFTER `Sucursal`;
UPDATE empleado e
JOIN sucursal s	ON (e.Sucursal = s.Sucursal)
SET e.IdSucursal = s.IdSucursal;

ALTER TABLE `empleado` DROP `Sucursal`;


-- Aqui voy a crear una table que contenga los valores de Idempleado para posteriormente modificar idempleado y crearle una clave que las diferencie

ALTER TABLE `empleado` ADD `CodigoEmpleado` INT NULL DEFAULT '0' AFTER `IdEmpleado`;

UPDATE empleado SET CodigoEmpleado = IdEmpleado;
UPDATE empleado SET IdEmpleado = (IdSucursal * 1000000) + CodigoEmpleado;

/*Chequeo de claves duplicadas*/
SELECT * FROM empleado;
SELECT IdEmpleado, COUNT(*) FROM empleado GROUP BY IdEmpleado HAVING COUNT(*) > 1;

/*Modificacion de la clave foranea de empleado en venta*/
UPDATE venta SET IdEmpleado = (IdSucursal * 1000000) + IdEmpleado;


/*Normalizacion tabla empleado... Esto lo hace porque en la tabla empleado habian dos campos llamados cargo y sector los cuales tenian los mismos valores o aludian a lo mismo*/

DROP TABLE IF EXISTS cargo;
CREATE TABLE IF NOT EXISTS cargo (
  IdCargo int NOT NULL AUTO_INCREMENT,
  Cargo varchar(50) NOT NULL,
  PRIMARY KEY (IdCargo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS sector;
CREATE TABLE IF NOT EXISTS sector (
  IdSector int NOT NULL AUTO_INCREMENT,
  Sector varchar(50) NOT NULL,
  PRIMARY KEY (`IdSector`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO cargo (Cargo) SELECT DISTINCT Cargo FROM empleado ORDER BY 1; -- carga el campo de cargo de la tabla cargo con los valores de cargo de la tabla empleado
INSERT INTO sector (Sector) SELECT DISTINCT Sector FROM empleado ORDER BY 1;

-- crea en la tbla empleado dos columnas llamadas idsecto e id cargo para llenarla posterior mente lcon los id de la tabla cargo y sector
ALTER TABLE empleado 	ADD IdSector INT NOT NULL DEFAULT '0' AFTER IdSucursal, 
						ADD IdCargo INT NOT NULL DEFAULT '0' AFTER IdSector;

UPDATE empleado e JOIN cargo c ON (c.Cargo = e.Cargo) SET e.IdCargo = c.IdCargo;
UPDATE empleado e JOIN sector s ON (s.Sector = e.Sector) SET e.IdSector = s.IdSector;

ALTER TABLE empleado DROP Cargo;
ALTER TABLE empleado DROP Sector;



/*Normalización tabla producto  Generar una nueva tabla a partir de la tabla 'producto' que contenga la entidad Tipo de Producto.*/

ALTER TABLE producto ADD IdTipoProducto INT NOT NULL DEFAULT 0 AFTER Precio;

DROP TABLE IF EXISTS tipo_producto;
CREATE TABLE IF NOT EXISTS tipo_producto (
  IdTipoProducto int NOT NULL AUTO_INCREMENT,
  TipoProducto varchar(50) NOT NULL,
  PRIMARY KEY (IdTipoProducto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO tipo_producto (TipoProducto) SELECT DISTINCT Tipo FROM producto ORDER BY 1; -- inserta en la tabla tipoprodcuto los valore unicos de tipo de la tabla producto

UPDATE producto p JOIN tipo_producto t ON (p.Tipo = t.TipoProducto) SET p.IdTipoProducto = t.IdTipoProducto;
-- SELECT * FROM `producto`;
ALTER TABLE producto DROP Tipo;



/*Normalización Localidad Provincia*/ -- punto 13
DROP TABLE IF EXISTS aux_Localidad;
CREATE TABLE IF NOT EXISTS aux_Localidad (
	Localidad_Original	VARCHAR(80),
	Provincia_Original	VARCHAR(50),
	Localidad_Normalizada	VARCHAR(80),
	Provincia_Normalizada	VARCHAR(50),
	IdLocalidad			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- pa esto ver foto del excel
INSERT INTO aux_localidad (Localidad_Original, Provincia_Original, Localidad_Normalizada, Provincia_Normalizada, IdLocalidad)
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM cliente -- esta insertando en los dos primeros campos los valores de localidad y provincia de cliente y en normalizada los mismos valores para trabajar posteriormente ocn ellos
UNION
SELECT DISTINCT Localidad, Provincia, Localidad, Provincia, 0 FROM sucursal
UNION
SELECT DISTINCT Ciudad, Provincia, Ciudad, Provincia, 0 FROM proveedor
ORDER BY 2, 1;

-- jmmm

SELECT * FROM aux_localidad ORDER BY Provincia_Original;

-- comienza a normalizar
UPDATE aux_localidad SET Provincia_Normalizada = 'Buenos Aires' -- pongale buenos aires a provinia normalizada cada que vea en provienza original algo de la lista
WHERE Provincia_Original IN ('B. Aires',
                            'B.Aires',
                            'Bs As',
                            'Bs.As.',
                            'Buenos Aires',
                            'C Debuenos Aires',
                            'Caba',
                            'Ciudad De Buenos Aires',
                            'Pcia Bs As',
                            'Prov De Bs As.',
                            'Provincia De Buenos Aires');
							
UPDATE aux_localidad SET Localidad_Normalizada = 'Capital Federal'
WHERE Localidad_Original IN ('Boca De Atencion Monte Castro',
                            'Caba',
                            'Cap.   Federal',
                            'Cap. Fed.',
                            'Capfed',
                            'Capital',
                            'Capital Federal',
                            'Cdad De Buenos Aires',
                            'Ciudad De Buenos Aires')
AND Provincia_Normalizada = 'Buenos Aires';
							
UPDATE aux_localidad SET Localidad_Normalizada = 'Córdoba'
WHERE Localidad_Original IN ('Coroba',
                            'Cordoba',
							'Cã³rdoba')
AND Provincia_Normalizada = 'Córdoba';

-- creo tablas provincia y localidad

DROP TABLE IF EXISTS localidad;
CREATE TABLE IF NOT EXISTS localidad (
  IdLocalidad int NOT NULL AUTO_INCREMENT,
  Localidad varchar(80) NOT NULL,
  Provincia varchar(80) NOT NULL,
  IdProvincia int NOT NULL,
  PRIMARY KEY (IdLocalidad)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS provincia;
CREATE TABLE IF NOT EXISTS provincia (
  IdProvincia int NOT NULL AUTO_INCREMENT,
  Provincia varchar(50) NOT NULL,
  PRIMARY KEY (IdProvincia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- le cargo datos

INSERT INTO Localidad (Localidad, Provincia, IdProvincia)
SELECT	DISTINCT Localidad_Normalizada, Provincia_Normalizada, 0
FROM aux_localidad
ORDER BY Provincia_Normalizada, Localidad_Normalizada;

INSERT INTO provincia (Provincia)
SELECT DISTINCT Provincia_Normalizada
FROM aux_localidad
ORDER BY Provincia_Normalizada;
-- select * from provincia;
-- select * from localidad;



-- pongo los valores de idprovincia en la tabla localidad 
UPDATE localidad l
JOIN provincia p ON (l.Provincia = p.Provincia)
SET l.IdProvincia = p.IdProvincia;

UPDATE aux_localidad a
JOIN localidad l ON (l.Localidad = a.Localidad_Normalizada
                AND a.Provincia_Normalizada = l.Provincia)
SET a.IdLocalidad = l.IdLocalidad;

select * from aux_localidad;

-- creo columnas id localidad para cleinte proveedor y sucursal

ALTER TABLE cliente ADD IdLocalidad INT NOT NULL DEFAULT '0' AFTER Localidad;
ALTER TABLE proveedor ADD IdLocalidad INT NOT NULL DEFAULT '0' AFTER Departamento;
ALTER TABLE sucursal ADD IdLocalidad INT NOT NULL DEFAULT '0' AFTER Provincia;

-- cargo
update cliente c
join aux_localidad a ON (c.Provincia = a.Provincia_Original AND c.Localidad = a.Localidad_Original)
set c.IdLocalidad = a.IdLocalidad;

UPDATE sucursal s JOIN aux_localidad a
	ON (s.Provincia = a.Provincia_Original AND s.Localidad = a.Localidad_Original)
SET s.IdLocalidad = a.IdLocalidad;

UPDATE proveedor p JOIN aux_localidad a
	ON (p.Provincia = a.Provincia_Original AND p.Ciudad = a.Localidad_Original)
SET p.IdLocalidad = a.IdLocalidad;

/* select * from cliente;
select * from proveedor;
select * from sucursal; */

-- borro tablas que ya no necesito

ALTER TABLE cliente
  DROP Provincia,
  DROP Localidad;
  
ALTER TABLE proveedor
  DROP Ciudad,
  DROP Provincia,
  DROP Pais,
  DROP Departamento;
  
ALTER TABLE sucursal
  DROP Localidad,
  DROP Provincia;
  
ALTER TABLE localidad
  DROP Provincia;
  
  /* SELECT * FROM `cliente`;
SELECT * FROM `proveedor`;
SELECT * FROM `sucursal`;
SELECT * FROM `localidad`;
SELECT * FROM `provincia`; */

/*Discretización*/
ALTER TABLE cliente ADD Rango_Etario VARCHAR(20) NOT NULL DEFAULT '-' AFTER `Edad`;

UPDATE cliente SET Rango_Etario = '1 Hasta 30 años' WHERE Edad <= 30;
UPDATE cliente SET Rango_Etario = '2 De 31 a 40 años' WHERE Edad <= 40 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '3 De 41 a 50 años' WHERE Edad <= 50 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '4 De 51 a 60 años' WHERE Edad <= 60 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '5 Desde 60 años' WHERE Edad > 60 AND Rango_Etario = '-';

-- alter table cliente drop Rango_Etario;

select Rango_Etario, count(*)
from cliente
group by Rango_Etario; -- muestra las columnas rango etario de la tabla cleinte y una columna que conta los rangos etareos

/* SELECT * from venta
UNION
SELECT * from aux_venta; */
  
  

