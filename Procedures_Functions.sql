use henry;
-- Este procedimiento lista los alumnos pertenecientes a una carrera.

DELIMITER $$
CREATE PROCEDURE listarCarrera( IN nombreCarrera VARCHAR(25))
BEGIN
	SELECT CONCAT(alumnos.nombre,' ',apellido) AS Alumno, cohorte
	FROM alumnos
	INNER JOIN cohortes
	ON cohorte = idCohorte
	INNER JOIN carreras 
	ON carrera = idCarrera
	WHERE carreras.nombre=nombreCarrera;
END;
DELIMITER

CALL listarCarrera('Data Science')

-- ejemplo2
drop procedure GetTotalAlumnos;

DELIMITER $$
CREATE PROCEDURE GetTotalAlumnos()
BEGIN
	DECLARE TotalAlumnos INT DEFAULT 0;
    
    SELECT COUNT(*) 
    INTO TotalAlumnos
    FROM alumno;
    
    SELECT TotalAlumnos;
END$$
DELIMITER ;

CALL GetTotalAlumnos();

show session variables like 'GetTotalAlumnos';

-- EJEMPLO 1:

-- Esta función recibe una fecha de ingreso y cálcula la antigüedad en meses del alumno.
/* antes de crear esta funcion debe setearse una variable porque puedo que nos de el ERROR CODE: 1418 "This function has none of deterministic, nosql, or real sql data in its declaration and binary logging is enable(you *might want to use the less safe log_bin_trust_function_creator variable)*/
show variables like 'log_bin_trust_function_creators';
set global log_bin_trust_function_creators =1; -- pone el value en "ON porque por defecto viene en OFF"


DELIMITER $$
CREATE FUNCTION antMeses(fechaIncorporacion DATE) RETURNS INT -- Asignamos un nombre, parámetros de la función y tipo de dato a retornar.
-- La función se define entre BEGIN - END.
BEGIN

	DECLARE meses INT; -- Declaramos las variables que van a operar en la función
    SET meses = timestampdiff(MONTH, fechaIncorporacion, curdate()); -- Definimos el script.
    -- set meses = TIMESTAMPDIFF(MONTH, fechaIncorporacion, date(now())); es lo mismo de arriba, sintaxis timestampdiff = (UnidadEsperada,Parametro1,Parametro2)--los parametros se restan
    RETURN meses; -- Retornamos el valor de salida que debe coincidir con el tipo declarado en CREATE
    
END$$
DELIMITER ;

select *, antMeses(fechaIncorporacion)
from alumno;

-- EJEMPLO 2:

-- Esta función recibe el id de un alumno y devuelve su antigüedad en meses.

DELIMITER $$
CREATE FUNCTION antiguedadMeses2(id INT) RETURNS INT
BEGIN
	DECLARE meses INT;
    SELECT TIMESTAMPDIFF(MONTH, fechaIncorporacion, DATE(NOW()))
    INTO meses
    FROM alumno
    WHERE idAlumno = id;
    RETURN meses;
END$$
DELIMITER ;

drop function antiguedadMeses2;
SELECT antiguedadMeses2(130);

-- ejemplo que esta buena la funcion
select *, timestampdiff(month,fechaIncorporacion,date(now())) as antiguedad from alumno where idAlumno = 130 ;


-- ---------------------------------------------------- --
/*SOLUCION HOMEWORK*/
use henry_m3;
-- 1 Crear un procedimiento que recibe como parametro una fecha y devuelva el listado de productos que se vendieron en esa fecha.

select /*distinct*/ p.Producto, v.Fecha 
from venta v
inner join producto p on (v.IdProducto=p.IdProducto)
-- where v.Cantidad > 0 -- este sobra porque todas las cantidades son mayores a 0
group by p.Producto, v.Fecha -- el groupby de p.Producto hace lo de distinct
order by p.Producto;
-- sin:46645, con:18097(Este esta bueno)

DELIMITER $$
create procedure ProductosVendidos(fechaVenta date)
BEGIN

	select p.Producto
    from venta v
    inner join producto p on (v.IdProducto=p.IdProducto) -- and v.Fecha = fechaVenta)
    where fechaVenta =v.Fecha
    group by p.Producto, fechaVenta;
    
END$$
DELIMITER ;

call ProductosVendidos('2018-06-08');

-- otra respuesta 
DROP PROCEDURE listaProductos;
/*
-- #1
DROP PROCEDURE listaProductos;
DELIMITER $$
CREATE PROCEDURE listaProductos (fechaVenta DATE)
BEGIN
	SELECT DISTINCT p.Producto
    FROM venta v
    JOIN producto p ON(p.IdProducto = v.IdProducto AND v.Fecha = fechaVenta);
END $$
DELIMITER ;
*/

-- 2 Crear una función que calcule el valor nominal de un margen bruto determinado por el usuario a partir del precio de lista de los productos.

DROP FUNCTION margenBruto;
DELIMITER $$
CREATE FUNCTION margenBruto(precio DECIMAL(15,2), margen DECIMAL(8,2)) RETURNS DECIMAL (15,2)
BEGIN
	DECLARE margenBruto DECIMAL(15,2);
    SET margenBruto = precio * margen;
    RETURN margenBruto;
END $$
DELIMITER ;

SELECT margenBruto(100, 1.2);

SELECT c.Fecha, pr.nombre as Proveedor, p.Producto, c.Precio as Precio_Compra, margenBruto(c.Precio, 1.2) as Precio_con_margen
FROM compra c
JOIN producto p ON(p.IdProducto = c.IdProducto)
JOIN proveedor pr ON(pr.IdProveedor = c.IdProveedor);

-- 3 Obtner un listado de productos de IMPRESION y utilizarlo para cálcular el valor nominal de un margen bruto del 20% de cada uno de los productos.
SELECT p.IdProducto, p.Producto, p.Precio, margenBruto(p.Precio, 1.2) as precio_con_margen
FROM producto p
JOIN tipo_producto tp ON(p.IdTipoProducto = tp.IdTipoProducto AND TipoProducto = 'Impresión');

-- 4 Crear un procedimiento que permita listar los productos vendidos desde venta a partir de un "Tipo" que determine el usuario.
select p.IdProducto, p.Producto,tp.TipoProducto
from producto p
join tipo_producto tp on (p.IdTipoProducto = tp.IdTipoProducto)
where tp.TipoProducto = 'Audio'
order by p.IdProducto;

drop procedure ListaProductosTipo;
DELIMITER $$
create procedure ListaProductosTipo (tipoProducto varchar(30))
begin
	select p.IdProducto, p.Producto, tipoProducto
    from producto p
    inner join tipo_producto tp on (p.IdTipoProducto = tp.IdTipoProducto and tp.TipoProducto = tipoProducto collate utf8mb4_spanish_ci); -- = tipoProducto); esta parte se usa cuando nos da el error code 1267 illegal mix of collections
end$$
DELIMITER ;
call ListaProductosTipo('Audio');

-- 5 Crear un procedimiento que permita realizar la insercción de datos en la tabla fact_venta.
truncate table fact_venta;

DROP PROCEDURE cargarFact_venta;
DELIMITER $$
CREATE PROCEDURE cargarFact_venta()
BEGIN
	INSERT INTO fact_venta
    SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, Cantidad
    FROM venta
    -- WHERE Outlier = 1
    LIMIT 10;
END $$
DELIMITER ;
CALL cargarFact_venta();

-- 6 Crear un procedimiento almacenado que reciba un grupo etario y devuelta el total de ventas para ese grupo.
drop procedure VentasGrupoEtario;
DELIMITER $$
create procedure VentasGrupoEtario (grupoEtario varchar(30))
begin
	select c.Rango_Etario, SUM(v.Precio * v.Cantidad) AS Total_ventas
    from venta v
    inner join cliente c on (v.IdCliente = c.IdCliente and c.Rango_Etario collate utf8mb4_spanish_ci LIKE concat('%', grupoEtario, '%'));
end$$
DELIMITER ;

call VentasGrupoEtario('51%60');

-- 7 Crear una variable que se pase como valor para realizar una filtro sobre Rango_etario en una consulta génerica a dim_cliente.
set @grupo_etario='4 De 51 a 60 años' collate utf8mb4_spanish_ci;
SELECT *
FROM dim_cliente
WHERE Rango_Etario  = @grupo_etario;
