use henry_m3;

-- Venta agrupado por trimestre y rango etario
select ca.Trimestre, c.Rango_Etario, sum(v.Precio * v.Cantidad) as Venta
from venta v
join cliente c on (v.IdCliente = c.IdCliente) -- and year(v.Fecha)=2020) -- el on es donde intercecta, lo que hay en comun
join calendario ca on(ca.Fecha = v.Fecha)
where year(v.Fecha) = 2020 -- having es sobre agrupaciones o agregacion
group by ca.trimestre, c.Rango_Etario
order by ca.trimestre, c.Rango_Etario;
-- Tiempo de Salida: 8.2 segundos
-- 0.078 despues



-- venta agrupado por año, trimestre y tipo de producto
select c.anio, c.trimestre, tp.TipoProducto, sum(v.Precio * v.Cantidad) as Venta
from venta v
join producto p on(p.IdProducto = v.IdVenta)
join tipo_producto tp on (tp.IdTipoProducto = p.IdTipoProducto) -- tabla tipo de producto hay que arreglarla
join c on (c.Fecha = v.Fecha)
group by  c.anio, c.trimestre, tp.TipoProducto
order by c.anio, c.trimestre, tp.TipoProducto;
-- Tiempo de Salida = 01 segundo


-- venta agrupada por  sucursal, canal, mayor a 5000000
select s.Sucursal,cv.Canal, sum(v.Precio * v.Cantidad) as Venta
from venta v
join sucursal s on (s.IdSucursal = v.IdSucursal)
join canal_venta cv on (s.IdVenta = v.IdCanal)
group by s.Sucursal, cv.Canal
having venta > 5000000
order by 3 desc; -- ordena la columna 3(venta) de manera descendente
-- Tiempo de Salida = 0.001 segundos



-- Monto agrupado por fecha y tipo de gasto
select year(g.Fecha), tg.Tipo_Gasto, sum (g.Monto)
from gasto g
join tipo_gasto tg on (tg.IdTipoGasto = g.IdTipoGasto)
group by year(g.Fecha), tg.Tipo_Gasto
order by 3 desc; -- siempre hay que relativizar "Depende del tipo de empresa del que esteos hablando"



-- punto 2

alter table venta add primary key (IdVenta);
alter table venta add index (Fecha);
alter table venta add index (Fecha_Entrega);
alter table venta add index (IdCanal);
alter table venta add index (IdProducto);

alter table calendario add unique(fecha); -- asegura que a la larga hayan valores unicos, sol ote deja agregar esos valores

alter table producto add primary key (IdProducto);
alter table producto add index (IdTipoProducto);

alter table sucursal  add primary key(IdSucursal);
alter table sucursal add index (IdLocalidad);

alter table empleado add primary key(IdEmpleado); -- revisar los duplicados
/* alter table empleado add primary key (CodigoEmpleado); -- da error*/
alter table empleado add index (IdSucursal);
alter table empleado add index (IdSector);


-- drop index IdCliente on venta --> asi se elimina un indice

-- creación tabla de dhechos para modelo estrella
create table if not exists fact_venta(
IdVenta int,
Fecha date not null,
Fecha_Entrega date not null,
IdCanal int,
IdCliente int
);








/* Desde aca mi solución */
-- Funcion Agregacion y filtro para saber el producto mas vendido por rango de edad entre el 2017 y el 2019
select 	p.Producto, c.Rango_Etario, year(v.Fecha) as año, max(v.Cantidad) as Cantidad
from venta v
join producto p on (v.IdProducto = p.IdProducto)
join cliente c on (v.IdCliente = c.IdCliente)
where year(v.Fecha) between 2017 and 2019
group by p.Producto, c.Rango_Etario
order by Cantidad desc;
-- 2 segundos
-- 0.172 s

-- funcion agregacion y filtro para saber cual fue el producto que mas vendio cada canal en la provincia de buenos aires
select p.Producto, cv.Canal,/* s.Sucursal,*/ pr.Provincia, max(v.Cantidad) as Cantidad
from venta v
join producto p on (v.IdProducto = p.IdProducto)
join sucursal s on (v.IdSucursal = v.IdSucursal)
join localidad l on (l.IdLocalidad = s.IdLocalidad)
join canal_venta cv on (v.IdCanal = cv.IdCanal)
join provincia pr on (l.IdProvincia = pr.IdProvincia)
WHERE pr.Provincia = 'Buenos Aires' -- OK
group by p.Producto, cv.Canal -- , s.Sucursal
order by p.Producto, cv.Canal; -- , s.Sucursal;
-- 16 segundos
-- 11


/* select p.Producto, c.Rango_Etario, max(v.Cantidad) as cantidad
from venta v
join producto p on (v.idProducto = p.idProducto)
join cliente c on (c.idCliente = v.idCliente)
group by p.Producto, c.Rango_Etario
having max(v.Cantidad)
order by cantidad desc; */

/*Creamos indices de las tablas determinando claves primarias y foraneas*/
ALTER TABLE venta ADD PRIMARY KEY(IdVenta);
ALTER TABLE venta ADD INDEX(IdProducto);
ALTER TABLE venta ADD INDEX(IdEmpleado);
ALTER TABLE venta ADD INDEX(Fecha);
ALTER TABLE venta ADD INDEX(Fecha_Entrega);
ALTER TABLE venta ADD INDEX(IdCliente);
ALTER TABLE venta ADD INDEX(IdSucursal);
ALTER TABLE venta ADD INDEX(IdCanal);

ALTER TABLE calendario ADD UNIQUE(fecha);

ALTER TABLE canal_venta ADD PRIMARY KEY(IdCanal);

ALTER TABLE producto ADD PRIMARY KEY(IdProducto);
ALTER TABLE producto ADD INDEX(IdTipoProducto);

-- ALTER TABLE `tipo_producto` ADD PRIMARY KEY(`IdTipoProducto`); -- Ya fue definido como PK

ALTER TABLE sucursal ADD PRIMARY KEY(IdSucursal);
ALTER TABLE sucursal ADD INDEX(IdLocalidad);

ALTER TABLE empleado ADD PRIMARY KEY(IdEmpleado); -- Revisar duplicados
-- ALTER TABLE empleado ADD PRIMARY KEY(CodigoEmpleado); -- Esto da error de clave duplicada
ALTER TABLE empleado ADD INDEX(IdSucursal);
ALTER TABLE empleado ADD INDEX(IdSector);
ALTER TABLE empleado ADD INDEX(IdCargo);

ALTER TABLE localidad ADD INDEX(IdProvincia);

ALTER TABLE proveedor ADD PRIMARY KEY(IdProveedor);
ALTER TABLE proveedor ADD INDEX(IdLocalidad);

ALTER TABLE gasto ADD PRIMARY KEY(IdGasto);
ALTER TABLE gasto ADD INDEX(IdSucursal);
ALTER TABLE gasto ADD INDEX(IdTipoGasto);
ALTER TABLE gasto ADD INDEX(Fecha);

ALTER TABLE cliente ADD PRIMARY KEY(IdCliente);
ALTER TABLE cliente ADD INDEX(IdLocalidad);

ALTER TABLE compra ADD PRIMARY KEY(IdCompra);
ALTER TABLE compra ADD INDEX(Fecha);
ALTER TABLE compra ADD INDEX(IdProducto);
ALTER TABLE compra ADD INDEX(IdProveedor);

/*Creamos las relaciones entre las tablas, y con ellas las restricciones*/ -- permite principio de integridad
ALTER TABLE venta ADD CONSTRAINT venta_fk_fecha FOREIGN KEY (fecha) REFERENCES calendario (fecha) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT venta_fk_cliente FOREIGN KEY (IdCliente) REFERENCES cliente (IdCliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT venta_fk_sucursal FOREIGN KEY (IdSucursal) REFERENCES sucursal (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT venta_fk_producto FOREIGN KEY (IdProducto) REFERENCES producto (IdProducto) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT venta_fk_empleado FOREIGN KEY (IdEmpleado) REFERENCES empleado (IdEmpleado) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT venta_fk_canal FOREIGN KEY (IdCanal) REFERENCES canal_venta (IdCanal) ON DELETE RESTRICT ON UPDATE RESTRICT;

select * from venta where IdCliente = 969;
delete from cliente where IdCliente = 969; -- No me deja porque está creada la restricción

select * from cliente where IdCliente
NOT IN (SELECT DISTINCT IdCliente FROM venta);
delete from cliente where IdCliente = 59; -- Me deja, está creada la restricción, pero no existe el cliente en ventas

ALTER TABLE producto ADD CONSTRAINT producto_fk_tipoproducto FOREIGN KEY (IdTipoProducto) REFERENCES tipo_producto (IdTipoProducto) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE empleado ADD CONSTRAINT empleado_fk_sector FOREIGN KEY (IdSector) REFERENCES sector (IdSector) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE empleado ADD CONSTRAINT empleado_fk_cargo FOREIGN KEY (IdCargo) REFERENCES cargo (IdCargo) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE empleado ADD CONSTRAINT empleado_fk_sucursal FOREIGN KEY (IdSucursal) REFERENCES sucursal (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE cliente ADD CONSTRAINT cliente_fk_localidad FOREIGN KEY (IdLocalidad) REFERENCES localidad (IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE proveedor ADD CONSTRAINT proveedor_fk_localidad FOREIGN KEY (IdLocalidad) REFERENCES localidad (IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE sucursal ADD CONSTRAINT sucursal_fk_localidad FOREIGN KEY (IdLocalidad) REFERENCES localidad (IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE localidad ADD CONSTRAINT localidad_fk_provincia FOREIGN KEY (IdProvincia) REFERENCES provincia (IdProvincia) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE compra ADD CONSTRAINT compra_fk_fecha FOREIGN KEY (Fecha) REFERENCES calendario (fecha) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE compra ADD CONSTRAINT compra_fk_producto FOREIGN KEY (IdProducto) REFERENCES producto (IdProducto) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE compra ADD CONSTRAINT compra_fk_proveedor FOREIGN KEY (IdProveedor) REFERENCES proveedor (IdProveedor) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE gasto ADD CONSTRAINT gasto_fk_fecha FOREIGN KEY (Fecha) REFERENCES calendario (fecha) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE gasto ADD CONSTRAINT gasto_fk_sucursal FOREIGN KEY (IdSucursal) REFERENCES sucursal (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE gasto ADD CONSTRAINT gasto_fk_tipogasto FOREIGN KEY (IdTipoGasto) REFERENCES tipo_gasto (IdTipoGasto) ON DELETE RESTRICT ON UPDATE RESTRICT;

/*Cracion de Tablas de Hechos para modelo Estrella*/
DROP TABLE IF EXISTS fact_venta;
CREATE TABLE IF NOT EXISTS fact_venta (
  IdVenta				INTEGER,
  Fecha				DATE NOT NULL,
  Fecha_Entrega 		DATE NOT NULL,
  IdCanal				INTEGER, 
  IdCliente			INTEGER, 
  IdEmpleado			INTEGER,
  IdProducto			INTEGER,
  Precio			DECIMAL(15,2),
  Cantidad			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO fact_venta
SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, Cantidad
FROM venta;

select * from venta
WHERE YEAR(Fecha) = 2020;

ALTER TABLE fact_venta ADD PRIMARY KEY(IdVenta);
ALTER TABLE fact_venta ADD INDEX(IdProducto);
ALTER TABLE fact_venta ADD INDEX(IdEmpleado);
ALTER TABLE fact_venta ADD INDEX(Fecha);
ALTER TABLE fact_venta ADD INDEX(Fecha_Entrega);
ALTER TABLE fact_venta ADD INDEX(IdCliente);
ALTER TABLE fact_venta ADD INDEX(IdCanal);

CREATE TABLE IF NOT EXISTS dim_cliente (
	IdCliente			INTEGER,
	Nombre_y_Apellido	VARCHAR(80),
	Domicilio			VARCHAR(150),
	Telefono			VARCHAR(30),
	Rango_Etario		VARCHAR(20),
	IdLocalidad			INTEGER,
	Latitud				DECIMAL(13,10),
	Longitud			DECIMAL(13,10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO dim_cliente
SELECT IdCliente, Nombre_y_Apellido, Domicilio, Telefono, Rango_Etario, IdLocalidad, Latitud, Longitud
FROM cliente
WHERE IdCliente IN (SELECT distinct IdCliente FROM fact_venta);

DROP TABLE IF EXISTS dim_producto;
CREATE TABLE IF NOT EXISTS dim_producto (
	IdProducto					INTEGER,
	Producto					VARCHAR(100),
	IdTipoProducto				VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO dim_producto
SELECT IdProducto, Producto, IdTipoProducto
FROM producto
WHERE IdProducto IN (SELECT distinct IdProducto FROM fact_venta);




