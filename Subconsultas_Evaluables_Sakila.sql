-- Película(s) más larga(s) por categoría
-- Objetivo: Para cada categoría, devolver la(s) película(s) de mayor duración dentro de esa categoría.

SELECT 
    c.name AS category, f.title, f.length
FROM
    film f
        JOIN
    film_category USING (film_id)
        JOIN
    category c USING (category_id)
WHERE
    length > (SELECT 
            AVG(f.length)
        FROM
            film f)
ORDER BY length DESC , category
LIMIT 20;

-- Número de películas sin stock disponible en ninguna tienda
-- Objetivo: Devolver una única fila con el recuento de películas que no tienen ninguna copia disponible en stock en ninguna tienda.

select count(*) as num_unavailable_films from inventory i 
where not exists(select 1
from store s
where s.store_id = i.store_id);
