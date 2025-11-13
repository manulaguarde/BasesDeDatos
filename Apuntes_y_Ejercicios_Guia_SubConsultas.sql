-- ======= 1 SUBCONSULTAS EN LA CLÁUSULA WHERE========


SELECT 
    title
FROM
    film
WHERE
    language_id = (SELECT -- la subconsulta interna devuelve el language_id del idioma cuyo name es 'English'
            language_id
        FROM
            language
        WHERE
            name = 'English');

-- la consulta externa selecciona todas las peliculas cuyo language_id coincide con ese valor
-- este tipo de subconsulta es escalar (devuelve un valor único) y usamos el operador = para compararlo
-- en las subconsultas escalares si o si tiene que devolver una fila
-- -------------------------------------------------------------------------------------
-- ====Comparar un valor agregado:====
-- listar las películas más largas que la duracion media de todas las películas

SELECT 
    title, length
FROM
    film
WHERE
    length > (SELECT  -- primero calculamos la duracion media usando una subconsulta sobre la propia tabla film
            AVG(length)
        FROM
            film); -- y luego filtrar usando ese promedio
            
-- la subconsulta calcula la duracion media de todas las peliculas.
-- la consulta externa filtra las peliculas cuya duración es mayor a dicha media
-- ------------------------------------------------------------------------------------------
-- =====USO DE 'IN' PARA SUBCONSULTAS QUE DEVUELVEN CONJUNTOS=====
-- usamos IN si la subconsulta puede devolver múltiples filas (o su negación NOT IN)

-- obtener los nombres de todos los actores que actuan en la pelicula "ALONE TRIP"

SELECT 
    first_name, last_name
FROM
    actor
WHERE
    actor_id IN -- usamos IN poruqe la subconsulta de film_actor puede devolver múltiples filas 
    (SELECT -- obtiene todos los actor_id que participaron en la pelicula con film_id de 'ALONE TRIP'
            actor_id
        FROM
            film_actor
        WHERE
            film_id = (SELECT -- encuentra el film_id de la pelicula 'ALONE TRIP'
                    film_id
                FROM
                    film
                WHERE
                    title = 'ALONE TRIP'));

-- Si la pelicula tiene 5 actores, la condicion actor_id IN verificara la pertenencia
-- de cada actor_id a esos 5 valores. Esta solucion evita tener que escribir un JOIN múltiple.
-- si la subconsulta no encuentra ninguna fila la condicion IN no coincidira con ningun valor (actuara como condicion vacia)
-- en cambio la subconsulta escalar con '=' producira un valor NULL haciendo que la condicion falle para todas las filas.

-- ======Subconsultas con ANY, ALL y comparaciones avanzadas======

-- ------------------------------------------------------------------------------------------------
-- Listar las películas cuya duración es mayor que la de alguna película de la categoría Sports

SELECT 
    title, length
FROM
    film
WHERE
    length > ANY -- compara film.length con cada valor de ese conjunto (de la subconsulta)
    (SELECT		-- y sera verdadero si la longitud de la plicula externa es mayor que AL MENOS UNO de los valores devueltos en la subconsulta
            f2.length
        FROM
            film f2
                JOIN
            film_category fc ON f2.film_id = fc.film_id
                JOIN
            category c ON fc.category_id = c.category_id
        WHERE
            c.name = 'Sports'); -- la subconsulta devuelve las longitudes de todas las peliculas de 'Sports' 
            
-- ----------------------------------------------------------------------------------------------------------
-- ====Encontrar las películas más largas que todas las películas de Sports (es decir, mas largas que al duracion máxima de Sports)======
-- para esta consulta usamos ALL

SELECT 
    title, length
FROM
    film
WHERE
    length > ALL -- la condicion solo sera verdadera para aquellas peliculas cuya duracion es mayor que la maxima duracion de peliculas Sports
    (SELECT 
            f2.length
        FROM
            film f2
                JOIN
            film_category fc ON f2.film_id = fc.film_id
                JOIN
            category c ON fc.category_id = c.category_id
        WHERE
            c.name = 'Sports');

-- si la pelicula mas larga del catalogo fuera de Sports el resultado sería vacío.

-- condicion > ANY (subconsulta): Verdadero si la condicion se cumple con al menos un valor del conjunto devuelto
-- condicion > ALL (subconsulta): Verdaddero solo si se cumple con todos los valores del conjunto (es más estricta)

-- -------------------------------------------------------------------------------------------------------------------

-- =========  2 SUBCONSULTAS CORRELACIONADAS (EXISTS y NOT EXISTS) ================

-- ===EXISTS===
-- clientes que al menos hayan realizado un alquier.
SELECT 
    first_name, last_name
FROM
    customer c -- la consulta externa selecciona todos los clientes
WHERE
    EXISTS( SELECT  -- y la interna busca que haya coincidencia entre el customer id de la tabla customer con el customer id de la tabla rental
            1 -- podria utilizar tambien *
        FROM
            rental r
        WHERE
            r.customer_id = c.customer_id); -- ¿existe al menos una fila en el resultado de subconsulta?

-- si hay coincidencia pasa el filtro de exist y devuelve el cliente que tiene al menos un alquiler

-- ===NOT EXISTS===
-- peliculas (con sus copias) que nunca han sido alquiladas

SELECT 
    title
FROM
    film f -- recorre todas las películas de la tabla film
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            inventory i
                JOIN
            rental AS r USING (inventory_id) -- encuentra cualquier alquiler que le corresponda una copia
        WHERE
            i.film_id = f.film_id); -- vuelve a comparar la existencia  del alquiler con la pelicula mediante film_id pero ahora devuelve el dato si este no existe

-- el resultado es la lista de titulos de las peliculas nunca rentadas

-- Otro uso típico de subconsultas correlacionadas con NOT EXISTS es para preguntas del tipo "para cada X
-- que cumpla una condicion con todos los Y relacionados"

-- Ej: actores que han participado en todas las categorías de peliculas

SELECT 
    a.actor_id, a.first_name, a.last_name
FROM
    actor a
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            category c
        WHERE
            NOT EXISTS( SELECT 
                    1
                FROM
                    film_actor fa
                        JOIN
                    film_category fc USING (film_id)
                WHERE
                    fa.actor_id = a.actor_id
                        AND fc.category_id = c.category_id));
                        
-- (ESTA TENGO QUE REPASARLA PORQUE NO LO ENTENDI MUY BIEN)

-- lo importante es notar la doble negacion "no existe una categoria tal que no exista una pelicula de ese actor en dicha categoria"
-- equivale a "el actor tiene al menos una película en cada categoría"

-- ====2.1 Algunos ejemplos mas====

-- Ej 1: Peliculas de la categoria "children" (camino y pasos)
-- camino de tablas: category->film_category->film
-- Paso 1: obtener category_id de "Children"

SELECT 
    category_id
FROM
    category
WHERE
    name = 'Children'; -- id=3
    
-- Paso 2: con ese category_id, obtener film_id en film_category

SELECT 
    film_id
FROM
    film_category
WHERE
    category_id = 3; -- todos los film_id en la tabla film_category que concidan con el category_id '3'

-- Paso 3: filtrar film con IN (lista de film_id)

SELECT 
    title
FROM
    film -- mostramos todas las películas (titulos)
WHERE
    film_id IN (SELECT -- donde film_id esté en la tabla film_category
            film_id
        FROM
            film_category
        WHERE
            category_id = (SELECT -- pero además que el id de la categoria sea 3
                    category_id
                FROM
                    category
                WHERE
                    name = 'Children')); -- osea todas las peliculas cuyo id esté relacionado con el id '3' de la categoria (que pertenece a children)
                    
-- SUBCONSULTAS CORRELACIONADAS CON EXISTS

-- a veces la condicion de filtrado requiere verificar la existencia o ausencia de las filas relacionadas
-- para cada fila de la consulta externa. Para esos casos se usa EXISTS y NOT EXISTST

-- Ejemplo 2: Películas nunca aluiladas (camino y pasos).
-- Camino de tablas: film->(anti-join) inventory -> rental

-- Paso 1: consulta exterior:

select f.film_id, f.title
from film f;

-- Paso 2: subconsulta sin correlación (estructura mínima)

SELECT 
    1
FROM
    inventory i
        JOIN
    rental r USING (inventory_id); -- creo que 1 es donde haya coincidencia (devuelve 1)

-- Paso 3: correlacionar con la fila exterior (i.film_id = f.film_id)

SELECT 
    1
FROM
    inventory i
        JOIN
    rental r USING (inventory_id)
WHERE
    i.film_id = f.film_id;
    
-- Paso 4: usar NOT EXISTS

SELECT 
    f.film_id, f.title
FROM
    film f
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            inventory i
                JOIN
            rental r USING (inventory_id)
        WHERE
            i.film_id = f.film_id)
ORDER BY f.title;

-- Ejemplo 3: Actores con alguna película de length > 120 (camino y pasos)
-- camino de tablas: actor->film_actor->film
-- Paso 1: exterior

SELECT 
    a.actor_id, a.first_name, a.last_name
FROM
    actor a;
    
-- Paso 2: subconsulta sin correlación (estructura mínima)

SELECT 
    1
FROM
    film_actor fa
        JOIN
    film f USING (film_id)
WHERE
    f.length > 120;
    
-- Paso 3: correlacionar con la fila exterior

SELECT 
    1
FROM
    film_actor fa
        JOIN
    film f USING (film_id)
WHERE
    fa.actor_id = a.actor_id
        AND f.length > 120;

-- Paso 4: usar EXISTS

SELECT 
    a.actor_id, a.first_name, a.last_name
FROM
    actor a
WHERE
    EXISTS( SELECT 
            1
        FROM
            film_actor fa
                JOIN
            film f USING (film_id)
        WHERE
            fa.actor_id = a.actor_id
                AND f.length > 120)
ORDER BY a.last_name , a.first_name;

-- ====SUBCONSULTAS EN LA LISTA SELECT (campos calculados por fila)====

-- se colocan en el select como parte de columnas calculadas en la salida, deben ser de tipo escalar (devuelven un unico valor por cada fila externa)
-- Ej: mostrar cada película junto con el número total de veces que ha sido alquilada.

SELECT 
    f.title,
    (SELECT 
            COUNT(*) -- cuenta todos los film_id (de las copias en inventory) que tienen al menos un alquiler
        FROM
            rental r
                JOIN
            inventory i USING (inventory_id) 
        WHERE
            i.film_id = f.film_id) AS total_rentals -- se muestra como columna el resultado de la subconsulta
FROM
    film f;

-- esta manera es equivalente a hacer un join con rental e inventory y agruparlo con film
-- pero a veces la subconsulta resulta más sencilla de entender "para esta pelicula, calcula este dato agregado"

