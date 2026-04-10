use logistica_global;

select * from envios
where id between 1000 and 1500; -- esta consulta tarda mucho menos 
-- esto es porque esta consulta tiene un índice

select * from envios
where cliente_id between 1000 and 1500; -- esta tarda 100 más que la consulta anterior (0.06..)
-- y esta no tine índice

-- podemos crear un índice para agilizar las 

-- un índice es una tabla intermedia (que yo no veo) -> está ordenado

-- es como una baraja, si está ordenada sabemos a donde está la carta que buscamos
-- sino está ordenada tengo que ir una por una

-- cuando tengo un índice busca directamente el índice que le interesa en el caso de la primer consulta 500
-- en cambio la otra consulta tuvo que mirar las 100.000

-- podemos crearle un índice a cliente_id

		-- idx_tablaEnLaQueEstoy_NombreColumna
create index idx_envios_cliente_id on envios(cliente_id);

-- se deshace con drop...

-- entonces cuanto tardala consulta 2?

select * from envios
where cliente_id between 1000 and 1500; -- ahora tarda 0.0012..)

-- como sé que cree un indice (lo miro en la columna key-> aparece como MUL porque hay duplicados)
explain envios;

-- la clave primaria, foreign key, unique tiene por defécto un índice -> por lo tanto nunca querré hacer un índice de esto
-- tampoco quiero hacer un índice de una columna tipo text

-- otra manera
show index from envios;

-- los índices se pierdes si utilizo una funcion 

