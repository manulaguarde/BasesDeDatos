-- Consultas SQL con JOINs en la base de datos Sakila
-- Consulta 1: Clientes con al menos un alquiler
-- El gerente de la tienda desea conocer qué clientes han realizado alquileres de películas,
-- sin incluir a aquellos que no han alquilado nada.

SELECT 
    cu.customer_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS nombre_completo,
    COUNT(rental.rental_id) AS cantidad_alquileres
FROM
    customer cu
        JOIN
    rental USING (customer_id)
WHERE
    store_id = 1 -- no esta en el enunciado pero de esta manera da el resultado esperado
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name)
ORDER BY cantidad_alquileres DESC
LIMIT 10;


-- Consulta 2: Todos los clientes y sus alquileres
-- El encargado de atención al cliente quiere un listado de todos los clientes registrados en el almacén 1 y el número de alquileres que han hecho,
-- incluyendo clientes sin alquileres.

SELECT 
    cu.customer_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS cliente,
    cu.store_id AS almacen_1,
    COUNT(rental.rental_id) AS total_alquileres
FROM
    customer cu
        LEFT JOIN
    rental USING (customer_id)
WHERE
    cu.store_id = 1
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name)
LIMIT 10;


-- Consulta 3: Actores y sus películas
-- El gerente de casting necesita un reporte de los actores y las películas en las que han actuado.
-- Además, quiere incluir actores que aún no han participado en ninguna película.
SELECT 
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS nombre_actor,
    f.title AS titulo_pelicula
FROM
    actor a
        LEFT JOIN
    film_actor USING (actor_id)
        LEFT JOIN
    film f USING (film_id)
LIMIT 234;

-- Consulta 4: Categorías y películas
-- El analista de inventario requiere un informe que muestre todas las categorías de películas
-- junto con las películas asignadas a cada categoría.
-- Es posible que existan categorías sin ninguna película asignada y (aunque en Sakila es poco común) películas sin categoría.
SELECT 
    ca.category_id, ca.name AS categoria, f.title AS pelicula
FROM
    category ca
        LEFT JOIN
    film_category USING (category_id)
        LEFT JOIN
    film f USING (film_id) 
UNION SELECT 
    ca.category_id,
    ca.name AS nombre_categoria,
    f.title AS titulo_pelicula
FROM
    category ca
        RIGHT JOIN
    film_category USING (category_id)
        RIGHT JOIN
    film f USING (film_id)
LIMIT 10;

-- Consulta 5: Películas y sus actores
-- El director de contenido quiere un listado de las películas y los actores que participan en cada una,
-- pero incluyendo películas que aún no tengan actor asignado.
SELECT 
    f.film_id,
    f.title AS titulo_pelicula,
    a.actor_id,
    CONCAT(a.first_name, ' ', a.last_name) AS nombre_actor
FROM
    film f
        LEFT JOIN
    film_actor USING (film_id)
        LEFT JOIN
    actor a USING (actor_id)
LIMIT 10;