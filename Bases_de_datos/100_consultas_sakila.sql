-- 1:  Para cada actor, muestra el número total de películas en las que aparece;
-- es decir, cuenta cuántas filas de film_actor corresponden a cada actor.

SELECT 
    actor.actor_id as actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS nombre_actor,
    COUNT(fa.film_id) AS peliculas_totales
FROM
    actor
        JOIN
    film_actor fa USING (actor_id)
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

-- Comentarios: selecciono cada actor y cuento las peliculas totales, en el join uniendo estas dos tablas se muestran para cada actor que pelicula esta asociada y agrupo por actor 

-- 2:  Lista solo los actores que participan en 20 o más películas (umbral alto) con su conteo.

SELECT 
	actor.actor_id as actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS nombre_actor,
    COUNT(fa.film_id) AS participaciones_totales
FROM
    actor
        JOIN
    film_actor fa USING (actor_id)
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name)
HAVING COUNT(fa.film_id) >= 20;

-- Comentarios: consulta similar a la anterior pero añadiendo un filtro con having (porque es sobre el conteo de las peliculas) donde la participacion del actor sea mayor o igual a 20

-- 3:  Para cada idioma, indica cuántas películas están catalogadas en ese idioma.

SELECT 
    la.language_id AS idioma_id,
    la.name AS idioma,
    COUNT(film.film_id) AS total_peliculas
FROM
    language la
        JOIN
    film ON film.language_id = la.language_id
GROUP BY la.language_id, la.name;

-- Comentarios: selecciono los idiomas (que solo hay uno) y cuento peliculas luego al unir ambas tablas aparecen cuantas peliculas estan asociadas a ese idioma (en este caso todas en ingles)

-- 4:  Muestra el promedio de duración (length) de las películas por idioma y 
-- filtra aquellos idiomas con duración media estrictamente mayor a 110 minutos.

SELECT 
    la.language_id,
    la.name AS idioma,
    AVG(film.length) AS duracion_media
FROM
    language la
        JOIN
    film ON film.language_id = la.language_id
GROUP BY la.language_id , la.name
HAVING AVG(film.length) > 110;

-- Comentarios: calculo el promedio de duración (length) de las películas agrupadas por idioma, usando HAVING para mostrar solo aquellos idiomas cuyo promedio supera los 110 minutos.

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

-- Comentarios:muestro cada película junto con la cantidad de copias disponibles en el inventario. El JOIN vincula las películas con los registros del inventario y el COUNT contabiliza las copias por título.

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

-- Comentario: misma lógica que la anterior, pero agregando un filtro HAVING para mostrar únicamente las películas con 5 o más copias disponibles.

-- 7:  Para cada artículo de inventario, cuenta cuántos alquileres se han realizado.

SELECT 
    inv.inventory_id AS inventario_id,
    COUNT(rental.rental_id) AS total_alquileres
FROM
    inventory inv
        JOIN
    rental USING (inventory_id)
GROUP BY inv.inventory_id;

-- Comentario: muestro cada artículo del inventario (cada copia) y cuántas veces ha sido alquilado. El conteo se hace sobre rental_id, agrupando por inventory_id.

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

-- Comentario: muestro cada cliente junto con la cantidad total de alquileres realizados. La unión con rental permite contar los alquileres por cliente.

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

-- Comentario: igual que la anterior, pero aplicando un filtro con HAVING para mostrar solo los clientes que tienen 30 o más alquileres acumulados.

-- 10:  Para cada cliente, muestra el total de pagos (suma en euros/dólares) que ha realizado.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    SUM(pa.amount) AS total_pagos
FROM
    customer cu
        JOIN
    payment pa USING (customer_id)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- Comentario: calculo cuánto ha pagado en total cada cliente sumando todos sus pagos (amount). El JOIN une cada cliente con sus registros de pago.

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

-- Comentario: similar a la anterior, pero filtrando con HAVING los clientes cuyo total de pagos acumulado es igual o superior a 200.

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

-- Comentario: muestro cada empleado y la cantidad de pagos que ha procesado. El conteo se realiza sobre la columna amount de la tabla payment, agrupando por empleado.

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

-- Comentario: muestra cuánto dinero ha gestionado en total cada empleado, sumando los importes (amount) de los pagos que procesó.

-- 14:  Para cada tienda, cuenta cuántos artículos de inventario tiene.

SELECT 
    store.store_id AS tienda,
    COUNT(inv.inventory_id) AS copias_totales
FROM
    store
        JOIN
    inventory inv USING (store_id)
GROUP BY store.store_id;

-- Comentario: cuenta cuántos artículos de inventario (copias de películas) pertenecen a cada tienda. El COUNT se aplica sobre los inventory_id agrupados por store_id

-- 15:  Para cada tienda, cuenta cuántos clientes tiene asignados.
SELECT 
    store.store_id AS tienda,
    COUNT(cu.customer_id) AS total_clientes
FROM
    store
        JOIN
    customer cu USING (store_id)
GROUP BY store.store_id;

-- Comentario: muestra cuántos clientes están asociados a cada tienda. El conteo se hace sobre customer_id agrupando por tienda.

-- 16: Para cada tienda, cuenta cuántos empleados (staff) tiene asignados.
SELECT 
    store.store_id AS tienda,
    COUNT(staff.staff_id) AS total_empleados
FROM
    store
        JOIN
    staff USING (store_id)
GROUP BY store.store_id;

-- Comentario: cuenta el número de empleados que trabajan en cada tienda. El JOIN enlaza las tablas store y staff según store_id.

-- 17:  Para cada dirección (address), cuenta cuántas tiendas hay ubicadas ahí (debería ser 0/1 en datos estándar).

SELECT 
    ad.address_id AS direccion_id,
    ad.address AS direccion,
    COUNT(store.store_id) as total_tiendas
FROM
    address ad
        JOIN
    store USING (address_id)
GROUP BY ad.address_id , ad.address;

-- Comentario: muestra cuántas tiendas están ubicadas en cada dirección. Normalmente cada dirección solo debería tener una tienda (resultado 0 o 1).

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

-- Comentario: indica cuántos empleados residen en cada dirección. El JOIN une address con staff por address_id y se agrupa por dirección.

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

-- Comentario: muestra cuántos clientes viven en cada dirección. Se cuentan los clientes asociados a cada address_id.

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

-- Comentario: cuenta cuántas direcciones están registradas en cada ciudad, uniendo city con address mediante city_id.

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

-- Comentario: muestra cuántas ciudades existen en cada país. Se realiza un JOIN entre country y city, agrupando por país.

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

-- Comentario: Muetra cual es la duracion media de las peliculas por idiomas, y solo las que la media este entre 90 y 120 min.


-- 23:  Para cada película, cuenta el número de alquileres que se han hecho de cualquiera de sus copias (usando inventario).

SELECT 
    inv.film_id AS pelicula_id,
    film.title AS titulo,
    COUNT(rental.rental_id) AS total_alquileres
FROM
    film
        JOIN
    inventory inv USING (film_id)
        JOIN
    rental USING (inventory_id)
GROUP BY inv.film_id;

-- Comentario: Muestra el número de alquileres totales que tuvo cada pelicula, uniendo con el inventario donde estan las copias de las peliculas

use sakila;

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

-- Comentario: Muestra la cantidad de pagos que se realizaron por cada cliente en 2005

-- 25:  Para cada película, muestra el promedio de tarifa de alquiler (rental_rate)
-- de las copias existentes (es un promedio redundante pero válido).

SELECT 
    film.film_id AS inventario_id,
    film.title AS pelicula,
    AVG(film.rental_rate) AS promedio_tarifa_alquiler
FROM
    film
GROUP BY film.film_id , film.title;

-- Comentario: Muestra el promedio de la ganancia por película alquilada

-- 26:  Para cada actor, muestra la duración media (length) de sus películas.

SELECT 
    actor.actor_id AS actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS actor,
    AVG(film.length) AS duracion_media
FROM
    actor
        JOIN
    film_actor USING (actor_id)
        JOIN
    film USING (film_id)
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

-- Comentario: Aqui se muestra la duracion media que tienen las peliculas donde aparecen cada actor

-- 27:  Para cada ciudad, cuenta cuántos clientes hay (usando la relación cliente->address->city requiere 3 tablas;
-- aquí contamos direcciones por ciudad).

SELECT 
   city.city_id AS ciudad_id,
   city.city AS ciudad,
   COUNT(cu.customer_id) AS total_clientes
	-- COUNT(ad.address_id) AS total_direcciones
FROM
    city
        JOIN
    address ad USING (city_id)
        JOIN
    customer cu USING (address_id)
GROUP BY city.city_id , city.city
ORDER BY city_id;


-- Comentario: Aqui uno ciudad con dirrecciones y con cliente y cuento clientes, de esta manera cuenta cuantos clientes hay en cada ciudad
-- el resultado espera que tambien se cuenten las direcciones que no tienen clientes registrados, como las del staff o las tiendas, pero no es lo que solicita el enunciado 

-- 28:  Para cada película, cuenta cuántos actores tiene asociados.

SELECT 
    film.film_id AS pelicula_id,
    film.title AS pelicula,
    COUNT(film_actor.actor_id) AS actores_participantes
FROM
    film
        JOIN
    film_actor USING (film_id)
GROUP BY film.film_id , film.title;

-- Muestra cuantos actores estan asociados, participan, de cada pelicula

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

-- 51:  Para cada tienda, cuenta cuántos clientes activos (active=1) tiene.

SELECT 
    store.store_id AS tienda,
    COUNT(cu.active) AS total_clientes_activos
FROM
    store
        JOIN
    customer cu USING (store_id)
WHERE
    cu.active = 1
GROUP BY store.store_id;

-- 52:  Para cada cliente, cuenta en cuántas categorías distintas ha alquilado
-- (aprox. vía film_category; requiere 4 tablas, aquí contamos películas que se alquilaron 2006 por inventario).

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS nombre_cliente,
    COUNT(DISTINCT fc.category_id) AS categorias_distintas
FROM
    customer cu
        JOIN
    rental USING (customer_id)
        JOIN
    inventory USING (inventory_id)
        JOIN
    film USING (film_id)
        JOIN
    film_category fc USING (film_id)
WHERE
    YEAR(rental.rental_date) = '2006'
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- aqui hice una correccion del enunciado, porque en principio parece que pide películas que son del 2006 y no los alquileres que se efectuaron en 2006

-- 53:  Para cada empleado, cuenta cuántos clientes diferentes le han pagado.

SELECT 
    staff.staff_id AS empleado_id,
    CONCAT(staff.first_name, ' ', staff.last_name) AS nombre_empleado,
    COUNT(DISTINCT payment.customer_id) AS total_clientes_que_pagaron
FROM
    staff
        JOIN
    payment USING (staff_id)
GROUP BY staff.staff_id , CONCAT(staff.first_name, ' ', staff.last_name);

-- 54:  Para cada ciudad, cuenta cuántas películas que han sido alquiladas en 2006 por residentes en esa ciudad.

SELECT 
    city.city_id AS ciudad_id,
    city.city AS nombre_ciudad,
    COUNT(rental.inventory_id) AS peliculas_alquiladas_2006
FROM
    city
        JOIN
    address USING (city_id)
        JOIN
    customer USING (address_id)
        JOIN
    rental USING (customer_id)
WHERE
    YEAR(rental.rental_date) = '2006'
GROUP BY city.city_id , city.city;

-- En este pasa similar que en la consuta 52, se espera segun el resultado que se filtre por el año que fueron alquiladas pero el 
-- enunciado original da a entender que se filtre por el año de estreno

-- 55:  Para cada categoría, calcula el promedio de replacement_cost de sus películas.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS categoria,
    AVG(film.replacement_cost) AS media_coste_de_reemplazo
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
GROUP BY ca.category_id , ca.name;

-- 56:  Para cada tienda, suma los importes cobrados en 2006 (vía empleados de esa tienda).

SELECT 
    staff.store_id AS tienda,
    SUM(pa.amount) AS imortes_cobrados_2006
FROM
    staff
        JOIN
    payment pa USING (staff_id)
WHERE
    YEAR(pa.payment_date) = '2006'
GROUP BY staff.store_id;

-- 57:  Para cada actor, cuenta cuántas películas tienen título de más de 12 caracteres.

SELECT 
    actor.actor_id AS actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS nombre_actor,
    COUNT(film.film_id) AS total_peliculas
FROM
    actor
        JOIN
    film_actor USING (actor_id)
        JOIN
    film USING (film_id)
WHERE
    LENGTH(film.title) > 12
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

-- 58:  Para cada ciudad, calcula la suma de pagos de 2005 y filtra las ciudades con total >= 300.

SELECT 
    city.city_id AS ciudad_id,
    city.city AS nombre_ciudad,
    SUM(pa.amount) AS total_pagos
FROM
    city
        JOIN
    address USING (city_id)
        JOIN
    customer USING (address_id)
        JOIN
    payment pa USING (customer_id)
WHERE
    YEAR(payment_date) = '2005'
GROUP BY city.city_id , city.city
HAVING SUM(pa.amount) >= 300;

-- 59:  Para cada categoría, cuenta cuántas películas tienen rating 'PG' o 'PG-13'.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS nombre_categoria,
    COUNT(film.film_id) AS peliculas_pg_pg13
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
WHERE
    rating LIKE 'PG%'
GROUP BY ca.category_id , ca.name;

-- 60:  Para cada cliente, calcula el total pagado en pagos procesados por el empleado 2.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS nombre_cliente,
    SUM(pa.amount) AS total_pagado
FROM
    customer cu
        JOIN
    payment pa USING (customer_id)
WHERE
    staff_id = 2
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 61:  Para cada ciudad, cuenta cuántos clientes hay y muestra solo ciudades con 10 o más clientes.

SELECT 
    city.city_id AS ciudad_id,
    city.city AS nombre_ciudad,
    COUNT(customer_id) AS total_clientes_por_ciudad
FROM
    city
        JOIN
    address USING (city_id)
        JOIN
    customer USING (address_id)
GROUP BY city.city_id , city.city
HAVING COUNT(customer_id) >= 10;

-- 62:  Para cada actor, cuenta cuántos alquileres totales suman todas sus películas.

SELECT 
    actor.actor_id AS actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS nombre_actor,
    COUNT(rental_id) AS alquileres_totales
FROM
    actor
        JOIN
    film_actor USING (actor_id)
        JOIN
    film USING (film_id)
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

-- 63:  Para cada categoría, suma los importes pagados derivados de películas de esa categoría.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS nombre_categoria,
    SUM(pa.amount) AS importes_pagados
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
        JOIN
    payment pa USING (rental_id)
GROUP BY ca.category_id , ca.name;

-- 64:  Para cada ciudad, suma los importes pagados por clientes residentes en esa ciudad en 2005.

SELECT 
    city.city_id AS ciudad_id,
    city.city AS ciudad,
    SUM(pa.amount) AS importes_pagados_por_ciudad
FROM
    city
        JOIN
    address USING (city_id)
        JOIN
    customer USING (address_id)
        JOIN
    payment pa USING (customer_id)
WHERE
    YEAR(payment_date) = '2005'
GROUP BY city.city_id , city.city;

-- 65:  Para cada tienda, cuenta cuántos actores distintos aparecen en las películas de su inventario.

SELECT 
    store.store_id AS tienda,
    COUNT(DISTINCT fa.actor_id) AS actores_distintos_por_pelicula
FROM
    store
        JOIN
    inventory USING (store_id)
        JOIN
    film USING (film_id)
        JOIN
    film_actor fa USING (film_id)
GROUP BY store.store_id;

-- 66:  Para cada idioma, cuenta cuántos alquileres totales se han hecho de películas en ese idioma.

SELECT 
    la.language_id AS idioma_id,
    la.name AS idioma,
    COUNT(rental_id) AS alquileres_totales
FROM
    language la
        JOIN
    film USING (language_id)
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
GROUP BY la.language_id , la.name;

-- 67:  Para cada cliente, cuenta en cuántos meses distintos de 2005 realizó pagos (meses distintos).

SELECT 
    cu.customer_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    COUNT(DISTINCT MONTH(pa.payment_date)) AS meses_distintos
FROM
    customer cu
        JOIN
    payment pa USING (customer_id)
WHERE
    YEAR(pa.payment_date) = 2005
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 68:  Para cada categoría, calcula la duración media de las películas alquiladas (considerando solo películas alquiladas).

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
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
GROUP BY ca.category_id , ca.name;

-- 69:  Para cada país, cuenta cuántos clientes hay (country -> city -> address -> customer).

SELECT 
    country.country_id AS pais_id,
    country.country AS pais,
    COUNT(cu.customer_id) AS total_clientes
FROM
    country
        JOIN
    city USING (country_id)
        JOIN
    address USING (city_id)
        JOIN
    customer cu USING (address_id)
GROUP BY country.country_id , country.country;

-- 70:  Para cada país, suma los importes pagados por sus clientes.

SELECT 
    country.country_id AS pais_id,
    country.country AS pais,
    SUM(pa.amount)
FROM
    country
        JOIN
    city USING (country_id)
        JOIN
    address USING (city_id)
        JOIN
    customer USING (address_id)
        JOIN
    payment pa USING (customer_id)
GROUP BY country.country_id , country.country;

-- 71:  Para cada tienda, cuenta cuántas categorías distintas existen en su inventario.

SELECT 
    store.store_id AS tienda,
    COUNT(DISTINCT fa.category_id) AS total_categorias_distintas
FROM
    store
        JOIN
    inventory USING (store_id)
        JOIN
    film USING (film_id)
        JOIN
    film_category fa USING (film_id)
GROUP BY store.store_id;

-- 72:  Para cada tienda, suma la recaudación por categoría (resultado agregado por tienda y categoría).

SELECT 
    store.store_id AS tienda,
    category.name AS categoria,
    SUM(payment.amount) AS recaudacion
FROM
    store
        JOIN
    staff USING (store_id)
        JOIN
    payment USING (staff_id)
        JOIN
    rental USING (rental_id)
        JOIN
    inventory USING (inventory_id)
        JOIN
    film USING (film_id)
        JOIN
    film_category USING (film_id)
        JOIN
    category USING (category_id)
GROUP BY store.store_id , category.name;

-- 73:  Para cada actor, cuenta en cuántas tiendas distintas se han alquilado sus películas.

SELECT 
    actor.actor_id AS actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS actor,
    COUNT(DISTINCT inventory.store_id)
FROM
    actor
        JOIN
    film_actor USING (actor_id)
        JOIN
    film USING (film_id)
        JOIN
    inventory USING (film_id)
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

-- 74:  Para cada categoría, cuenta cuántos clientes distintos han alquilado películas de esa categoría.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS categoria,
    COUNT(DISTINCT cu.customer_id) AS clientes_que_alquilaron
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
        JOIN
    customer cu USING (customer_id)
GROUP BY ca.category_id , ca.name;

-- 75:  Para cada idioma, cuenta cuántos actores distintos participan en películas alquiladas en ese idioma.

SELECT 
    la.language_id AS idioma_id,
    la.name AS idioma,
    COUNT(DISTINCT fa.actor_id)
FROM
    language la
        JOIN
    film ON la.language_id = film.language_id
        JOIN
    film_actor fa USING (film_id)
GROUP BY la.language_id , la.name;

-- 76:  Para cada país, cuenta cuántas tiendas hay (país->ciudad->address->store).

SELECT 
    co.country_id AS pais_id,
    co.country AS pais,
    COUNT(store.store_id)
FROM
    country co
        JOIN
    city USING (country_id)
        JOIN
    address USING (city_id)
        JOIN
    store USING (address_id)
GROUP BY co.country_id , co.country;

-- 77:  Para cada cliente, cuenta los alquileres en los que la devolución (return_date) fue el mismo día del alquiler.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    COUNT(rental.rental_id) AS alquileres_devueltos_mismo_dia
FROM
    customer cu
        JOIN
    rental USING (customer_id)
WHERE
    DATE(rental_date) = DATE(return_date)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 78:  Para cada tienda, cuenta cuántos clientes distintos realizaron pagos en 2005.

SELECT 
    staff.store_id AS tienda,
    COUNT(DISTINCT pa.customer_id) AS total_clientes_2005
FROM
    payment pa
        JOIN
    staff USING (staff_id)
WHERE
    YEAR(pa.payment_date) = 2005
GROUP BY staff.store_id;

-- 79:  Para cada categoría, cuenta cuántas películas con título de longitud > 15 han sido alquiladas.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS categoria,
    COUNT(rental.rental_id) AS total_peliculas
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
WHERE
    LENGTH(film.title) > 15
GROUP BY ca.category_id , ca.name;

-- 80:  Para cada país, suma los pagos procesados por los empleados de las tiendas ubicadas en ese país.

SELECT 
    co.country_id AS pais_id,
    co.country AS pais,
    SUM(pa.amount) AS pagos_procesados
FROM
    country co
        JOIN
    city USING (country_id)
        JOIN
    address USING (city_id)
        JOIN
    store USING (address_id)
        JOIN
    staff USING (store_id)
        JOIN
    payment pa USING (staff_id)
GROUP BY co.country_id , co.country;

-- 81:  Para cada cliente, muestra el total pagado con IVA teórico del 21% aplicado (total*1.21), redondeado a 2 decimales.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    ROUND(SUM((pa.amount) * 1.21), 2) AS total_pagado
FROM
    customer cu
        JOIN
    payment pa USING (customer_id)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 82:  Para cada hora del día (0-23), cuenta cuántos alquileres se iniciaron en esa hora.

SELECT 
    HOUR(rental.rental_date) AS hora_del_dia, COUNT(rental.rental_id)
FROM
    rental
GROUP BY HOUR(rental.rental_date)
ORDER BY horas;

-- 83:  Para cada tienda, muestra la media de length de las películas alquiladas en 2005 y filtra las tiendas con media >= 100.

SELECT 
    inv.store_id AS tienda,
    AVG(film.length) AS duracion_media_peli_2005
FROM rental
JOIN inventory inv USING (inventory_id)
JOIN film  USING (film_id)
WHERE YEAR(rental.rental_date) = '2005'
GROUP BY inv.store_id
HAVING AVG(film.length) >= 100;

-- 84:  Para cada categoría, muestra la media de replacement_cost de las películas alquiladas un domingo.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS categoria,
    AVG(film.replacement_cost) AS media_coste_reemplazo
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
WHERE
    DAYOFWEEK(rental_date) = 1
GROUP BY ca.category_id , ca.name;

-- 85:  Para cada empleado, muestra el importe total por pagos realizados entre las 00:00 y 06:00 (inclusive 00:00, exclusivo 06:00).

SELECT 
    staff.staff_id AS empleado_id,
    CONCAT(staff.first_name, ' ', staff.last_name) AS nombre_empleado,
    SUM(pa.amount)
FROM
    staff
        JOIN
    payment pa USING (staff_id)
WHERE
    TIME(pa.payment_date) BETWEEN '00:00:00' AND '05:59:59'
GROUP BY staff.staff_id , CONCAT(staff.first_name, ' ', staff.last_name);

-- 86:  Para cada actor, cuenta cuántas de sus películas tienen un título que contiene la palabra 'LOVE' (mayúsculas).

SELECT 
    actor.actor_id AS actor_id,
    CONCAT(actor.first_name, ' ', actor.last_name) AS actor,
    COUNT(film.film_id) AS pelicula_amor
FROM
    actor
        JOIN
    film_actor USING (actor_id)
        JOIN
    film USING (film_id)
WHERE
    UPPER(film.title) LIKE ('%LOVE%')
GROUP BY actor.actor_id , CONCAT(actor.first_name, ' ', actor.last_name);

-- 87:  Para cada idioma, muestra el total de pagos de alquileres de películas en ese idioma.

SELECT 
    la.language_id AS idioma_id,
    la.name AS idioma,
    SUM(pa.amount) AS total_pagos_por_idioma
FROM
    language la
        JOIN
    film ON film.language_id = la.language_id
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
        JOIN
    payment pa USING (rental_id)
GROUP BY la.language_id , la.name;

-- 88:  Para cada cliente, cuenta en cuántos días distintos de 2005 realizó algún alquiler.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    COUNT(DISTINCT DATE(rental.rental_date)) AS dias_distintos_2005
FROM
    customer cu
        JOIN
    rental USING (customer_id)
WHERE
    YEAR(rental.rental_date) = '2005'
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name);

-- 89:  Para cada categoría, calcula la longitud media de títulos (número de caracteres) de sus películas alquiladas.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS categoria,
    AVG(LENGTH(film.title))
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
GROUP BY ca.category_id , ca.name;

-- 90:  Para cada tienda, cuenta cuántos clientes distintos alquilaron en el primer trimestre de 2006 (enero-marzo).

SELECT 
    inv.store_id AS tienda,
    COUNT(DISTINCT cu.customer_id) AS clientes_distintos
FROM
    inventory inv
        JOIN
    rental USING (inventory_id)
        JOIN
    customer cu USING (customer_id)
WHERE
    DATE(rental_date) BETWEEN '2006-01-01' AND '2006-03-31'
GROUP BY inv.store_id;


-- 91:  Para cada país, cuenta cuántas categorías diferentes han sido alquiladas por clientes residentes en ese país.

SELECT 
    co.country_id AS pais_id,
    co.country AS pais,
    COUNT(DISTINCT fc.category_id) total_categorias_distintas
FROM
    country co
        JOIN
    city USING (country_id)
        JOIN
    address USING (city_id)
        JOIN
    customer USING (address_id)
        JOIN
    rental USING (customer_id)
        JOIN
    inventory USING (inventory_id)
        JOIN
    film USING (film_id)
        JOIN
    film_category fc USING (film_id)
GROUP BY co.country_id , co.country;

-- 92:  Para cada cliente, muestra el importe medio de sus pagos redondeado a 2 decimales, solo si ha hecho al menos 10 pagos.

SELECT 
    cu.customer_id AS cliente_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    ROUND(AVG(pa.amount), 2) AS importe_medio
FROM
    customer cu
        JOIN
    payment pa USING (customer_id)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name)
HAVING COUNT(pa.payment_id) >= 10;

-- 93:  Para cada categoría, muestra el número de películas con replacement_cost > 20 que hayan sido alquiladas al menos una vez.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS categoria,
    COUNT(DISTINCT film.film_id) AS total_peliculas_caras
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
WHERE
    film.replacement_cost > 20
GROUP BY ca.category_id , ca.name;

-- 94:  Para cada tienda, suma los importes pagados en fines de semana.

SELECT 
    store.store_id AS tienda,
    SUM(pa.amount) AS importes_pagados_finde
FROM
    payment pa
        JOIN
    staff USING (staff_id)
        JOIN
    store USING (store_id)
        JOIN
    rental ON pa.rental_id = rental.rental_id
WHERE
    DAYOFWEEK(rental.rental_date) IN (1 , 7)
GROUP BY store.store_id;

-- 95:  Para cada actor, cuenta cuántas películas suyas fueron alquiladas por al menos 5 clientes distintos (se cuenta alquileres y luego se filtra por HAVING).

select actor.actor_id as actor_id,
concat(actor.first_name,' ',actor.last_name) as actor,
count(film.film_id)
from actor
join film_actor using (actor_id)
join film using (film_id)
join inventory using (film_id) 
join rental using (inventory_id)
group by  actor.actor_id, concat(actor.first_name,' ',actor.last_name)
having count(distinct rental.customer_id) >= 5;

-- 96:  Para cada idioma, muestra el número de películas cuyo título empieza por la letra 'A' y que han sido alquiladas.

SELECT 
    la.language_id AS idioma_id,
    la.name AS idioma,
    COUNT(DISTINCT film.film_id) AS peliculas_empizan_A
FROM
    language la
        JOIN
    film ON film.language_id = la.language_id
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
WHERE
    film.title LIKE 'A%'
GROUP BY la.language_id , la.name;


-- 97:  Para cada país, suma el importe total de pagos realizados por clientes residentes y filtra países con total >= 1000.

SELECT 
    co.country_id AS pais_id,
    co.country AS pais,
    SUM(pa.amount) AS total_pagos
FROM
    country co
        JOIN
    city USING (country_id)
        JOIN
    address USING (city_id)
        JOIN
    customer USING (address_id)
        JOIN
    payment pa USING (customer_id)
GROUP BY co.country_id , co.country
HAVING SUM(pa.amount) >= 1000;

-- 98:  Para cada cliente, cuenta cuántos días han pasado entre su primer y su último alquiler en 2005 (diferencia de fechas),
--  mostrando solo clientes con >= 5 alquileres en 2005.
--     (Se evita subconsulta calculando sobre el conjunto agrupado por cliente y usando MIN/MAX de rental_date en 2005).

select cu.customer_id as cliente_id,
concat(cu.first_name,' ',cu.last_name) as cliente,
datediff(max(rental.rental_date),min(rental.rental_date)) as dias_transcurridos_primer_ultimo_alquier
from customer cu
join rental using (customer_id)
where year(rental_date) = '2005'
group by cu.customer_id, concat(cu.first_name,' ',cu.last_name)
having datediff(max(rental.rental_date),min(rental.rental_date)) >=5;

-- 99:  Para cada tienda, muestra la media de importes cobrados por transacción en el año 2006, con dos decimales.

SELECT 
    store.store_id AS tienda,
    ROUND(AVG(pa.amount), 2) AS media_importes_cobrados
FROM
    store
        JOIN
    staff USING (store_id)
        JOIN
    payment pa USING (staff_id)
WHERE
    YEAR(pa.payment_date) = '2006'
GROUP BY store.store_id;

-- 100:  Para cada categoría, calcula la media de duración (length) de películas alquiladas en 2006 y ordénalas descendentemente por dicha media.

SELECT 
    ca.category_id AS categoria_id,
    ca.name AS categoria,
    AVG(film.length) AS duracion_media_pelis_2006
FROM
    category ca
        JOIN
    film_category USING (category_id)
        JOIN
    film USING (film_id)
        JOIN
    inventory USING (film_id)
        JOIN
    rental USING (inventory_id)
WHERE
    YEAR(rental.rental_date) = '2006'
GROUP BY ca.category_id , ca.name
ORDER BY AVG(film.length) DESC;