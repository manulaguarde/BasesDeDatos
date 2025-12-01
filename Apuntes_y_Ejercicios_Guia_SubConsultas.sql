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
-- lo usamos cuando no nos vale un operador porque tenemos que comparar dos cosas

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

-- ------------------------------------------------------------------------------------------

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

-- ------------------------------------------------------------------------------------------

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

-- ------------------------------------------------------------------------------------------

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
        
-- ------------------------------------------------------------------------------------------       
        
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

-- ------------------------------------------------------------------------------------------

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

-- ------------------------------------------------------------------------------------------

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

-- ------------------------------------------------------------------------------------------

-- Ej: listar cada cliente con el monto total que ha pagado en todos sus alquileres

SELECT 
    c.first_name,
    c.last_name,
    (SELECT 
            SUM(p.amount)
        FROM
            payment p
               -- JOIN
           -- rental r USING (rental_id)
        WHERE
            p.customer_id = c.customer_id) AS total_pagado
FROM
    customer c;
    
-- las subconsultas correlacionadas pueden emplearse en la cláusula WHERE (usando EXISTS, NOT EXISTS, IN,etc)
-- o el la lista select como subconsultas escalares para crear columnas calculadas

-- ------------------------------------------------------------------------------------------

-- =========3 Subconsultas en la cláusula FROM (tablas derivadas)=========

-- es útil cuando queremos estructurar la consulta en pasos: primero obtener un resultado intermedio con su propia SELECT
-- y luego onsultarlo o combinarlo con otras tablas.
-- Es obligatorio asignarle un alias (porque la consulta externa debe referirse a ese resultado)

-- Ejemplo: queremos encontrar las categorías de películas que tienen más películas que el número promedio de peliculas por categoria.
-- (categorías que estan "por encima del promedio" en cuanto a cantidad de películas)

-- con agregaciones requeriria dos niveles de agrupamiento, primero contar películas por categoría, luego comparar cada conteo
-- con el promedio de todos los conteos. SQL no permite esto a menos que usemos una subconsulta

-- Pasos:
-- 1.- Obtener el número de películas por categoría
-- 2.- Calcular el promedio de esos números
-- 3.- Seleccionar las categorias cuyo número está por encima de ese promedio

-- 1.- Construimos una subconsulta que calcule el total de películas en cada categoría.

SELECT 
    category_id, COUNT(*) AS film_count
FROM
    film_category
GROUP BY category_id;

-- esta subconsulta produce una tabla con dos columnas: el id y el total de películas de ese id (de esa categoría)

-- ahora la usaremos dentro de la clausula FROM de la consulta principal, aliñandola e incorporamos el cálculo del promedio

SELECT 
    ca.name AS category_name, category_counts.film_count
FROM
    (SELECT 
        category_id, COUNT(*) AS film_count
    FROM
        film_category
    GROUP BY category_id) AS category_counts -- es la subconsulta derivada qque saca el total de películas por categoría. AHORA SE COMPORTA COMO UNA TABLA llamada category_counts
        JOIN
    category ca ON ca.category_id = category_counts.category_id -- hacemos un join de la nueva tabla, con category, para obtener el nombre de la categoria
WHERE -- aca comparamos el resultado de contar todas las peliculas por categoria (osea todas las películas que pertenecen a esa categoria) >>>
    category_counts.film_count > (SELECT 
            AVG(film_count) -- >>> con el promedio  que se obtiene mediante otra subconsulta que es igual que la anterior pero ahora para calcular el promedio
        FROM
            (SELECT 
                category_id, COUNT(*) AS film_count
            FROM
                film_category
            GROUP BY category_id) AS category_counts2);
-- la consulta final lista el nombre de cada categoría y su conteo de películas, para las categorías sobre la media

-- Nota: Esta solucion nos obliga a repetir la subconsulta de conteo dos veces.
-- En SQL existen formas alternativas. podriamos haber calculado el total de peliculas (N), y el número de categorias (K) para computar la media en una sola subconsutla
-- o utilizar una WITH

-- ------------------------------------------------------------------------------------------

-- Otro ejemplo de subconsulta con FROM es usarla para lograr un "paso intermedio"
-- Podríamos reescribir la consulta de "películas con duracion superior a la media" de la siguiente manera:

SELECT 
    f.title, f.length
FROM
    film f
        JOIN
    (SELECT 
        AVG(length) AS avg_length
    FROM
        film) AS stats
WHERE
    f.length > stats.avg_length;
    
-- En general las subconsultas en FROM son muy utiles para:
-- 		descomponer consultas complejas en subpasos comprensibles
--  	evitarl limitaciones del SQL básico
-- 		Reutilizar resultados intermedios

-- ------------------------------------------------------------------------------------------
-- =====CONCLUSIONES=====
-- ESCALARES: Dentro de select - Crea una columna
-- DERIVADAS: Dentro de from -  Crea una tabla derivada (tiene que llevar un alias si o si)
-- CORRELACIONALES: dentro del where
-- ------------------------------------------------------------------------------------------
-- =======EJERCICIOS DE PRACTICA=======

-- Ejercicio 1: Películas por encima de la duración promedio

SELECT 
    f.title, f.length
FROM
    film f
WHERE
    length > (SELECT 
            AVG(f.length)
        FROM
            film f);
-- ORDER BY f.length DESC , f.title;

-- Ejercicio 2: Actores en "Action" y en "Comedy"

SELECT 
    a.first_name, a.last_name
FROM
    actor a
WHERE
    EXISTS( SELECT 
            1
        FROM
            film_actor fa
                JOIN
            film_category fc USING (film_id)
                JOIN
            category c USING (category_id)
        WHERE
            fa.actor_id = a.actor_id
                AND c.name = 'Action')
        AND EXISTS( SELECT 
            1
        FROM
            film_actor fa
                JOIN
            film_category fc USING (film_id)
                JOIN
            category c USING (category_id)
        WHERE
            fa.actor_id = a.actor_id
                AND c.name = 'Comedy')
ORDER BY a.last_name , a.first_name;

-- Ejercicio 3: Cliente con más alquileres

SELECT 
    c.customer_id, c.first_name, c.last_name
FROM
    customer AS c
        JOIN
    (SELECT 
        r.customer_id, COUNT(*) AS rentals
    FROM
        rental AS r
    GROUP BY r.customer_id) AS t ON t.customer_id = c.customer_id
WHERE
    t.rentals = (SELECT 
            MAX(x.rentals)
        FROM
            (SELECT 
                r2.customer_id, COUNT(*) AS rentals
            FROM
                rental AS r2
            GROUP BY r2.customer_id) AS x);

-- Ejercicio 4: Películas de "Sports" no alquiladas en 2005

SELECT 
    f.title
FROM
    film f
        JOIN
    film_category fc USING (film_id)
        JOIN
    category c USING (category_id)
WHERE
    c.name = 'Sports'
        AND NOT EXISTS( SELECT 
            1
        FROM
            inventory i
                JOIN
            rental r USING (inventory_id)
        WHERE
            i.film_id = f.film_id
                AND YEAR(r.rental_date) = 2005);
                
-- =EJERCICIOS RESUELTOS=

-- el objetivo es comprender cuando conviene usar una subconsulta derivada, una correclacionada o una escalar.

-- DERIVADA -> Películas por idioma

-- Enunciado: Queremos conocer cuántas películas hay registradas en la base de datos por
-- cada idioma. Para ello agrupamos las películas según su language_id, contamos cuántas
-- hay en cada grupo, y posteriormente relacionamos ese resultado con la tabla language para
-- mostrar el nombre del idioma.

-- Tipo de subconsulta: derivada (tabla intermedia agregada).
-- Camino: film → (derivada por language_id) → language
-- Salida: language_id, language_name, films_in_language (desc)

SELECT 
    l.language_id, l.name, t.films_in_language
FROM
    (SELECT 
        f.language_id, COUNT(*) AS films_in_language
    FROM
        film f
    GROUP BY f.language_id) AS t
        JOIN
    language AS l ON l.language_id = t.language_id;

-- Interpretación: La subconsulta crea una tabla temporal (t) que contiene la cantidad de
-- películas por idioma. Posteriormente se une con language para mostrar el nombre de cada
-- idioma. El resultado demuestra que todas las películas están en inglés.

-- DERIVADA -> Idiomas con longitud media superior a 110 minutos

SELECT 
    l.language_id, l.name, s.avg_length
FROM
    (SELECT 
        f.language_id, AVG(f.length) AS avg_length
    FROM
        film f
    GROUP BY f.language_id) AS s
        JOIN
    language l USING (language_id)
WHERE
    s.avg_length > 110;
    
-- 	DERIVADA -> Máximo y mínimo replacement_cost por idioma

SELECT 
    l.language_id,
    l.name,
    r.max_replacement_cost,
    r.min_replacement_cost
FROM
    (SELECT 
        f.language_id,
            MAX(f.replacement_cost) AS max_replacement_cost,
            MIN(replacement_cost) AS min_replacement_cost
    FROM
        film f
    GROUP BY f.language_id) AS r
        JOIN
    language l USING (language_id);
    
    -- CORRELACIONADA (EXISTS)-> Idiomas con al menos una película rating='R'
    
    select * from film limit 10;
    
    SELECT 
    l.language_id, l.name AS language_name
FROM
    language l
WHERE
    EXISTS( SELECT 
            1
        FROM
            film f
        WHERE
            l.language_id = f.language_id
                AND f.rating = 'R');
                
-- ESCALAR -> Número total de idiomas distintos presentes en film

SELECT 
    (SELECT 
            COUNT(DISTINCT f.language_id)
        FROM
            film f) AS film_languages;
            
-- ESCALAR -> Número de películas con calificación 'R'

SELECT 
    (SELECT 
            COUNT(f.rating)
        FROM
            film f
        WHERE
            f.rating = 'R') AS films_rating_r;
            
-- CTE -Common Table Expression- (WITH) -> Actores con al menos 30 películas
    
with film_count as(
select fa.actor_id, count(*) as total_films
from film_actor fa
group by fa.actor_id
)
select a.actor_id, a.first_name, a.last_name, fc.total_films
from film_count as fc
join actor a on a.actor_id = fc.actor_id
where fc.total_films >= 30;

-- Las CTEs son una alternativa mas legible a las subconsultas derivadas. Permiten reutilizar resultados intermedios con nombres temporales
-- y facilitan la lectura de consultas complejas

-- ==============6 Para Practicar=================

-- 6.1 Derivada - Películas por idioma

SELECT 
    l.language_id, l.name, t.films_in_language
FROM
    (SELECT 
        f.language_id, COUNT(*) AS films_in_language
    FROM
        film f
    GROUP BY f.language_id) AS t
        JOIN
    language l USING (language_id);
    
-- 6.2 Derivada - Idiomas con AVG(length)>110

SELECT 
    l.language_id, l.name, t.avg_length
FROM
    (SELECT 
        f.language_id, AVG(f.length) AS avg_length
    FROM
        film f
    GROUP BY f.language_id) AS t
        JOIN
    language l USING (language_id)
WHERE
    t.avg_length > 110;
    
-- 6.3 Derivada - Max/Min replacement_cost por idioma

SELECT 
    l.language_id,
    l.name,
    t.max_replacement_cost,
    t.min_replacement_cost
FROM
    (SELECT 
        f.language_id,
            MAX(f.replacement_cost) AS max_replacement_cost,
            MIN(f.replacement_cost) AS min_replacement_cost
    FROM
        film f
    GROUP BY f.language_id) AS t
        JOIN
    language l USING (language_id);
    
-- 6.4 Correlacionada (Exists) - Idiomas con peliculas rating='R'

SELECT 
    l.language_id, l.name
FROM
    language l
WHERE
    EXISTS( SELECT 
            1
        FROM
            film f
        WHERE
            f.language_id = l.language_id
                AND f.rating = 'R');
                
-- 6.5 Escalar - Nº de idiomas distintos en film
SELECT 
    (SELECT 
            COUNT(DISTINCT f.language_id)
        FROM
            film f) AS film_languages;
            
-- 6.6 Escalar - Nº de películas rating ='R'

SELECT 
    (SELECT 
            COUNT(f.film_id)
        FROM
            film f
        WHERE
            rating = 'R') AS films_rating_r;
            
-- 6.7 Derivada - Idioma con más películas (TOP-1)

SELECT 
    l.name, t.films_in_language
FROM
    (SELECT 
        f.language_id, COUNT(f.language_id) AS films_in_language
    FROM
        film f
    GROUP BY f.language_id) AS t
        JOIN
    language l USING (language_id)
ORDER BY t.films_in_language DESC
LIMIT 1;

-- 6.8 Derivada - Idioma con mayor AVG(length) (TOP-1)

SELECT 
    l.name, t.avg_length
FROM
    (SELECT 
        f.language_id, AVG(f.length) AS avg_length
    FROM
        film f
    GROUP BY f.language_id) AS t
        JOIN
    language l USING (language_id)
ORDER BY t.avg_length DESC
LIMIT 1;

-- 6.9 Escalar - Media global de length

SELECT 
    (SELECT 
            AVG(f.length)
        FROM
            film f) AS avg_global;
            
-- Correlacionada (NOT EXISTS) — Idiomas de language sin películas

SELECT 
    l.language_id, l.name
FROM
    language l
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            film f
        WHERE
            l.language_id = f.language_id);
            
SELECT 
    (SELECT 
            COUNT(*) AS total_films
        FROM
            film f
        WHERE
            f.rating != 'R') AS films_not_r;
            
-- Escalar — Proporción de R sobre el total (4 decimales)

SELECT 
    ROUND((SELECT 
                    COUNT(*)
                FROM
                    film
                WHERE
                    rating = 'R') / (SELECT 
                    COUNT(*)
                FROM
                    film),
            4) AS ratio_r;
            
-- Correlacionada (EXISTS) — ¿Algún idioma distinto de English con películas?

SELECT 
    l.language_id, l.name
FROM
    language l
WHERE
    l.name != 'English'
        AND EXISTS( SELECT 
            1
        FROM
            film f
        WHERE
            f.language_id = l.language_id);
            
-- Escalar — ¿Cuántos idiomas hay en language?


SELECT 
    (SELECT 
            COUNT(*)
        FROM
            language) AS langs_in_language;
            
-- Correlacionada (EXISTS) — Idiomas con al menos una película

SELECT 
    l.name
FROM
    language l
WHERE
    EXISTS( SELECT 
            1
        FROM
            film f
        WHERE
            l.language_id = f.language_id);
            

-- Derivada — Idiomas con MAX(replacement_cost) = 29.99

SELECT 
    l.name
FROM
    (SELECT 
        f.language_id, MAX(f.replacement_cost) AS mx
    FROM
        film f
    GROUP BY f.language_id) AS r
        JOIN
    language l USING (language_id)
WHERE
    r.mx = 29.99;
    
-- Derivada — Idiomas con MIN(replacement_cost) = 9.99

SELECT 
    l.name
FROM
    (SELECT 
        f.language_id, MIN(replacement_cost) AS min
    FROM
        film f
    GROUP BY f.language_id) AS r
        JOIN
    language l using (language_id)
WHERE
    r.min = 9.99;

-- Correlacionada (EXISTS) — Idiomas con películas no ’R’

SELECT 
    l.name
FROM
    language l
WHERE
    EXISTS( SELECT 
            1
        FROM
            film f
        WHERE
            l.language_id = f.language_id
                AND f.rating != 'R');
                
-- Derivada — ¿Cuántas películas totales hay? 

SELECT 
    t.total_films
FROM
    (SELECT 
        COUNT(*) AS total_films
    FROM
        film) AS t;

-- Escalar — Media global de length (redondeada a 4 decimales)

SELECT 
    ROUND((SELECT 
                    AVG(f.length)
                FROM
                    film f),
            4) AS avg_len;



            



