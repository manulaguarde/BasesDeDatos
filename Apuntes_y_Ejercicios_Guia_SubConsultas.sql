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


