/* CREATE TABLE IF NOT EXISTS fact_venta (
  IdVenta				INTEGER,
  Fecha				DATE NOT NULL,
  Fecha_Entrega 		DATE NOT NULL,
  IdCanal				INTEGER, 
  IdCliente			INTEGER, 
  IdEmpleado			INTEGER,
  IdProducto			INTEGER,
  Precio			DECIMAL(15,2),
  Cantidad			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci; */

-- Punto 1 y 2
use henry_m3;

drop table fact_venta_auditoria;
create table fact_venta_auditoria(
IdFactVentaAuditoria int not null auto_increment,
Fecha date not null,
Fecha_Entrega date not null,
IdCanal int,
IdCliente int,
IdEmpleado int,		
IdProducto int,
Usuario varchar(20),
FechaModificacion datetime,
primary key (IdFactVentaAuditoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TRIGGER fact_venta_auditoria;
create trigger fact_venta_auditoria after insert on fact_venta
for each row
insert into fact_venta_auditoria (Fecha,Fecha_Entrega,IdCanal,IdCliente,IdEmpleado,IdProducto,Usuario,FechaModificacion)
values(new.Fecha, new.Fecha_Entrega, new.IdCanal, new.IdCliente, new.IdEmpleado, new.IdProducto, current_user(), now());

/*Probando el trigger*/

TRUNCATE TABLE fact_venta;

INSERT INTO fact_venta
SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, Cantidad
FROM venta
LIMIT 30;

-- punto 3 y 4
drop table fact_venta_registros;
create table if not exists fact_venta_registros(
IdFactVentaRegistros int not null auto_increment,
CantidadRegistros int,
Usuario varchar(20),
FechaHora datetime,
primary key (IdFactVentaRegistros)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

drop trigger fact_venta_registros;
create trigger fact_venta_registros after insert on  fact_venta
for each row
insert into fact_venta_registros (CantidadRegistros,Usuario,FechaHora) -- como el id tiene autoincrement no se pone en insert into
values ((select count(*)from fact_venta),current_user(), now());
-- probando

TRUNCATE TABLE fact_venta;

INSERT INTO fact_venta
SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, Cantidad
FROM venta
LIMIT 30;


-- punto 5
-- creamos una tabla donde se puedan agrupar los registros por dia
create table registros_tablas(
IdRegistros int not null auto_increment,
Tabla varchar(30),
Fecha datetime,
CantidadRegistros int,
primary key (IdRegistros)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

-- permite ver la fecha que hay y la cantidad de registros, no necesariamente los hacemos con triggers

insert into registros_tablas (Tabla, Fecha,CantidadRegistros)
select 'venta' , now(), count(*)
from venta;

insert into registros_tablas (Tabla, Fecha,CantidadRegistros)
select 'gasto' , now(), count(*)
from gasto;

-- last point
-- tabla que permite llevar un seguimiento de la actualizacion de los cambios

drop table fact_venta_cambios;
create table fact_venta_cambios(
IdFactVentaCambios int not null auto_increment,
Fecha date,
IdCliente int,
IdProducto int,
IdEmpleado int,
Precio decimal(15,3),
Cantidad int,
Usuario varchar (20),
FechaModificacion datetime,
primary key(IdFactVentaCambios)
) engine=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

drop trigger control_actualizacion;
create trigger control_actualizacion after update on fact_venta
for each row
insert into fact_venta_cambios
values(null,old.Fecha, old.IdCliente,old.IdProducto, old.IdEmpleado, old.Precio, old.Cantidad, current_user(),now());
-- lo probamos
update fact_venta
set Cantidad=2
where IdVenta=2;
