use henry_m3;

-- usig outliyers detection 3 sigma rules

(select IdProducto, avg(Precio) as Promedio, avg(Precio) + (3*stddev(Precio)) as Maximo
from venta 
group by IdProducto);

SELECT IdProducto, avg(Precio) as promedio, avg(Precio) - (3 * stddev(Precio)) as Minimo
from venta
GROUP BY IdProducto;

-- deteccion outliyers  
	-- venta
select v.* , s1.Promedio, s1.Maximo
from venta v
join(SELECT IdProducto, avg(Precio) as Promedio, avg(Precio) + (3 * stddev(Precio)) as Maximo -- subquery desde aqui comienza
	from venta
	GROUP BY IdProducto) s1
on (v.IdProducto = s1.IdProducto) -- Tabla con promedio y maximo del query1
where v.Precio > s1.Maximo
order by s1.Maximo desc;

select v.* , s1.Promedio, s1.Minimo
from venta v
join(SELECT IdProducto, avg(Precio) as Promedio, avg(Precio) - (3 * stddev(Precio)) as Minimo 
	from venta
	GROUP BY IdProducto) s1
on (v.IdProducto = s1.IdProducto) 
where v.Precio > s1.Minimo; -- se descarta el minimo porque dan valores negativos para el precio

SELECT *
FROM venta
WHERE IdProducto = 42890;

SELECT *
FROM venta
WHERE IdProducto = 42811;

		-- Cantidad
select v.* , s1.Promedio, s1.Maximo
from venta v
join(SELECT IdProducto, avg(Cantidad) as Promedio, avg(Cantidad) + (3 * stddev(Cantidad)) as Maximo -- subquery desde aqui comienza
	from venta
	GROUP BY IdProducto) s1
on (v.IdProducto = s1.IdProducto) -- Tabla con promedio y maximo del query1
where v.Precio > s1.Maximo
order by s1.Maximo desc;







