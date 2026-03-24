use erp_logistica;
show tables;

select * from clientes;
select * from pedidos;
select * from logs_sistema;
select * from productos;
select * from categorias;



-- 1 buscar los problemas que hay (select)
select nombre_completo from clientes;
-- 2 sanear los problemas
set sql_safe_updates =0;
update clientes set nombre_completo= TRIM(nombre_completo);
set sql_safe_updates =1;
-- 3 comprobar
select nombre_completo from clientes;
-- ¿Porque el modo seguro?

-- EJERCICIO 2 (esta incompleto)

select * from clientes where email like '%.con';
set sql_safe_updates =0;
update clientes set email=replace(email,'.con','.com');
-- si ubiera un gomez.conrado sería un problema
-- en este caso ESTE REPLACE funciona
set sql_safe_updates =1;

-- opcion segura plan a

update clientes 
	set email=replace(email,'.con','.com')
    where email like '%.con';
    
-- plan b
update clientes 
	set email=replace(email,'email.con','email.com')
    where email like '%.con';
update clientes 
	set email=replace(email,'outlook.con','outlook.com')
    where email like '%.con';
    
-- comprobamos
select count(email) from clientes
where email like '%.con';

-- EJERCICIO 3 estandarizacion de teléfonos
-- ANTES hay dos formas de hacer cambios temporales:
-- STAGING (tablas o columnas intermedias)


-- TRANSACCIONES:
start transaction; -- a partir de ahora, todos los cambios son temporales, hasta el commit (confirmarlos) o el rollback (deshacerlos)

update clientes set telefono= replace(telefono,' ','');
update clientes set telefono= replace(telefono,'-','');
select * from clientes;
commit; -- marco como definitivo los cambios realizados
start transaction;
update clientes set telefono= replace(telefono,'+34','');
update clientes set telefono= replace(telefono,'0034',''); -- aqui la he cagado 

-- tengo que deshacer la transaccion

rollback;
update clientes set telefono= substring(telefono,5,9) 
	where telefono like '0034%';
commit;

start transaction; -- en el momento que hago un start transaction se hace un commit de lo anterior

-- pero existen safe points 
set sql_safe_updates=1;
-- EJERCICIO 4
select * from pedidos;
update pedidos set estado=upper(estado);
set sql_safe_updates=0;

-- EJERCICIO 5

select * from productos; -- un desastre los precios

-- vamos a por cambios temporales. En este caso, vamos a aprender staging
-- creamos una columna "precio_procesado" que vamos rellenando
-- IMPORTANTE: del mismo dato
EXPLAIN productos; -- vemos que el tipo de los precios es varchar
alter table productos
	add column precio_procesado varchar(50); -- ya tengo mi columna (con el mismo tipo) 
    
set sql_safe_updates=0;
update productos set precio_procesado= replace(precio_sucio,' ','');
update productos set precio_procesado= replace(replace(precio_procesado, '$',''),'€',''); -- se pueden añidar replace
update productos set precio_procesado=0 where precio_procesado regexp('[a-zA-Z]');
update productos set precio_procesado= replace (precio_procesado,',','.');

-- actualizo la columna inicial
update productos set precio_sucio = precio_procesado;

select * from productos;

-- elimino la columna temporal

alter table productos
	drop column precio_procesado;

set sql_safe_updates=1;


	



