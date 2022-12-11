-- cliente
use henry_m3;

-- 1. Obtener un listado del nombre y apellido de cada cliente que haya adquirido algun producto junto al id del producto y su respectivo precio.
select c.IdCliente, c.Nombre_y_Apellido, v.IdProducto, v.Precio
from cliente c
join venta v on ( c.IdCliente = v.IdCliente )
group by c.IdCliente;

select distinct c.IdCliente, c.Nombre_y_Apellido, v.IdProducto, v.Precio
from venta v
left join cliente c using (IdCliente);

select c.IdCliente, c.Nombre_y_Apellido, v.IdProducto, v.Precio
from cliente c
join venta v on ( c.IdCliente = v.IdCliente )
-- group by v.IdProducto, v.Precio; -- 558 rows returned
group by c.IdCliente,c.Nombre_y_Apellido, v.IdProducto, v.Precio;

-- clientes que compraron al menos un producto
SELECT Nombre_y_Apellido, IDProducto, precio AS Precio
FROM venta v
JOIN cliente c ON v.IdCliente = c.IdCliente;  -- solo cuando matchea
-- WHERE IdCliente IS NOT NULL
-- WHERE IdVenta -- IS NOT NULL

-- 2. Obtener un listado de clientes con la cantidad de productos adquiridos, incluyendo aquellos que nunca compraron algún producto.
select c.Nombre_y_Apellido, sum(v.Cantidad) as ProductosAdquiridos
from cliente c
left join venta v on (c.IdCliente = v.IdCliente)
group by c.IdCliente;

/*
SELECT Nombre_y_Apellido, SUM(cantidad) AS productos_adquiridos
FROM venta v
RIGHT JOIN cliente c
ON v.IdCliente = c.ID
GROUP BY ID;
*/

-- 3. Obtener un listado de cual fue el volumen de compra (cantidad) por año de cada cliente.
SELECT c.Nombre_y_Apellido, SUM(cantidad) AS productos_adquiridos, YEAR(v.Fecha) AS anio
FROM cliente c
left JOIN venta v
ON v.IdCliente = c.IdCliente
GROUP BY c.IdCliente, anio; -- el groupby para saber su compra por cada año (agrupa repetidos)

-- 4. Obtener un listado del nombre y apellido de cada cliente que haya adquirido algun producto junto al id del producto
-- la cantidad de productos adquiridos y el precio promedio.

select c.Nombre_y_Apellido, v.IdProducto, sum(v.cantidad) as CantidadProductos, avg(v.Precio*v.Cantidad) as promedio
from cliente c
join venta v on (v.IdCliente = c.IdCliente)
group by v.IdProducto, c.IdCliente; -- 18365

-- 5. Cacular la cantidad de productos vendidos y la suma total de ventas para cada localidad,
-- presentar el análisis en un listado con el nombre de cada localidad.

select v.IdProducto, c.IdLocalidad, l.Localidad, sum(v.Cantidad*v.Precio) as CantidadPorLocalidad, count(v.IdVenta) as volumen_venta
from cliente c
inner join localidad l on (c.IdLocalidad=l.IdLocalidad) inner join venta v on (c.IdCliente = v.IdCliente)
group by l.IdLocalidad; -- 578

select v.IdProducto, c.IdLocalidad, l.Localidad, sum(v.Cantidad) as CantidadPorLocalidad
from venta v
inner join sucursal s on (v.IdSucursal=s.IdSucursal) inner join cliente c on (c.IdCliente = v.IdCliente) inner join localidad l on(l.IdLocalidad = c.IdLocalidad)
group by l.IdLocalidad; -- 578


