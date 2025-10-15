use sakila;

-- 4) Tres películas con mayores ingresos por alquiler. 
/* Pistas:
- Los ingresos están en payment.amount
- Saca id,nombre de cada película con los ingresos.
*/
select * from payment 
order by amount desc limit 20;

SELECT 
    f.film_id as id_pelicula, f.title as titulo, SUM(p.amount) AS ingresos
FROM
    film f
        JOIN
    inventory i USING (film_id)
        JOIN
    rental r USING (inventory_id)
        JOIN
    payment p USING (rental_id)
GROUP BY f.film_id
ORDER BY ingresos DESC
LIMIT 3;


-- 5) Ingreso promedio por alquiler en cada tienda

SELECT 
    i.store_id as tienda, ROUND(AVG(amount), 2) AS ingreso_promedio
FROM
    inventory i
        JOIN
    rental r USING (inventory_id)
        JOIN
    payment p USING (rental_id)
GROUP BY i.store_id
ORDER BY ingreso_promedio ASC;

select * from store;