use logistica_global;

select * from almacenes; -- aca no hay foreign keys
explain almacenes;

select * from clientes; -- aca no hay foreign keys
explain clientes;

select * from empleados; -- aca tenemos almacen_id
explain empleados;

select * from envios; -- aca tenemos cliente_id, vehiculo_id, empleado_id
explain envios;

select * from incidencias; -- aca tenemos envio_id
explain incidencias;

select * from mantenimientos_flota; -- aca tenemos vehiculo_id
explain mantenimientos_flota;

select * from proveedores; -- aca no hay foreign keys
explain proveedores;

select * from vehiculos;
explain proveedores;

-- ======================COMIENZO SANEANDO EMPLEADOS=============================

select * from empleados;

select e1.id, e2.id from empleados e1
join empleados e2 on e1.nif_nie = e2.nif_nie
where e2.nif_nie > e1.nif_nie;

SELECT nif_nie, COUNT(*) as repeticiones
FROM empleados
GROUP BY nif_nie
HAVING COUNT(*) > 1;

select id, nif_nie, nombre_completo
from empleados 
where nif_nie in(
SELECT nif_nie
FROM empleados
GROUP BY nif_nie
HAVING COUNT(*) > 1)
order by nif_nie;

select *
from empleados 
where nif_nie is null;

-- HAY EMPLEADOS CON NIF_NIE NULL
-- UNA OPCION: ponerles un nif temporal con el número de id
UPDATE empleados 
SET nif_nie = CONCAT('TEMP-', id) 
WHERE nif_nie IS NULL;

-- OTRA OPCIÓN:
-- 1. Crear copia de seguridad de los erróneos
CREATE TABLE empleados_error_nif AS 
SELECT * FROM empleados WHERE nif_nie IS NULL;

-- 2. Borrar de la tabla principal
set sql_safe_updates=0;
DELETE FROM empleados WHERE nif_nie IS NULL;

-- 3. Ahora ya podemos  blindar la tabla
ALTER TABLE empleados MODIFY COLUMN nif_nie VARCHAR(50) NOT NULL;
ALTER TABLE empleados ADD CONSTRAINT uq_nif UNIQUE (nif_nie);

select * from envios;


-- 1. Identificar empleados sin NIF que TIENEN envíos asignados
SELECT 
    e.id AS empleado_id, 
    e.nombre_completo, 
    COUNT(v.id) AS total_envios_asociados
FROM empleados e
JOIN envios v ON e.id = v.empleado_id
WHERE e.nif_nie IS NULL OR TRIM(e.nif_nie) = ''
GROUP BY e.id, e.nombre_completo;


-- ahora que sabemos que los registros no sirven se podrían borrar
SET sql_safe_updates = 0;

-- 1. Borrar registros basura (NIFs nulos o vacíos)
DELETE FROM empleados 
WHERE nif_nie IS NULL OR TRIM(nif_nie) = '';

-- 2. Limpiar los NIFs reales (Mayúsculas y sin espacios)
UPDATE empleados 
SET nif_nie = UPPER(TRIM(nif_nie));

-- 3. Blindaje: Ahora que no hay nulos ni basura, prohibimos que entren en el futuro
ALTER TABLE empleados MODIFY COLUMN nif_nie VARCHAR(50) NOT NULL;
ALTER TABLE empleados ADD CONSTRAINT uq_empleado_nif UNIQUE (nif_nie);

-- SANEAR LA COLUMNA NIF_NIE

-- 1. Entramos en modo edición segura
SET sql_safe_updates = 0;

-- 2. Limpieza de strings: Quitar espacios locos y pasar a Mayúsculas
-- Esto arregla el " 12345678a" -> "12345678A"
UPDATE empleados 
SET nif_nie = UPPER(TRIM(nif_nie))
WHERE nif_nie IS NOT NULL;

-- 3. Caso especial: El script genera NIFs con espacios internos ("12345678 A")
-- Los eliminamos todos para que el JOIN futuro no falle
UPDATE empleados 
SET nif_nie = REPLACE(nif_nie, ' ', '')
WHERE nif_nie LIKE '% %';

UPDATE empleados 
SET nif_nie = REPLACE(nif_nie, '-', '')
WHERE nif_nie LIKE '% %';

-- 4. Verificación de duplicados POST-LIMPIEZA
-- A veces, al limpiar espacios, dos registros que parecían distintos resultan ser el mismo
SELECT nif_nie, COUNT(*) 
FROM empleados 
GROUP BY nif_nie 
HAVING COUNT(*) > 1;

-- 5. EL CERROJO FINAL (Si no hay duplicados)
-- Esto garantiza que el NIF sea obligatorio y único de ahora en adelante
ALTER TABLE empleados MODIFY COLUMN nif_nie VARCHAR(20) NOT NULL;
ALTER TABLE empleados ADD CONSTRAINT uq_nif_empleado UNIQUE (nif_nie);

SELECT * from empleados
where id=1002;

-- tengo que ver que hacer con los nif que no cumplen todo lo que tienen que cumplir como el del id 1002

-- una opcion es enviarlos a la tabla cuarentena
-- Mandamos a errores todo lo que NO sea un NIF estándar NI un NIE estándar
INSERT INTO empleados_error_nif
SELECT * FROM empleados 
WHERE NOT (
    -- Opción A: NIF Estándar (8 números + 1 letra)
    nif_nie REGEXP '^[0-9]{8}[A-Z]$' 
    OR 
    -- Opción B: NIE Estándar (Letra X/Y/Z + 7 números + 1 letra)
    nif_nie REGEXP '^[XYZ][0-9]{7}[A-Z]$'
);

-- Una vez puestos a salvo en la otra tabla, los borramos de la principal
DELETE FROM empleados 
WHERE id IN (SELECT id FROM empleados_error_nif);


--   -----------------------------------------------------------------------------------------------------------------
-- VAMOS A SANEAR EMAILS

select * from empleados;

start transaction;
-- 1. Actualizamos el email concatenando la parte izquierda del @ con el nuevo dominio
UPDATE empleados 
SET email_corp = CONCAT(
    SUBSTRING_INDEX(email_corp, '@', 1), 
    '@logistica.local'
)
WHERE email_corp LIKE '%@%';



-- 2. Verificación: ¿Hay algún email que NO termine correctamente ahora?
SELECT id, email_corp 
FROM empleados 
WHERE email_corp NOT LIKE '%@logistica.local';

-- Este es un regexp general para emails
select * from empleados
where email_corp not regexp '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

-- quitar los dos @
start transaction;
update empleados
set email_corp= replace(email_corp,'@@','@');

-- convertir todos los emails por igual
-- 1. Transformación masiva: 'user' + ID + '@logistica.local'
UPDATE empleados 
SET email_corp = CONCAT('user', id, '@logistica.local');

-- 2. Verificación rápida (muestra los primeros 5)
SELECT id, nombre_completo, email_corp 
FROM empleados 
LIMIT 5;

--  ------------------------------------------------------------------------------------------------------
-- SANEAMIENTO FECHA DE ALTA

SELECT f_alta, COUNT(*) 
FROM empleados 
GROUP BY f_alta 
ORDER BY COUNT(*) DESC;

SELECT id, f_alta 
FROM empleados 
WHERE f_alta NOT REGEXP '[0-9]';

-- 1. Preparamos el terreno
ALTER TABLE empleados ADD COLUMN f_alta_clean DATE AFTER f_alta;

start transaction;
UPDATE empleados SET f_alta_clean = CASE 
    -- 1. FORMATOS DE 4 DÍGITOS (Sin ambigüedad)
    WHEN f_alta LIKE '____-__-__' THEN STR_TO_DATE(f_alta, '%Y-%m-%d')
    WHEN f_alta LIKE '____/__/__' THEN STR_TO_DATE(f_alta, '%Y/%m/%d')
    WHEN f_alta LIKE '__/__/____' THEN STR_TO_DATE(f_alta, '%d/%m/%Y')
    WHEN f_alta LIKE '__-__-____' THEN STR_TO_DATE(f_alta, '%d-%m-%Y')

    -- 2. FORMATOS DE 2 DÍGITOS (Aplicando tu regla: MES SIEMPRE EN MEDIO)
    -- Asumimos DD-MM-YY (Día/Mes/Año)
    WHEN f_alta LIKE '__/__/__'   THEN STR_TO_DATE(f_alta, '%d/%m/%y')
    WHEN f_alta LIKE '__-__-__'   THEN STR_TO_DATE(f_alta, '%d-%m-%y')
    
    ELSE NULL 
END;

rollback;
select * from empleados;

-- conversión con regexp
UPDATE empleados 
SET f_alta_clean = CASE 
    -- Formato estándar: 2023-01-01
    WHEN f_alta REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(f_alta, '%Y-%m-%d')
    -- Formato español: 01/01/2023
    WHEN f_alta REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN STR_TO_DATE(f_alta, '%d/%m/%Y')
    -- Formato con guiones: 01-01-2023
    WHEN f_alta REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{2}$' THEN STR_TO_DATE(f_alta, '%d-%m-%y')
    -- Formato año corto: 01/01/23
    WHEN f_alta REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{2}$' THEN STR_TO_DATE(f_alta, '%d/%m/%y')
    ELSE NULL 
END;

-- ver que no hayan quedado nulls y si quedaron enviarlos a la de cuarentena:
SELECT count(*) FROM empleados WHERE f_alta_clean IS NULL AND f_alta IS NOT NULL;

-- elimiar f_alta sucia
ALTER TABLE empleados DROP COLUMN f_alta;

-- renombrar f_alta_clean y poner date
ALTER TABLE empleados CHANGE f_alta_clean f_alta DATE;

-- --------------------------------------------------------------------------------------------------
-- SANEAMIENTO SALARIO BASE SUCIO

-- 1. Preparamos la columna de destino
ALTER TABLE empleados ADD COLUMN salario_base_num DECIMAL(10,2) AFTER salario_base_sucio;
start transaction;
-- 2. Limpieza Universal:
-- Paso A: Quitamos unidades comunes (EUR, USD, €, $) y espacios.
-- Paso B: Convertimos comas en puntos (estándar decimal de SQL).
UPDATE empleados 
SET salario_base_num = CAST(
    TRIM(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
						REPLACE(salario_base_sucio, ' ', ''),
					'EUR',''),
                'USD', ''), 
            '€', ''), 
        ',', '.')
    ) AS DECIMAL(10,2)
)
-- Solo intentamos convertir si el campo contiene al menos un número
WHERE salario_base_sucio REGEXP '[0-9]';

select * from empleados;

-- verificar nulls
SELECT id, salario_base_sucio 
FROM empleados 
WHERE salario_base_num IS NULL 
  AND salario_base_sucio IS NOT NULL;
  
  
-- opciones con los null:
-- opcion a) (enviarlos a otra tabla)
INSERT INTO empleados_error_nif (id, motivo)
SELECT id, 'Error en salario' FROM empleados 
WHERE salario_base_num IS NULL;

-- opcion b) (por defecto)
UPDATE empleados 
SET salario_base_num = 1080.00 -- o el que sea
WHERE salario_base_num IS NULL;

ALTER TABLE empleados DROP COLUMN salario_base_sucio;
ALTER TABLE empleados CHANGE salario_base_num salario_base decimal(10,2) NOT NULL DEFAULT 0.00; -- o default lo que sea
alter table empleados add constraint chk_salario check (salario_base >=0);
-- -------------------------------------------------------------------------------------------
-- SANEAMIENTO ACTIVO_BOOLEAN

-- primero revisamos que valores hay
SELECT activo_boolean, COUNT(*) 
FROM empleados 
GROUP BY activo_boolean;

-- 1. Creamos la columna técnica (Booleana)
ALTER TABLE empleados ADD COLUMN activo_new TINYINT(1) DEFAULT 0 AFTER activo_boolean;

-- 2. Mapeo de valores conocidos
UPDATE empleados 
SET activo_new = CASE 
    -- Casos para ACTIVO (1)
    WHEN activo_boolean IN ('1', 'SI', 'S', 'TRUE', 'ACTIVO') THEN 1
    -- Casos para INACTIVO (0)
    WHEN activo_boolean IN ('0', 'NO', 'N', 'FALSE', 'INACTIVO') THEN 0
    -- Por defecto, si es NULL o basura, asumimos inactivo o lo que dicte el negocio
    ELSE 0 
END;

select * from empleados;
-- Borramos la original y renombramos la nueva
ALTER TABLE empleados DROP COLUMN activo_boolean;
ALTER TABLE empleados CHANGE activo_new activo TINYINT(1) NOT NULL DEFAULT 1; -- o default 0

-- EXTRAS SI ME PIDEN:
-- Rellenar el Número de Seguridad Social con el patrón 'SEG-' + ID
UPDATE empleados 
SET num_ss = CONCAT('SEG-', id)
WHERE num_ss IS NULL;

-- Paso A: Rellenar los registros actuales que estén NULL
UPDATE empleados 
SET puesto = 'SUBORDINADO'
WHERE puesto IS NULL;

-- Paso B: Establecer el valor por defecto en la estructura de la tabla
ALTER TABLE empleados 
MODIFY COLUMN puesto VARCHAR(50) DEFAULT 'SUBORDINADO';

-- --------------------------------------------------------------------------------------------------
-- UNIR EMLEADOS CON ALMACENES:
explain empleados;
explain almacenes;

alter table empleados
add constraint fk_empleados_almacenes foreign key (almacen_id)
references almacenes(id)
on update cascade on delete restrict;

SELECT id, nombre_completo, almacen_id 
FROM empleados 
WHERE almacen_id IS NOT NULL 
  AND almacen_id NOT IN (SELECT id FROM almacenes);
  
-- TENGO TRES OPCIONES:
-- OPCION 1)
-- 1. "Blanqueamos" los IDs que no existen
UPDATE empleados 
SET almacen_id = NULL 
WHERE almacen_id = 99999;

-- 2. Ahora la FK pasará sin problemas
ALTER TABLE empleados
ADD CONSTRAINT fk_empleados_almacenes 
FOREIGN KEY (almacen_id) 
REFERENCES almacenes(id)
ON UPDATE CASCADE 
ON DELETE SET NULL;

-- OPCION 2)
INSERT INTO almacenes (id, nombre_sucursal) 
VALUES (99999, 'ALMACÉN TEMPORAL / DESCONOCIDO');

-- 2. Ahora ya puedes crear la FK porque el 99999 YA EXISTE
ALTER TABLE empleados
ADD CONSTRAINT fk_empleados_almacenes 
FOREIGN KEY (almacen_id) 
REFERENCES almacenes(id)
ON UPDATE CASCADE 
ON DELETE RESTRICT;

-- OPCION 3)
-- que los que sean 99999 sean por defecto 1
UPDATE empleados 
SET almacen_id = 1 
WHERE almacen_id = 99999;

-- para que sean por defecto el almacen 1, pero sin saber que existen
-- debería ser algo como

start transaction;
update empleados
set almacen_id = 1
where almacen_id not in (select id from almacenes)
and almacen_id is not null;

-- ================================ TABLA ALMACENES ==============================================================

select * from almacenes;

-- SANEAR COD_ALMACEN

SET sql_safe_updates = 0;

start transaction;
-- Generar formato ALM-001, ALM-002, etc. con el id (puede ser una opción)
UPDATE almacenes 
SET cod_almacen = CONCAT('ALM-', LPAD(id, 3, '0'));
rollback;


UPDATE almacenes 
SET cod_almacen = CONCAT('ALM-', 
    REGEXP_REPLACE(cod_almacen, '[^0-9]', '')
);



-- identificar codigos duplicados
-- ¿Qué hace GROUP_CONCAT? Te lista los IDs de las filas que comparten ese código.
-- Esto es vital para decidir cuál de las dos (o tres) filas es la "buena" y cuáles son basura.
SELECT cod_almacen, COUNT(*) as repeticiones, GROUP_CONCAT(id) as ids_afectados
FROM almacenes
GROUP BY cod_almacen
HAVING COUNT(*) > 1;

-- para saber cuales tienen exactamente los mismos datos
SELECT 
    nombre_sucursal, 
    cod_almacen, 
    ciudad_ubicacion, 
    capacidad_m3, 
    tel_contacto,
    tipo_gestion,
    ubicacion_geografica,
    COUNT(*) as veces_repetido,
    MIN(id) as id_original,
    MAX(id) as id_duplicado
FROM almacenes
GROUP BY nombre_sucursal, cod_almacen, ciudad_ubicacion, capacidad_m3, tel_contacto, tipo_gestion, ubicacion_geografica
HAVING COUNT(*) > 1;


-- Convertimos ALM-001 en ALM-001, ALM-002, etc., usando su ID único
UPDATE almacenes 
SET codigo_almacen = CONCAT('ALM-', LPAD(id, 3, '0'));

-- si los datos son idénticos lo eliminamos
DELETE a1 FROM almacenes a1
INNER JOIN almacenes a2 
WHERE a1.id > a2.id 
  AND a1.codigo_almacen = a2.codigo_almacen;

-- COLUMNA CAPACIDAD_M3

start transaction;
-- Paso 1: Extraer solo los números y limpiar el texto
UPDATE almacenes 
SET capacidad_m3 = CASE 
    -- Si contiene al menos un número, extraemos solo los dígitos
    WHEN capacidad_m3 REGEXP '[0-9]' 
        THEN REGEXP_REPLACE(capacidad_m3, '[^0-9]', '')
    -- Si no tiene números (ej: 'Infinita'), lo ponemos a NULL directamente
    ELSE NULL 
END;

select * from almacenes;

-- Paso 2: Convertir la columna a tipo numérico real
-- Usamos UNSIGNED porque una capacidad no puede ser negativa
ALTER TABLE almacenes MODIFY COLUMN capacidad_m3 INT UNSIGNED;


-- COLUMNA TIPO_GESTION

start transaction;
-- Paso 1: Convertir todo a MAYÚSCULAS y quitar espacios en blanco
UPDATE almacenes 
SET tipo_gestion = UPPER(TRIM(tipo_gestion));

-- Paso 2: Anular valores que no sean los oficiales
UPDATE almacenes 
SET tipo_gestion = NULL -- o PROPIA
WHERE tipo_gestion NOT IN ('PROPIA', 'SUBCONTRATA');




-- ========================================TABLA CLIENTES=========================================

select * from clientes;

-- COLUMNA CIF_NIF
SELECT cif_nif, COUNT(*) as repeticiones, GROUP_CONCAT(id) as ids_afectados
FROM clientes
GROUP BY cif_nif
HAVING COUNT(*) > 1;

start transaction;
set sql_safe_updates=0;
update clientes set cif_nif=trim(cif_nif);
-- 1. Quitamos cualquier carácter que no sea letra o número
-- 2. Lo pasamos todo a MAYÚSCULAS
UPDATE clientes 
SET cif_nif = UPPER(REGEXP_REPLACE(cif_nif, '[^a-zA-Z0-9]', ''));

select * from clientes
where length(cif_nif)!=9;


-- -------------------------------------------------------------------------------------------------
-- COLUMNA LIMITE_CREDITO_SUCIO
explain clientes;

alter table clientes
add column limite_credito_dolares varchar (50)
after limite_credito_sucio;
alter table clientes
add column limite_credito_euros varchar (50)
after limite_credito_dolares;

start transaction;
update clientes
SET limite_credito_dolares = limite_credito_sucio
where upper(limite_credito_sucio) like '%USD%'
or limite_credito_sucio like '%$%';

update clientes
SET limite_credito_dolares = CAST(
    TRIM(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
						REPLACE(limite_credito_dolares, ' ', ''),
					'EUR',''),
                'USD', ''), 
            '€', ''), 
        ',', '.')
    ) AS DECIMAL(10,2)
);

select * from clientes;

alter table clientes modify column limite_credito_dolares decimal (10,2),
add constraint chk_limite_credito_dolares check (limite_credito_dolares >= 0);

start transaction;
update clientes
SET limite_credito_euros = limite_credito_sucio
where upper(limite_credito_sucio) like '%EUR%'
or limite_credito_sucio like '%€%';

update clientes
SET limite_credito_euros = CAST(
    TRIM(
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
						REPLACE(limite_credito_euros, ' ', ''),
					'EUR',''),
                'USD', ''), 
            '€', ''), 
        ',', '.')
    ) AS DECIMAL(10,2)
);

alter table clientes modify column limite_credito_euros decimal (10,2),
add constraint chk_limite_credito_euros check (limite_credito_euros >= 0);

START TRANSACTION;

-- Pasamos los dólares convertidos a la columna de euros
-- Solo para aquellos registros que originalmente eran dólares
UPDATE clientes 
SET limite_credito_euros = ROUND(limite_credito_dolares / 1.17, 2)
WHERE limite_credito_dolares IS NOT NULL;

-- Pasamos los euros convertidos a la columna de dolares
-- Solo para aquellos registros que originalmente eran euros
UPDATE clientes 
SET limite_credito_dolares = ROUND(limite_credito_euros * 1.17, 2)
WHERE limite_credito_euros IS NOT NULL;

savepoint creditos;

-- -------------------------------------------------------------------------------------------

-- ESTO FUNCIONA PARA CAMBIAR LA RAZON SOCIAL CON EL NÚMERO DE ID.
UPDATE clientes 
SET razon_social = CONCAT('Empresa ', id, ' S.L');

--  -------------------------------------------------------------------------------------------
-- COLUMNA FECHA_ALTA_CLIENTE

-- 1. Preparamos el terreno
ALTER TABLE clientes ADD COLUMN f_alta_clean DATE AFTER fecha_alta_cliente;

start transaction;
UPDATE clientes SET f_alta_clean = CASE 
    -- 1. FORMATOS DE 4 DÍGITOS (Sin ambigüedad)
    WHEN fecha_alta_cliente LIKE '____-__-__' THEN STR_TO_DATE(fecha_alta_cliente, '%Y-%m-%d')
    WHEN fecha_alta_cliente LIKE '____/__/__' THEN STR_TO_DATE(fecha_alta_cliente, '%Y/%m/%d')
    WHEN fecha_alta_cliente LIKE '__/__/____' THEN STR_TO_DATE(fecha_alta_cliente, '%d/%m/%Y')
    WHEN fecha_alta_cliente LIKE '__-__-____' THEN STR_TO_DATE(fecha_alta_cliente, '%d-%m-%Y')

    -- 2. FORMATOS DE 2 DÍGITOS (Aplicando tu regla: MES SIEMPRE EN MEDIO)
    -- Asumimos DD-MM-YY (Día/Mes/Año)
    WHEN fecha_alta_cliente LIKE '__/__/__'   THEN STR_TO_DATE(fecha_alta_cliente, '%d/%m/%y')
    WHEN fecha_alta_cliente LIKE '__-__-__'   THEN STR_TO_DATE(fecha_alta_cliente, '%d-%m-%y')
    
    ELSE NULL 
END;

select * from clientes;

start transaction;
update clientes 
set cif_nif=null
where cif_nif not regexp '^[A-Z]{1}[0-9]{8}';

select * from clientes;



-- =====================================TABLA INCIDENCIAS===================================================

select * from incidencias;

-- SANEAMOS COSTE_ASOCIADO_SUCIO

start transaction;
UPDATE incidencias 
SET coste_asociado_sucio = REGEXP_REPLACE(
    REPLACE(coste_asociado_sucio, ',', '.'), -- 1. Cambiamos comas por puntos primero
    '[^0-9.]',                               -- 2. Buscamos todo lo que NO sea (^) 0-9 o punto
    ''                                       -- 3. Lo reemplazamos por nada (borrar)
);

-- Verificación: Mira si algún registro se ha quedado vacío o raro
SELECT id, coste_asociado_sucio 
FROM incidencias 
WHERE coste_asociado_sucio = '' OR coste_asociado_sucio IS NULL;




-- ==========================================TABLA ENVIOS=====================================================

select * from envios;

select f_salida from envios
where f_salida not like '%/%/%' or '%-%-%';

select tracking_number from envios
where tracking_number not regexp '^TRK-[0-9]';

-- ¿Hay IDs repetidos? (Si sale algo aquí, la PK fallará)
SELECT id, COUNT(*) 
FROM envios GROUP BY id HAVING COUNT(*) > 1;


-- ----------------------------------------------------------------------------------------
-- TRACKING_NUMBER

-- ¿Hay Tracking repetidos?
SELECT tracking_number, COUNT(*) 
FROM envios GROUP BY tracking_number HAVING COUNT(*) > 1;

select *
from envios
where tracking_number = 'TRK-10001597';

-- una opción
-- Agregamos un sufijo "-DUP" al segundo registro de cada pareja
-- Nota: Esto solo funciona si el campo tiene espacio suficiente (VARCHAR)
UPDATE envios e
JOIN (
    SELECT id, ROW_NUMBER() OVER(PARTITION BY tracking_number ORDER BY id) as fila
    FROM envios
) t ON e.id = t.id
SET e.tracking_number = CONCAT(e.tracking_number, '-DUP')
WHERE t.fila > 1;

-- crear tabla cuarentena
CREATE TABLE envios_duplicados_log LIKE envios;

-- enviarlos a otra tabla
INSERT INTO envios_duplicados_log
SELECT * FROM (
    SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY tracking_number ORDER BY id ASC) as fila
    FROM envios
) AS temp
WHERE temp.fila > 1;

-- ¿Son filas exactamente iguales?
SELECT id,tracking_number,cliente_id,vehiculo_id,empleado_id,f_salida,f_llegada_prevista,f_entrega_real,peso_kg_bruto,volumen_m3,importe_envio,seguro_contratado,
estado_envio,almacen_destino_id,prioridad,ruta_origen_ciudad,ruta_destino_ciudad,ruta_distancia_km,ruta_peajes_estimados,ruta_tiempo_estimado_h, COUNT(*)
FROM envios
GROUP BY id,tracking_number,cliente_id,vehiculo_id,empleado_id,f_salida,f_llegada_prevista,f_entrega_real,peso_kg_bruto,volumen_m3,importe_envio,seguro_contratado,
estado_envio,almacen_destino_id,prioridad,ruta_origen_ciudad,ruta_destino_ciudad,ruta_distancia_km,ruta_peajes_estimados,ruta_tiempo_estimado_h
HAVING COUNT(*) > 1;

-- -------------------------------------------------------------------------------
-- FECHAS

-- Ver cuántas fechas son basura (no tienen formato AAAA-MM-DD)
SELECT f_salida FROM envios 
WHERE f_salida REGEXP '[a-zA-Z]'; -- Detecta "mañana", "ayer", etc.

-- ------------------------------------------------------------------------------------

-- TABLA AUXILIAR PARA DATOS


-- 1. Creamos la tabla de cuarentena con la misma estructura que envios
CREATE TABLE envios_cuarentena AS 
SELECT * FROM envios WHERE 1 = 0; 

-- 2. Movemos (Insertamos) los registros con fechas textuales
INSERT INTO envios_cuarentena
SELECT * FROM envios 
WHERE f_salida REGEXP '[a-zA-Z]';

-- 3. Los eliminamos de la tabla principal
DELETE FROM envios 
WHERE f_salida REGEXP '[a-zA-Z]';

-- -------------------------------------------------------------------------------------------------
-- IMPORTE ENVIO

-- Buscar cualquier cosa que NO sea Euro o número
SELECT importe_envio FROM envios 
WHERE importe_envio NOT LIKE '%€%' 
  AND UPPER(importe_envio) NOT LIKE '%EUR%'
  AND importe_envio REGEXP '[a-zA-Z]' -- Si hay letras que no sean EUR, hay otra moneda
  AND importe_envio NOT REGEXP '^[0-9,. ]+$';
  
  -- --------------------------------------------------------------------------------
  -- RUTA_DISTANCIA_KM
  
-- Buscar unidades de distancia extrañas (millas, metros)
SELECT ruta_distancia_km FROM envios 
WHERE UPPER(ruta_distancia_km) NOT LIKE '%KM%' 
  AND UPPER(ruta_distancia_km) NOT LIKE '%KILOMETROS%'
  AND ruta_distancia_km REGEXP '[a-zA-Z]';
  
select * from envios;

SELECT e.id as id_envio,e.cliente_id, c1.id, c2.id
FROM 
	envios e 
		JOIN 
	clientes c1 ON e.cliente_id = c1.id 
		JOIN 
	clientes c2 ON c1.razon_social = c2.razon_social
WHERE c2.id < c1.id;

select * from clientes;




-- ======================================TABLA VEHICULOS=======================================================

select * from vehiculos;

-- ----------------------------------------------------------------

-- COORDENADAS_GPS

-- Añadimos latitud y longitud como tipos DECIMAL para mantener la precisión geográfica.

ALTER TABLE vehiculos 
ADD COLUMN latitud_gps DECIMAL(10, 8),
ADD COLUMN longitud_gps DECIMAL(11, 8);

UPDATE vehiculos 
SET coordenadas_gps = TRIM(REPLACE(coordenadas_gps, ' ', '')) 
WHERE coordenadas_gps IS NOT NULL;

UPDATE vehiculos 
SET latitud = CAST(SUBSTRING_INDEX(coordenadas_gps, ',', 1) AS DECIMAL(10,8)),
    longitud = CAST(SUBSTRING_INDEX(coordenadas_gps, ',', -1) AS DECIMAL(11,8))
WHERE coordenadas_gps IS NOT NULL AND coordenadas_gps LIKE '%,%';

-- Ver cuántos registros están "rotos"
SELECT id, coordenadas_gps FROM vehiculos 
WHERE coordenadas_gps NOT LIKE '%,%' 
   OR coordenadas_gps REGEXP '[a-zA-Z]';
   
-- --------------------------------------------------------------------------------------------
-- AÑO_FABRICACION

start transaction;
UPDATE vehiculos 
SET año_fabricacion = REGEXP_REPLACE(
    REPLACE(año_fabricacion, ',', '.'), -- 1. Cambiamos comas por puntos primero
    '[^0-9.]',                               -- 2. Buscamos todo lo que NO sea (^) 0-9 o punto
    ''                                       -- 3. Lo reemplazamos por nada (borrar)
);
select * from vehiculos;
rollback;

-- ----------------------------------------------------------------------------------------------
-- capacidad_carga_kg

-- comprobamos que todo sea kg
SELECT capacidad_carga_kg FROM vehiculos
WHERE UPPER(capacidad_carga_kg) NOT LIKE '%KG%' 
  AND UPPER(capacidad_carga_kg) NOT LIKE '%KILOGRAMOS%'
  AND capacidad_carga_kg REGEXP '[a-zA-Z]';
  
-- dejamos solo los números
start transaction;
UPDATE vehiculos 
SET capacidad_carga_kg = REGEXP_REPLACE(
    REPLACE(capacidad_carga_kg, ',', '.'), -- 1. Cambiamos comas por puntos primero
    '[^0-9.]',                               -- 2. Buscamos todo lo que NO sea (^) 0-9 o punto
    ''                                       -- 3. Lo reemplazamos por nada (borrar)
);
select * from vehiculos;
rollback;

-- -------------------------------------------------------------------------------------------
-- MATRICULA

start transaction;
set sql_safe_updates=0;
UPDATE vehiculos 
SET matricula = UPPER(TRIM(REPLACE(REPLACE(matricula, ' ', ''), '-', '')))
WHERE matricula IS NOT NULL;

UPDATE vehiculos 
SET matricula = CONCAT(LEFT(matricula, 4), '-', RIGHT(matricula, 3))
WHERE LENGTH(matricula) = 7 AND matricula NOT LIKE '%-%';


-- Identificamos qué matrículas no tienen 4 números seguidos de 3 letras (formato español moderno).
SELECT * FROM vehiculos 
WHERE matricula NOT REGEXP '^[0-9]{4}-[A-Z]{3}$';

CREATE TABLE vehiculos_errores LIKE vehiculos;

INSERT INTO vehiculos_errores 
SELECT * FROM vehiculos 
WHERE matricula NOT REGEXP '^[0-9]{4}-[A-Z]{3}$' OR matricula IS NULL;

delete from vehiculos
WHERE matricula NOT REGEXP '^[0-9]{4}-[A-Z]{3}$' OR matricula IS NULL;

-- una opcion para los null
UPDATE vehiculos 
SET matricula = '0000-SINDATO' 
WHERE matricula IS NULL;

-- hay una matrícula que se repite...
SELECT matricula, COUNT(*) 
FROM vehiculos GROUP BY matricula HAVING COUNT(*) > 1;

-- Marcamos el segundo registro como duplicado para revisión manual
UPDATE vehiculos 
SET matricula = CONCAT(matricula, '-REVISAR')
WHERE matricula = '5208-DEF' 
AND id = (SELECT MAX(id) FROM (SELECT * FROM vehiculos) AS temp WHERE matricula = '5208-DEF');

-- 1. Copiamos el registro con el ID más alto (el más nuevo/duplicado) al log
INSERT INTO vehiculos_errores
SELECT * FROM vehiculos 
WHERE matricula = '5208-DEF' 
ORDER BY id DESC LIMIT 1;

-- 2. Lo borramos de la tabla principal
DELETE FROM vehiculos 
WHERE matricula = '5208-DEF' 
ORDER BY id DESC LIMIT 1;

rollback;

select * from vehiculos_errores;
-- ====================================================TABLA MANTENIMIENTO_FLOTA==============================================================

select * from mantenimientos_flota;

alter table mantenimientos_flota
add constraint fk_mantenimiento_vehiculos foreign key (vehiculo_id)
references vehiculos(id);



SELECT mf.id as id_mantenimiento,mf.vehiculo_id, v1.id,v1.matricula, v2.id, v2.matricula
FROM 
	mantenimientos_flota mf 
		JOIN 
	vehiculos v1 ON mf.vehiculo_id = v1.id 
		JOIN 
	vehiculos v2 ON v1.matricula = v2.matricula
WHERE v2.id < v1.id;

-- --------------------------------------------------------------------------------------------------------------
-- para las fechas con años:
UPDATE envios 
SET fecha_final = CASE 
    -- Si la ÚLTIMA parte es menor a 24 (ej: 19), asumimos que el año está al PRINCIPIO
    WHEN CAST(SUBSTRING_INDEX(fecha_texto, '/', -1) AS UNSIGNED) < 24 
        THEN STR_TO_DATE(fecha_texto, '%y/%m/%d') 
    
    -- Si la ÚLTIMA parte es 24 o mayor, asumimos que es el año (DD/MM/YY)
    ELSE STR_TO_DATE(fecha_texto, '%d/%m/%y')
END
WHERE fecha_texto LIKE '%/%/%';

UPDATE vehiculos
SET matricula = CASE 
    WHEN matricula IS NULL THEN 'SIN-MATRICULA'
    WHEN matricula REGEXP '^[0-9]{4}[A-Z]{3}$' THEN CONCAT(LEFT(matricula, 4), '-', RIGHT(matricula, 3)) -- Falta el guion
    ELSE 'FORMATO-INVALIDO'
END
WHERE matricula NOT REGEXP '^[0-9]{4}-[A-Z]{3}$' OR matricula IS NULL;

UPDATE vehiculos 
SET matricula = '0000-XXX' 
WHERE matricula NOT REGEXP '^[0-9]{4}-[A-Z]{3}$' 
   OR matricula IS NULL;