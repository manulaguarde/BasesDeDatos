use sakila;
-- Cinco actores con mas peliculas

SELECT 
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS total_films
FROM
    actor a
        JOIN
    film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id
ORDER BY total_films DESC
LIMIT 5;

-- Peliculas que nunca han sido alquiladas

select * from film limit 1;
select * from rental limit 1;

select count(distinct inventory_id) from rental;
select count(distinct inventory_id) from inventory;


-- pais con mas clientes

SELECT 
    country, COUNT(customer_id) AS num_countries
FROM
    customer c
        JOIN
    address ad USING (address_id) -- Esto solo funciona cuando la culumna que se comparte es exactamente igual
        JOIN
    city USING (city_id)
        JOIN
    country co USING (country_id)
GROUP BY co.country_id
ORDER BY num_countries DESC;

select * from country limit 1;

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

-- tambien lo hice con 
-- STORE -> CUSTOMER -> PAYMENT
-- STORE -> CUSTOMER -> RENTAL -> PAYMENT
-- STORE -> STAFF USING (STORE_ID) -> PAYMENT

SELECT 
    i.store_id as tienda, (AVG(p.amount), 2) AS ingreso_promedio
FROM
    inventory i
        JOIN
    rental r USING (inventory_id)
        JOIN
    payment p USING (rental_id)
GROUP BY i.store_id
ORDER BY ingreso_promedio ASC;

SELECT 
    st.store_id as tienda, ROUND(AVG(p.amount), 2) AS ingreso_promedio
FROM
    store st
        JOIN
    customer c USING (store_id)
        JOIN
    payment p USING (customer_id)
GROUP BY st.store_id
ORDER BY ingreso_promedio ASC;

SELECT 
    st.store_id as tienda, ROUND(AVG(p.amount), 2) AS ingreso_promedio
FROM
    store st
        JOIN
    customer c USING (store_id)
		JOIN
	rental r USING (customer_id)
        JOIN
    payment p USING (rental_id)
GROUP BY st.store_id
ORDER BY ingreso_promedio ASC;

SELECT 
    st.store_id as tienda, ROUND(AVG(p.amount), 2) AS ingreso_promedio
FROM
    store st
        JOIN
    staff USING (store_id)
        JOIN
    payment p USING (staff_id)
GROUP BY st.store_id
ORDER BY ingreso_promedio ASC;

select * from store;

-- 6) Ventas totales por categoría ordenadas



-- 7) Actores con al menos diez películas de categorías distintas
-- 8) Tiendas con más stock disponible
-- 9) Diez películas con mayor diferencia entre coste de reposición y tarifa de alquiler
-- 10) Películas con más de tres actores y duración menor a 90 minutos
-- 11) Cliente que más ha gastado