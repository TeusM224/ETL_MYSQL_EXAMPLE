create database if not exists henry_m3;
use henry_m3;

drop table gasto;
create table gasto(
IdGasto int not null,
IdSucursal int not null,
IdTipoGasto int not null,
Fecha date not null,
Monto decimal(10,1) not null
-- primary key (IdGasto)
)engine = innoDB default charset=utf8mb4 collate=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Gasto.csv'
INTO TABLE gasto 
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

CREATE TABLE compra (
  IdCompra int not null,
  Fecha DATE not null,
  IdProducto int not null,
  Cantidad int not null,
  Precio decimal(10,2) not null,
  IdProveedor int not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\compra.csv' 
INTO TABLE compra 
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS venta;
create table venta (
IdVenta int not null,
Fecha date not null,
Fecha_Entrega date not null,
IdCanal int not null,
IdCliente int not null,
IdSucursal int not null,
IdEmpleado int not null,
IdProducto int not null,
Precio varchar(30) not null,
Cantidad varchar(30) not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Venta.csv' 
INTO TABLE venta 
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS producto;
create table producto(
IdProdcuto int not null,
Concepto varchar(100) not null,
Tipo varchar(45) not null, 
Precio varchar(30) not null
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_spanish_ci ;
load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\PRODUCTOS_csv.csv'
into table producto
fields terminated by ';' enclosed by'' escaped by''
lines terminated by'\r\n' ignore 1 lines;

drop table cliente;
create table cliente(
ID int not null,
Provincia VARCHAR(50) not null,
Nombre_y_Apellido VARCHAR(80) not null,
Domicilio VARCHAR(150) not null,
Telefono VARCHAR(30) not null,
Edad VARCHAR(5) not null,
Localidad VARCHAR(80) not null,
X VARCHAR(30) not null,
Y VARCHAR(30) not null,
col10 VARCHAR(1) not null
) engine=InnoDB default charset=utf8mb4 collate=utf8mb4_spanish_ci ;
load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Clientes.csv'
into table cliente
fields terminated by ';' enclosed by'' escaped by''
lines terminated by'\n' ignore 1 lines;

DROP TABLE IF EXISTS proveedor;
CREATE TABLE proveedor (
IDProveedor	int not null,
Nombre	VARCHAR(80) not null,
Domicilio VARCHAR(150) not null,
Ciudad	VARCHAR(80) not null,
Provincia VARCHAR(50) not null,
Pais VARCHAR(20) not null,
Departamento VARCHAR(80) not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Proveedores_csv.csv' 
INTO TABLE proveedor
FIELDS TERMINATED BY ';' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS empleado;
CREATE TABLE empleado (
IDEmpleado INTEGER,
Apellido VARCHAR(100),
Nombre VARCHAR(100),
Sucursal VARCHAR(50),
Sector VARCHAR(50),
Cargo VARCHAR(50),
Salario2 VARCHAR(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Empleados_csv.csv' 
INTO TABLE empleado 
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

DROP TABLE IF EXISTS sucursal;
CREATE TABLE IF NOT EXISTS sucursal (
ID int not null,
Sucursal VARCHAR(40) not null,
Domicilio VARCHAR(150) not null,
Localidad VARCHAR(80) not null,
Provincia VARCHAR(50) not null,
Latitud2 VARCHAR(30) not null,
Longitud2 VARCHAR(30) not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Sucursales.csv' 
INTO TABLE sucursal
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

drop table if exists canal_venta; -- alter table modificar una columna
CREATE TABLE IF NOT EXISTS canal_venta (
IdCanal	int not null,
Canal varchar(50) not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\CanalDeVenta_csv1.csv'
into table canal_venta
fields terminated by ';' enclosed by'' escaped by''
lines terminated by'\n' ignore 1 lines;

DROP TABLE IF EXISTS tipo_gasto;
CREATE TABLE IF NOT EXISTS tipo_gasto (
IdTipoGasto int(11) NOT NULL AUTO_INCREMENT,
Descripcion varchar(100) NOT NULL,
Monto_Aproximado DECIMAL(10,2) NOT NULL,
PRIMARY KEY (IdTipoGasto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TiposDeGasto.csv' 
INTO TABLE tipo_gasto 
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

/*Procedimiento Calendario*/

DROP PROCEDURE IF EXISTS `Llenar_dimension_calendario`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Llenar_dimension_calendario`(IN `startdate` DATE, IN `stopdate` DATE)
BEGIN
    DECLARE currentdate DATE;
    SET currentdate = startdate;
    WHILE currentdate < stopdate DO
        INSERT INTO calendario VALUES (
                        YEAR(currentdate)*10000+MONTH(currentdate)*100 + DAY(currentdate),
                        currentdate,
                        YEAR(currentdate),
                        MONTH(currentdate),
                        DAY(currentdate),
                        QUARTER(currentdate),
                        WEEKOFYEAR(currentdate),
                        DATE_FORMAT(currentdate,'%W'),
                        DATE_FORMAT(currentdate,'%M'));
        SET currentdate = ADDDATE(currentdate,INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

DROP TABLE IF EXISTS calendario;
CREATE TABLE calendario (
id INTEGER PRIMARY KEY,  -- year*10000+month*100+day
fecha DATE NOT NULL,
anio INTEGER NOT NULL,
mes INTEGER NOT NULL, -- 1 to 12
dia INTEGER NOT NULL, -- 1 to 31
trimestre INTEGER NOT NULL, -- 1 to 4
semana INTEGER NOT NULL, -- 1 to 52/53
dia_nombre VARCHAR(9) NOT NULL, -- 'Monday', 'Tuesday'...
mes_nombre VARCHAR(9) NOT NULL -- 'January', 'February'...
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

call Llenar_dimension_calendario('2015-01-01','2020-12-31');

/*Catalogo de funciones y procedimientos*/

SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS `UC_Words`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `UC_Words`( str VARCHAR(255) ) RETURNS varchar(255) CHARSET utf8mb4
BEGIN  
  DECLARE c CHAR(1);  
  DECLARE s VARCHAR(255);  
  DECLARE i INT DEFAULT 1;  
  DECLARE bool INT DEFAULT 1;  
  DECLARE punct CHAR(17) DEFAULT ' ()[]{},.-_!@;:?/';  
  SET s = LCASE( str );  
  WHILE i < LENGTH( str ) DO  
     BEGIN  
       SET c = SUBSTRING( s, i, 1 );  
       IF LOCATE( c, punct ) > 0 THEN  
        SET bool = 1;  
      ELSEIF bool=1 THEN  
        BEGIN  
          IF c >= 'a' AND c <= 'z' THEN  
             BEGIN  
               SET s = CONCAT(LEFT(s,i-1),UCASE(c),SUBSTRING(s,i+1));  
               SET bool = 0;  
             END;  
           ELSEIF c >= '0' AND c <= '9' THEN  
            SET bool = 0;  
          END IF;  
        END;  
      END IF;  
      SET i = i+1;  
    END;  
  END WHILE;  
  RETURN s;  
END$$
DELIMITER ;