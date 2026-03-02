-- ===== 1 =====
-- Película(s) más larga(s) por categoría
-- Objetivo: Para cada categoría, devolver la(s) película(s) de mayor duración dentro de esa categoría.

SELECT 
    c.name AS category, f.title, t.length
FROM
    (SELECT 
        category_id, MAX(length) AS length
    FROM
        film_category
    JOIN film USING (film_id)
    GROUP BY category_id) AS t
        JOIN
    category c USING (category_id)
        JOIN
    film_category USING (category_id)
        JOIN
    film f USING (film_id)
WHERE
    f.length = t.length
ORDER BY category ASC;

-- ===== 2 =====
-- Número de películas sin stock disponible en ninguna tienda
-- Objetivo: Devolver una única fila con el recuento de películas que no tienen ninguna copia disponible en stock en ninguna tienda.

SELECT 
    COUNT(*) AS num_unavailable_films
FROM
    film f
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            inventory i
        WHERE
            i.film_id = f.film_id);
  
-- ===== 3 =====
-- Recaudación mensual por categoría en 2024
-- Objetivo: Para cada categoría y cada mes del año natural 2024, devolver la recaudación total (suma de importes cobrados)
-- correspondiente a esa categoría en ese mes.

SELECT 
    category, month, SUM(amount) AS total
FROM
    (SELECT 
        c.name AS category, MONTH(p.payment_date) AS month, p.amount
    FROM
        payment p
    JOIN rental USING (rental_id)
    JOIN inventory USING (inventory_id)
    JOIN film USING (film_id)
    JOIN film_category USING (film_id)
    JOIN category c USING (category_id)
    WHERE
        YEAR(p.payment_date) = 2024) AS t
GROUP BY category , month
ORDER BY category , month;

-- ===== 4 =====
-- Clientes con alquileres pero sin pagos registrados
-- Objetivo: Listar los clientes que han realizado al menos un alquiler y no tienen ningún pago registrado.

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer
FROM
    customer c
WHERE
    c.customer_id IN (SELECT DISTINCT
            customer_id
        FROM
            rental r)
        AND c.customer_id NOT IN (SELECT DISTINCT
            customer_id
        FROM
            payment p);
    
-- ===== 5 =====
-- Cliente(s) que más ha(n) gastado en cada país
-- Objetivo: Para cada país, devolver el/los cliente(s) con mayor gasto total y el importe gastado

WITH gasto_por_cliente AS (
    SELECT 
        co.country_id,
        c.customer_id,
        SUM(p.amount) AS total_spent
    FROM payment p
    JOIN customer c ON p.customer_id = c.customer_id
    JOIN address a ON c.address_id = a.address_id
    JOIN city ci ON a.city_id = ci.city_id
    JOIN country co ON ci.country_id = co.country_id
    GROUP BY co.country_id, c.customer_id
)
SELECT 
    co.country       AS country,
    CONCAT(c.first_name, ' ', c.last_name) AS top_customer,
    gc.total_spent   AS max_spent
FROM gasto_por_cliente gc
JOIN customer c ON gc.customer_id = c.customer_id
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE gc.total_spent = (
    SELECT MAX(g2.total_spent)
    FROM gasto_por_cliente g2
    WHERE g2.country_id = gc.country_id
)
ORDER BY co.country ASC;

-- ===== 6 =====
-- Categorías con ingresos superiores a la media global
-- Objetivo: Devolver las categorías cuyo ingreso total (suma de importes cobrados asociados a sus alquileres) 
-- es estrictamente superior a la media global de ingresos por categoría
WITH revenue_by_category AS (
    SELECT 
        c.name AS category,
        SUM(p.amount) AS total_revenue
    FROM category c
    JOIN film_category USING (category_id)
    JOIN film USING (film_id)
    JOIN inventory USING (film_id)
    JOIN rental USING (inventory_id)
    JOIN payment p USING (rental_id)
    GROUP BY c.name
)

SELECT 
    category,
    total_revenue
FROM revenue_by_category
WHERE total_revenue > (
    SELECT AVG(total_revenue) FROM revenue_by_category
)
ORDER BY total_revenue DESC;



