-- Consultas SQL con JOINs en la base de datos Sakila
-- Consulta 1: Clientes con al menos un alquiler
-- El gerente de la tienda desea conocer qué clientes han realizado alquileres de películas, sin incluir a aquellos que no han alquilado nada.

SELECT 
    cu.customer_id,
    CONCAT(cu.first_name, ' ', cu.last_name) AS nombre_completo,
    COUNT(rental.rental_id) AS cantidad_alquileres
FROM
    customer cu
        INNER JOIN
    rental USING (customer_id)
GROUP BY cu.customer_id , CONCAT(cu.first_name, ' ', cu.last_name)
ORDER BY cantidad_alquileres DESC;


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
ORDER BY total_alquileres ASC;


-- Consulta 3: Actores y sus películas
-- El gerente de casting necesita un reporte de los actores y las películas en las que han actuado. Además, quiere incluir actores que aún no han participado en ninguna película.



-- Consulta 4: Categorías y películas
-- El analista de inventario requiere un informe que muestre todas las categorías de películas junto con las películas asignadas a cada categoría.
-- Es posible que existan categorías sin ninguna película asignada y (aunque en Sakila es poco común) películas sin categoría.


-- Consulta 5: Películas y sus actores
-- El director de contenido quiere un listado de las películas y los actores que participan en cada una, pero incluyendo películas que aún no tengan actor asignado.