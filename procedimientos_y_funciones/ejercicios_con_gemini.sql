-- EJERCICIOS CON GEMINI:

-- ==============================================================================================================================
-- ==============================================================================================================================

-- PROCEDIMIENTOS


-- Crear un procedimiento que nos diga cuántas películas hay de una clasificación específica (rating)
-- como 'G', 'PG', 'NC-17', etc.
select * from film;

delimiter //
create procedure contar_peliculas_por_rating (in v_clasificacion varchar(10))
begin 
	select count(*) as total_peliculas from film
    where rating= v_clasificacion;
end//
delimiter ;

-- ejercicio 2

delimiter //
create procedure duracion_total_actor (in p_actor_id int , out p_duracion_total decimal (10,2))
begin
	select sum(f.length) into p_duracion_total from film f
    join film_actor fa using (film_id)
    where fa.actor_id = p_actor_id;
end //
delimiter ;

-- ejercicio 3 con condicionales


DELIMITER //

CREATE PROCEDURE verificar_stock_pelicula (
    IN p_film_id INT, 
    IN p_store_id INT, 
    OUT p_mensaje VARCHAR(100)
)
BEGIN
    -- 1. Declaramos una variable local para guardar el cálculo interno
    DECLARE v_cantidad INT;

    -- 2. Guardamos el resultado del COUNT en nuestra variable local
    SELECT COUNT(*) INTO v_cantidad
    FROM inventory
    WHERE film_id = p_film_id AND store_id = p_store_id;

    -- 3. Estructura condicional IF
    IF v_cantidad > 0 THEN
        SET p_mensaje = 'Hay copias disponibles';
    ELSE
        SET p_mensaje = 'Sin existencias en esta tienda';
    END IF;

END //

DELIMITER ;

-- Enunciado probable: "Crea un procedimiento que reciba el nombre de una categoría y devuelva cuántas películas hay en ella."

DELIMITER // 
CREATE PROCEDURE obtener_conteo_categoria( IN p_nombre_categoria VARCHAR(25), OUT p_total INT )
BEGIN SELECT COUNT(*) INTO p_total
 FROM category 
JOIN film_category USING (category_id)
WHERE name = p_nombre_categoria; 
END // 
DELIMITER ;

 -- Cómo se usa: 
CALL obtener_conteo_categoria('Action', @resultado);
 SELECT @resultado;


-- ==============================================================================================================================
-- ==============================================================================================================================
-- ==============================================================================================================================

-- FUNCIONES

DELIMITER //

CREATE FUNCTION precio_con_iva(p_precio DECIMAL(5,2)) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN 
    RETURN p_precio * 1.15;
END //

DELIMITER ;

-- Enunciado probable: "Crea una función que reciba el ID de una película y devuelva 'CARA' si su rental_rate es mayor a 3, 'BARATA' si es menor a 1, y 'NORMAL' para el resto."
	DELIMITER //
CREATE FUNCTION evaluar_precio(p_film_id INT) 
RETURNS VARCHAR(10)
READS SQL DATA
BEGIN
    DECLARE v_precio DECIMAL(4,2);
    DECLARE v_etiqueta VARCHAR(10);

    -- Buscamos el precio de esa película
    SELECT rental_rate INTO v_precio FROM film WHERE film_id = p_film_id;

    -- Aplicamos la lógica
    IF v_precio > 3 THEN SET v_etiqueta = 'CARA';
    ELSEIF v_precio < 1 THEN SET v_etiqueta = 'BARATA';
    ELSE SET v_etiqueta = 'NORMAL';
    END IF;

    RETURN v_etiqueta;
END //
DELIMITER ;

-- Escenario: Función para calcular días de retraso
-- Queremos una función que nos diga cuántos días lleva retrasada una película que aún no se ha devuelto.
-- Lógica: Restaremos la fecha en la que debió devolverse (return_date teórica) de la fecha actual (CURDATE()).

DELIMITER //

CREATE FUNCTION dias_retraso_alquiler(p_rental_id INT) 
RETURNS INT
NOT DETERMINISTIC -- ¡Importante! El resultado cambia cada día que pasa
READS SQL DATA
BEGIN
    DECLARE v_fecha_limite DATETIME;
    DECLARE v_retraso INT;
    -- 1. Obtenemos la fecha en la que el cliente debería haber devuelto la película
    -- (En Sakila, sumamos rental_duration a la fecha de alquiler)
    SELECT DATE_ADD(rental_date, INTERVAL f.rental_duration DAY) INTO v_fecha_limite
    FROM rental r
    JOIN inventory i USING (inventory_id)
    JOIN film f USING (film_id)
    WHERE r.rental_id = p_rental_id;

    -- 2. Calculamos la diferencia en días entre HOY y esa fecha
    -- DATEDIFF(fecha1, fecha2) devuelve la resta en días
    SET v_retraso = DATEDIFF(CURDATE(), v_fecha_limite);

    -- 3. Si el resultado es negativo, es que aún tiene tiempo, devolvemos 0
    IF v_retraso < 0 THEN
        RETURN 0;
    ELSE
        RETURN v_retraso;
    END IF;
END //

DELIMITER ;

-- Como se usa:

SELECT 
    r.rental_id, 
    c.first_name, 
    f.title, 
    dias_retraso_alquiler(r.rental_id) AS dias_tarde
FROM rental r
JOIN customer c USING (customer_id)
JOIN inventory i USING (inventory_id)
JOIN film f USING (film_id)
WHERE r.return_date IS NULL -- Solo las que no se han devuelto todavía
ORDER BY dias_tarde DESC;

-- ==============================================================================================================================
-- ==============================================================================================================================
-- ==============================================================================================================================

-- TRIGGERS

-- Enunciado probable: "Cada vez que se borre un pago (payment), guarda el ID del pago, el importe y la fecha del borrado en una tabla de auditoría." (Primero tendrías que crear la tabla de log).

-- Tabla para guardar el historial (esto te lo suelen dar o pedir)
CREATE TABLE log_pagos_borrados (
    id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT,
    amount DECIMAL(5,2),
    fecha_borrado DATETIME
);

DELIMITER //
CREATE TRIGGER auditoria_pagos_delete
BEFORE DELETE ON payment -- Se ejecuta ANTES de borrar
FOR EACH ROW
BEGIN
    -- OLD hace referencia a los datos que estaban antes de borrar
    INSERT INTO log_pagos_borrados (payment_id, amount, fecha_borrado)
    VALUES (OLD.payment_id, OLD.amount, NOW());
END //
DELIMITER ;




-- Escenario: No permitir que se inserte una película cuyo rental_duration (duración del alquiler) sea menor a 3 días, porque no es rentable para el videoclub.



DELIMITER //

CREATE TRIGGER validar_duracion_alquiler
BEFORE INSERT ON film -- Usamos BEFORE para validar antes de que entre el dato
FOR EACH ROW
BEGIN
    -- Usamos NEW porque estamos evaluando el dato que intenta entrar
    IF NEW.rental_duration < 3 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: La duración mínima de alquiler debe ser de 3 días';
    END IF;
END //

DELIMITER ;

-- Escenario: Cada vez que cambie el precio de alquiler (rental_rate) de una película, queremos guardar el precio antiguo, el nuevo y la fecha en una tabla llamada historial_precios.

-- Suponiendo que la tabla existe:
-- CREATE TABLE historial_precios (id_historial INT AUTO_INCREMENT PRIMARY KEY, film_id INT, precio_viejo DECIMAL(4,2), precio_nuevo DECIMAL(4,2), fecha DATETIME);

DELIMITER //

CREATE TRIGGER log_cambio_precios
AFTER UPDATE ON film
FOR EACH ROW
BEGIN
    -- Solo guardamos si realmente cambió el precio
    IF OLD.rental_rate <> NEW.rental_rate THEN
        INSERT INTO historial_precios (film_id, precio_viejo, precio_nuevo, fecha)
        VALUES (OLD.film_id, OLD.rental_rate, NEW.rental_rate, NOW());
    END IF;
END //

DELIMITER ;


-- Si el profesor te pide: "No permitas que se alquile una película que no ha sido devuelta", tendrías que hacer un Trigger BEFORE INSERT.
-- Aquí tienes el código "blindado" para tus apuntes:
DELIMITER //

CREATE TRIGGER check_disponibilidad_antes_alquiler
BEFORE INSERT ON rental
FOR EACH ROW
BEGIN
    DECLARE v_esta_alquilada INT;

    -- Buscamos si ese ID de inventario tiene algún alquiler sin fecha de devolución
    SELECT COUNT(*) INTO v_esta_alquilada
    FROM rental
    WHERE inventory_id = NEW.inventory_id 
      AND return_date IS NULL;

    -- Si el conteo es mayor a 0, significa que la película está fuera
    IF v_esta_alquilada > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Este ejemplar ya está alquilado y no ha sido devuelto.';
    END IF;
END //

DELIMITER ;

