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

-- vamos con el 9: modificacion de tipo y conmbre de columna

-- la transaccion es a nivel de datos y no a nivel de estructura
-- DML= modificar transacciones (datos) -> insert, delete
-- DDL= definicion -> create, alter, drop, truncate (no afeccta a transaccion)
start transaction;

alter table productos

change precio_sucio precio decimal (10,2);
rollback;
explain productos;
set sql_safe_updates=0;
-- estandarización de fechas
-- 1 comprobamos
select * from pedidos;
start transaction;
-- 2 modificamos a yyyy-mm-dd (formato estandar)
update pedidos
-- das un formato de texto y lo cambian, hay que decirle que fechas quiere que leamos
set fecha_texto = str_to_date(fecha_texto, '%d/%m/%Y')
where fecha_texto like '%/%/____';
update pedidos
set fecha_texto = str_to_date(fecha_texto, '%d-%m-%Y')
where fecha_texto like '%-%-____';
update pedidos
set fecha_texto = str_to_date(fecha_texto, '%Y.%m.%d')
where fecha_texto like '____.%.%';
rollback;

start transaction;
update pedidos
set fecha_texto = case
	-- when condicion then valor_a_asignar
    when fecha_texto like '____.%.%' then str_to_date(fecha_texto, '%Y.%m.%d')
    when fecha_texto like '%-%-____' then str_to_date(fecha_texto, '%d-%m-%Y')
    when fecha_texto like '%/%/____' then str_to_date(fecha_texto, '%d/%m/%Y')
    else fecha_texto end
    where -- para optimizar QUE HAGA MATCH SOLO CON LAS QUE ESTEN MAL, (agiliza)
    fecha_texto like '____.%.%' or
    fecha_texto like '%-%-____' or
    fecha_texto like '%/%/____';
-- alter table pedidos change column fecha_texto fecha DATE; -- si hago un alter table hago un commit

-- compruebo que esten bien
select * from pedidos;

-- y ahora si hago el alter table (que a su vez es commit)
alter table pedidos change column fecha_texto fecha DATE;
set sql_safe_updates=1;
explain pedidos;

-- BLOQUE 3

-- Productos huérfanos: Asigna productos con categoria_id inexistente a la categoria 'General'

-- 1) Que hay mal? productos con categorías que no existen
select * from productos;
select * from categorias;
select *
from productos p
left join 
categorias c on  p.categoria_id = c.id
where c.id is null;

select *
from productos
where categoria_id not in (select id from categorias);

-- corrijo
set sql_safe_updates=0;
start transaction;
update productos
set categoria_id = (select id from categorias where nombre = 'General') -- anidar consultas
where categoria_id not in (select id from categorias);

set sql_safe_updates=1;
commit;
-- compruebo (la query debe dar 0)
select count(*)
from productos
where categoria_id not in (select id from categorias);

-- 2. Clientes huérfanos: Reasigna pedidos con cliente_id inexistente al 'Cliente Ficticio'.



-- 3. Deduplicación de clientes: Elimina duplicados manteniendo el ID más bajo. CASO TIPICO
-- IMPORTANTE: Reasigna primero los pedidos de los clientes que vas a borrar para no perder el historico

-- 1) Analizamos el problema
select * from clientes;
start transaction;

delete from clientes 
where id=4 or id=5; -- esto no sirve porque hay que hacer una query para verlo
-- ademas me quedan en la tabla pedidos, pedidos hechos por un cliente que no existen

SELECT p.id as id_pedido,p.cliente_id, c1.id,c1.email, c2.id, c2.email
FROM 
	pedidos p 
		JOIN 
	clientes c1 ON p.cliente_id = c1.id 
		JOIN 
	clientes c2 ON c1.email = c2.email
WHERE c2.id < c1.id;
set sql_safe_updates=0;

-- pasamos los pedidos del mismo cliente y los unimos a un único cliente
update pedidos p 
		JOIN 
	clientes c1 ON p.cliente_id = c1.id 
		JOIN 
	clientes c2 ON c1.email = c2.email
set p.cliente_id = c2.id
where c2.id < c1.id;

-- eliminamos clientes duplicados
delete c1
from clientes c1
		JOIN 
	clientes c2 ON c1.email = c2.email
    where c2.id < c1.id;

set sql_safe_updates=1;
commit;
select * from pedidos;
select * from clientes;


alter table pedidos
add constraint fk_pedidos_clientes foreign key (cliente_id) references clientes(id)
on delete restrict on update cascade;
-- DA ERROR
-- no funciona porque hay pedidos que han hecho clientes inexistentes. resuelve el 2.3
select * from categorias;

alter table productos
add constraint fk_productos_categorias foreign key (categoria_id) references cateogorias(categoria_id)
on delete restrict on update cascade;

-- drop constraint fk_productos_categorias; -- si la lío elimino el constraint

-- gestion de nulls
-- coalesce (primera_opcion, segunda_opcion_si_la_primera_es_nula, tercera_opcion_si_la_segunda_es_nula)
select * from productos;

alter table productos
add column precio_final decimal(10,2)
after precio_oferta;

start transaction;
set sql_safe_updates=0;
update productos
set precio_final = coalesce(precio_oferta, precio,999999999);
-- otra forma
-- set precio_final = case when precio_oferta is null then precio_oferta when precio_oferta is null and precio is not null then precio
set sql_safe_updates=1;
commit;

-- BLOQUE 6
-- clientes sin pedidos
select * from clientes where id not in (select cliente_id from pedidos);

CREATE TABLE `historico_clientes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre_completo` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


show tables;

insert into historico_clientes
select * from clientes where id not in (select cliente_id from pedidos);

select * from historico_clientes;


-- existen los savepoint
-- primeramente start transaction
-- savepoint nombre_savepoint
-- rollback to nombre_savepoint

-- averiguar insert into duplicate key
