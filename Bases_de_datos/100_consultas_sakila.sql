-- 1) Para cada idioma, obtener el replacement_cost máximo y mínimo de sus películas (idioma con >=10 películas).
-- Salida obligatoria (alias en orden): language_id, language_name, max_replacement_cost, min_replacement_cost

use sakila;

select * from film
where language_id =;

select * from language;

SELECT 
    language.language_id AS language_id,
    language.name AS language_name,
    MAX(replacement_cost) AS max_replacement_cost,
    MIN(replacement_cost) AS min_replacement_cost
FROM
    language
        JOIN
    film ON film.language_id = language.language_id
WHERE
    film.film_id >= 10
GROUP BY language.name , film.original_language_id , film.language_id;

-- 1:  Para cada actor, muestra el número total de películas en las que aparece;
-- es decir, cuenta cuántas filas de film_actor corresponden a cada actor.

SELECT 
    actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS nombre_actor,
    COUNT(fa.film_id) AS peliculas_totales
FROM
    actor
        JOIN
    film_actor fa USING (actor_id)
GROUP BY actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

-- 2:  Lista solo los actores que participan en 20 o más películas (umbral alto) con su conteo.

SELECT 
    CONCAT(actor.first_name, ' ', actor.last_name) AS nombre_actor,
    COUNT(fa.film_id) AS participaciones_totales
FROM
    actor
        JOIN
    film_actor fa USING (actor_id)
GROUP BY actor_id , CONCAT(actor.first_name, ' ', actor.last_name)
HAVING COUNT(fa.film_id) >= 20;

-- 3:  Para cada idioma, indica cuántas películas están catalogadas en ese idioma.

SELECT 
    la.name AS idioma, COUNT(film.film_id) AS total_peliculas
FROM
    language la
        JOIN
    film ON film.language_id = la.language_id
GROUP BY la.language_id;

-- 4:  Muestra el promedio de duración (length) de las películas por idioma y 
-- filtra aquellos idiomas con duración media estrictamente mayor a 110 minutos.

select * from film limit 5;

SELECT 
    la.language_id, la.name AS idioma, AVG(film.length)
FROM
    language la
        JOIN
    film ON film.language_id = la.language_id
GROUP BY la.language_id , la.name
HAVING AVG(film.length) > 110;

-- 5:  Para cada película, muestra cuántas copias hay en el inventario.
SELECT 
    film.film_id AS pelicula_id,
    film.title AS titulo,
    COUNT(inv.inventory_id) AS copias
FROM
    film
        JOIN
    inventory inv USING (film_id)
GROUP BY film.film_id , film.title;

-- 6:  Lista solo las películas que tienen al menos 5 copias en inventario.

SELECT 
    film.film_id AS pelicula_id,
    film.title AS titulo,
    COUNT(inv.inventory_id) AS copias
FROM
    film
        JOIN
    inventory inv USING (film_id)
GROUP BY film.film_id , film.title
HAVING COUNT(inv.inventory_id) >= 5;

-- 7:  Para cada artículo de inventario, cuenta cuántos alquileres se han realizado.

SELECT 
    inv.inventory_id AS inventario_id,
    COUNT(rental.rental_id) AS total_alquileres
FROM
    inventory inv
        JOIN
    rental USING (inventory_id)
GROUP BY inv.inventory_id;

-- 8:  Para cada cliente, muestra cuántos alquileres ha realizado en total.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    COUNT(rental.rental_id) AS alquileres_totales
FROM
    customer cu
        JOIN
    rental USING (customer_id)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 9:  Lista los clientes con 30 o más alquileres acumulados.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    COUNT(rental.rental_id) AS alquileres_totales
FROM
    customer cu
        JOIN
    rental USING (customer_id)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name)
HAVING COUNT(rental.rental_id) >= 30;

-- 10:  Para cada cliente, muestra el total de pagos (suma en euros/dólares) que ha realizado.

select * from payment limit 2;

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    SUM(pa.amount) AS total_pagos
FROM
    customer cu
        JOIN
    payment pa USING (customer_id)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 11:  Muestra los clientes cuyo importe total pagado es al menos 200.

 SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    SUM(pa.amount) AS total_pagos
FROM
    customer cu
        JOIN
    payment pa USING (customer_id)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name)
HAVING SUM(pa.amount) >= 200;

-- 12:  Para cada empleado (staff), muestra el número de pagos que ha procesado.

SELECT 
    staff.staff_id AS empleado_id,
    CONCAT(staff.first_name, ' ', staff.last_name) AS empleado,
    COUNT(pa.amount) AS total_cobros
FROM
    staff
        JOIN
    payment pa USING (staff_id)
GROUP BY staff.staff_id , CONCAT(staff.first_name, ' ', staff.last_name);

-- 13:  Para cada empleado, muestra el importe total procesado.

SELECT 
    staff.staff_id AS empleado_id,
    CONCAT(staff.first_name, ' ', staff.last_name) AS empleado,
    SUM(pa.amount) AS total_importe_cobrado
FROM
    staff
        JOIN
    payment pa USING (staff_id)
GROUP BY staff.staff_id , CONCAT(staff.first_name, ' ', staff.last_name);

-- 14:  Para cada tienda, cuenta cuántos artículos de inventario tiene.

SELECT 
    store.store_id AS tienda,
    COUNT(inv.inventory_id) AS copias_totales
FROM
    store
        JOIN
    inventory inv USING (store_id)
GROUP BY store.store_id;

-- 15:  Para cada tienda, cuenta cuántos clientes tiene asignados.
SELECT 
    store.store_id AS tienda,
    COUNT(cu.customer_id) AS total_clientes
FROM
    store
        JOIN
    customer cu USING (store_id)
GROUP BY store.store_id;

-- 16: Para cada tienda, cuenta cuántos empleados (staff) tiene asignados.
SELECT 
    store.store_id AS tienda,
    COUNT(staff.staff_id) AS total_empleados
FROM
    store
        JOIN
    staff USING (store_id)
GROUP BY store.store_id;

-- 17:  Para cada dirección (address), cuenta cuántas tiendas hay ubicadas ahí (debería ser 0/1 en datos estándar).

select * from address limit 5;

SELECT 
    ad.address_id AS direccion_id,
    ad.address AS direccion,
    COUNT(store.store_id) as total_tiendas
FROM
    address ad
        JOIN
    store USING (address_id)
GROUP BY ad.address_id , ad.address;

-- 18:  Para cada dirección, cuenta cuántos empleados residen en esa dirección. 

SELECT 
    ad.address_id AS direccion_id,
    ad.address AS direccion,
    COUNT(staff.staff_id) as total_empleados
FROM
    address ad
        JOIN
    staff USING (address_id)
GROUP BY ad.address_id , ad.address;

-- 19:  Para cada dirección, cuenta cuántos clientes residen ahí.
SELECT 
    ad.address_id AS direccion_id,
    ad.address AS direccion,
    COUNT(cu.customer_id) as total_clientes
FROM
    address ad
        JOIN
    customer cu USING (address_id)
GROUP BY ad.address_id , ad.address;

-- 20:  Para cada ciudad, cuenta cuántas direcciones hay registradas.

SELECT 
    city.city_id AS ciudad_id,
    city.city AS ciudad,
    COUNT(ad.address_id) AS total_direcciones
FROM
    city
        JOIN
    address ad USING (city_id)
GROUP BY city.city_id , city.city;

-- 21:  Para cada país, cuenta cuántas ciudades existen.

SELECT 
    country.country_id AS pais_id,
    country.country AS pais,
    COUNT(city.city_id) AS total_ciudades
FROM
    country
        JOIN
    city USING (country_id)
GROUP BY country.country_id , country.country;

-- 22:  Para cada idioma, calcula la duración media de películas y muestra solo los idiomas con media entre 90 y 120 inclusive

SELECT 
    la.language_id AS idioma_id,
    la.name AS idioma,
    AVG(film.length)
FROM
    language la
        JOIN
    film ON film.language_id = la.language_id
GROUP BY la.language_id , la.name
HAVING AVG(film.length) BETWEEN 90 AND 120;

-- 23:  Para cada película, cuenta el número de alquileres que se han hecho de cualquiera de sus copias (usando inventario).

SELECT 
    inv.film_id AS peliculas,
    film.title AS titulo,
    COUNT(rental.rental_id) AS total_alquileres
FROM
    film
        JOIN
    inventory inv USING (film_id)
        JOIN
    rental USING (inventory_id)
GROUP BY inv.film_id;

-- 24:  Para cada cliente, cuenta cuántos pagos ha realizado en 2005 (usando el año de payment_date).

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    COUNT(pa.payment_id) AS pagos_totales
FROM
    customer cu
        JOIN
    payment pa USING (customer_id)
WHERE
    YEAR(pa.payment_date) = '2005'
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 25:  Para cada película, muestra el promedio de tarifa de alquiler (rental_rate)
-- de las copias existentes (es un promedio redundante pero válido).

SELECT 
    film.film_id AS inventario_id,
    film.title AS pelicula,
    AVG(film.rental_rate)
FROM
    film
GROUP BY film.film_id , film.title;

-- 26:  Para cada actor, muestra la duración media (length) de sus películas.

SELECT 
    actor.actor_id AS actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS actor,
    AVG(film.length)
FROM
    actor
        JOIN
    film_actor USING (actor_id)
        JOIN
    film USING (film_id)
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

-- 27:  Para cada ciudad, cuenta cuántos clientes hay (usando la relación cliente->address->city requiere 3 tablas;
-- aquí contamos direcciones por ciudad).

SELECT 
    city.city_id AS ciudad_id,
    city.city AS ciudad,
    COUNT(cu.customer_id) AS total_clientes,
    COUNT(ad.address_id) AS total_direcciones
FROM
    city
        JOIN
    address ad USING (city_id)
        JOIN
    customer cu USING (address_id)
GROUP BY city.city_id , city.city
ORDER BY ciudad_id;

-- 28:  Para cada película, cuenta cuántos actores tiene asociados.

SELECT 
    film.film_id AS pelicula_id,
    film.title AS pelicula,
    COUNT(film_actor.actor_id)
FROM
    film
        JOIN
    film_actor USING (film_id)
GROUP BY film.film_id , film.title;

-- 29:  Para cada categoría (por id), cuenta cuántas películas pertenecen a ella (sin nombre de categoría para mantener 2 tablas).

SELECT 
    fc.category_id AS categoria,
    COUNT(film.film_id) AS peliculas
FROM
    film_category fc
        JOIN
    film USING (film_id)
GROUP BY fc.category_id;

-- 30:  Para cada tienda, cuenta cuántos alquileres totales se originan en su inventario.

SELECT 
    store.store_id AS tienda,
    COUNT(rental.rental_id) AS alquileres_por_tienda
FROM
    store
        JOIN
    inventory USING (store_id)
        JOIN
    rental USING (inventory_id)
GROUP BY store.store_id;

-- 31:  Para cada actor, cuenta cuántas películas tiene y muestra solo los que superan 15 películas.

SELECT 
    actor.actor_id AS actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS nombre_actor,
    COUNT(fa.film_id) AS total_peliculas
FROM
    actor
        JOIN
    film_actor fa USING (actor_id)
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name)
HAVING COUNT(fa.film_id) > 15;

-- 32:  Para cada categoría (por nombre), cuenta cuántas películas hay en esa categoría.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS categoria,
    COUNT(fc.film_id) AS total_peliculas
FROM
    category ca
        JOIN
    film_category fc USING (category_id)
GROUP BY ca.category_id , ca.name;

-- 33:  Para cada película, cuenta cuántos alquileres se han hecho de sus copias.

SELECT 
    film.film_id AS pelicula_id,
    film.title AS titulo,
    COUNT(rental.rental_id) AS total_alquileres
FROM
    film
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
GROUP BY film.film_id , film.title;

-- 34:  Para cada cliente, suma el importe pagado en 2005 y filtra clientes con total >= 150.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS nombre_cliente,
    SUM(pa.amount) AS importe_total
FROM
    customer cu
        JOIN
    payment pa ON cu.customer_id = pa.customer_id
        AND YEAR(payment_date) = '2005'
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name)
HAVING SUM(pa.amount) >= 150;

-- 35:  Para cada tienda, suma el importe cobrado por todos sus empleados.

SELECT 
    store.store_id AS tienda, SUM(pa.amount) AS total_cobrado
FROM
    store
        JOIN
    staff USING (store_id)
        JOIN
    payment pa USING (staff_id)
GROUP BY store.store_id;

-- 36:  Para cada ciudad, cuenta cuántos empleados residen ahí (staff -> address -> city).

SELECT 
    city.city_id AS ciudad_id,
    city.city AS ciudad,
    COUNT(staff.staff_id) AS num_empleados
FROM
    city
        JOIN
    address USING (city_id)
        JOIN
    staff USING (address_id)
GROUP BY city.city_id , city.city;

use sakila;

-- 37:  Para cada ciudad, cuenta cuántas tiendas existen (store -> address -> city).

SELECT 
    city.city_id AS ciudad_id,
    city.city AS ciudad,
    COUNT(store.store_id) AS total_tiendas
FROM
    city
        JOIN
    address USING (city_id)
        JOIN
    store USING (address_id)
GROUP BY city.city_id , city.city;

-- 38:  Para cada actor, calcula la duración media de sus películas del año 2006.

SELECT 
    actor.actor_id AS actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS nombre_actor,
    AVG(film.length) AS duracion_media
FROM
    actor
        JOIN
    film_actor USING (actor_id)
        JOIN
    film USING (film_id)
WHERE
    release_year = '2006'
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

select * from film limit 5;

-- 39:  Para cada categoría, calcula la duración media y muestra solo las que superan 120.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS nombre_categoria,
    AVG(film.length) AS duracion_media
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
GROUP BY ca.category_id , ca.name
HAVING AVG(film.length) > 120;

-- 40:  Para cada idioma, suma las tarifas de alquiler (rental_rate) de todas sus películas.

SELECT 
    la.language_id AS idioma_id,
    la.name AS idioma,
    SUM(film.rental_rate) AS total_tarifas_alquiler
FROM
    language la
        JOIN
    film ON la.language_id = film.language_id or la.language_id = film.original_language_id
GROUP BY la.language_id , la.name;

select count(*) from film;
select sum(rental_rate) from film;
select distinct(rental_rate) from film;

-- 41:  Para cada cliente, cuenta cuántos alquileres realizó en fines de semana (SÁB-DO) usando DAYOFWEEK (1=Domingo).

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS nombre_cliente,
    COUNT(rental.rental_id) AS alquileres_fin_de_semana
FROM
    customer cu
        JOIN
    rental USING (customer_id)
WHERE
    DAYOFWEEK(rental_date) IN (1 , 7)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 42:  Para cada actor, muestra el total de títulos distintos en los que participa (equivale a COUNT DISTINCT, sin subconsulta)

SELECT 
    actor.actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS nombre_actor,
    COUNT(DISTINCT film.title) AS titulos_que_participa
FROM
    actor
        JOIN
    film_actor USING (actor_id)
        JOIN
    film USING (film_id)
GROUP BY actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

-- 43:  Para cada ciudad, cuenta cuántos clientes residen ahí (customer -> address -> city).

SELECT 
    city.city_id AS ciudad_id,
    city.city AS ciudad,
    COUNT(cu.customer_id) AS clientes_totales
FROM
    city
        JOIN
    address USING (city_id)
        JOIN
    customer cu USING (address_id)
GROUP BY city.city_id , city.city;

-- 44:  Para cada categoría, muestra cuántos actores distintos participan en películas de esa categoría.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS nombre_categoria,
    COUNT(DISTINCT fa.actor_id)
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
        JOIN
    film_actor fa USING (film_id)
GROUP BY ca.category_id , ca.name;

-- 45:  Para cada tienda, cuenta cuántas copias totales (inventario) tiene de películas en 2006.

SELECT 
    store.store_id AS tienda,
    COUNT(inv.inventory_id) AS copias_totales_2006
FROM
    store
        JOIN
    inventory inv USING (store_id)
        JOIN
    film ON inv.film_id = film.film_id
        AND release_year = '2006'
GROUP BY store.store_id;

-- 46:  Para cada cliente, suma el total pagado por alquileres cuyo empleado pertenece a la tienda 1.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS nombre_cliente,
    SUM(pa.amount) AS total_pagado
FROM
    customer cu
        JOIN
    payment pa ON cu.customer_id = pa.customer_id
        JOIN
    staff ON pa.staff_id = staff.staff_id
        AND staff.store_id = 1
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 47:  Para cada película, cuenta cuántos actores tienen el apellido de longitud >= 5.

SELECT 
    film.film_id AS pelicula_id,
    film.title AS titulo,
    COUNT(actor.actor_id) AS cantidad_actores
FROM
    film
        JOIN
    film_actor USING (film_id)
        JOIN
    actor USING (actor_id)
WHERE
    LENGTH(last_name) >= 5
GROUP BY film.film_id , film.title;

-- 48:  Para cada categoría, suma la duración total (length) de sus películas.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS nombre_categoria,
    SUM(film.length) AS duracion_total
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
GROUP BY ca.category_id , ca.name;

-- 49:  Para cada ciudad, suma los importes pagados por clientes que residen en esa ciudad.

SELECT 
    city.city_id AS ciudad_id,
    city.city AS ciudad,
    SUM(pa.amount) AS importes_pagados
FROM
    city
        JOIN
    address USING (city_id)
        JOIN
    customer USING (address_id)
        JOIN
    payment pa USING (customer_id)
GROUP BY city.city_id , city.city;

-- 50:  Para cada idioma, cuenta cuántos actores distintos participan en películas de ese idioma.

SELECT 
    la.language_id AS idioma_id,
    la.name AS idioma,
    COUNT(DISTINCT fa.actor_id) AS actores_participantes
FROM
    language la
        JOIN
    film ON la.language_id = film.language_id
        JOIN
    film_actor fa USING (film_id)
GROUP BY la.language_id , la.name;






