-- Una vez cargada la base de datos, veo el panorama en cada tabla

use gha_analytics;

show tables;

SELECT 
    *
FROM
    especialidades;
    
SELECT 
    *
FROM
    medicos;
    
SELECT 
    *
FROM
    pacientes;
    
explain pacientes;

SELECT 
    *
FROM
    raw_import_visitas;
    
SELECT 
    *
FROM
    visitas;

explain visitas;
    


-- ========1. Normalización de Identidad (Pacientes)==========

set sql_safe_updates =0;
start transaction;

-- primero veo que pacientes se repiten
SELECT 
    *
FROM
    pacientes p1
        JOIN
    pacientes p2 ON p1.nif = p2.nif
WHERE
    p2.id < p1.id;

-- a su vez compruebo donde estos pacientes repetidos tienen visitas con ambos id
-- compruebo en visitas porque esta es la única tabla donde pueden haber conflictos, ya que están unidas por paciente_id
SELECT 
    v.id,
    v.paciente_id,
    p1.id AS paciente1_id,
    p2.id AS paciente2_d
FROM
    visitas v
        JOIN
    pacientes p1 ON v.paciente_id = p1.id
        JOIN
    pacientes p2 ON p1.email = p2.email
WHERE
    p2.id < p1.id;


-- intento hacer la union de las tablas pero falla porque hay pacientes inexistentes en la tabla visitas

-- alter table visitas
-- add constraint fk_visitas_pacientes foreign key (paciente_id) references pacientes(id)
-- on update cascade on delete restrict;


-- Voy a limpiar los nif y nombres de la base de datos, que los nif sean 8 números y una letra en mayuscula
set sql_safe_updates =0;
start transaction;

SELECT 
    *
FROM
    pacientes;
    
    
UPDATE pacientes 
SET 
    nif = TRIM(nif);
UPDATE pacientes 
SET 
    nif = REPLACE(nif, '-', '');
UPDATE pacientes 
SET 
    nombre_completo = TRIM(nombre_completo);
savepoint nif_y_nombres;


-- elimino los nif que no cumplen con el formato como se pide en el ejercicio.
DELETE FROM pacientes 
WHERE
    nif NOT REGEXP '^[0-9]{8}[A-Z]$';

commit;
set sql_safe_updates =1;

set sql_safe_updates =0;
start transaction;

-- otra manera de revisar que nif (y por lo tanto pacientes) se repiten
SELECT 
    nif, COUNT(*)
FROM
    pacientes
GROUP BY nif
HAVING COUNT(*) > 1;

-- corrijo las visitas que tenían el mismo paciente pero con id distintos para que ahora hagan referencia al mismo paciente
UPDATE visitas v
        JOIN
    pacientes p1 ON v.paciente_id = p1.id
        JOIN
    pacientes p2 ON p1.email = p2.email 
SET 
    v.paciente_id = p2.id
WHERE
    p2.id < p1.id;

-- elimino duplicados de la tabla pacientes
DELETE p1 FROM pacientes p1
        JOIN
    pacientes p2 ON p1.nif = p2.nif 
WHERE
    p2.id < p1.id;

SELECT 
    *
FROM
    visitas;
    
SELECT 
    *
FROM
    pacientes;

commit;

set sql_safe_updates =1;

-- agrego las restricciones para nif
alter table pacientes
modify nif varchar(9) not null,
add constraint uq_nif unique (nif),
add constraint chk_nif check (length(nif)=9);


set sql_safe_updates =0;
start transaction;


-- =========2. Consistencia de Colegiados (Médicos)===========
-- veo las inconsistencias en la tabla medicos
SELECT 
    *
FROM
    medicos;

-- selecciono los números de colegiado que no cumplan con el formato
SELECT 
    num_colegiado
FROM
    medicos
WHERE
    num_colegiado REGEXP '[^a-zA-Z0-9]';

-- corrijo el formato de num_colegiado, primero dejo solo los números
UPDATE medicos 
SET 
    num_colegiado = REPLACE(REPLACE(num_colegiado, '-', ''),
        '/',
        '');
        
UPDATE medicos 
SET 
    num_colegiado = REPLACE(REPLACE(num_colegiado, 'COL', ''),
        'INV',
        '');
        
-- esto es una nota para mí
-- REGEXP_REPLACE busca cualquier cosa que NO sea un número [^0-9] y la borra
-- UPDATE medicos 
-- SET num_colegiado = REGEXP_REPLACE(num_colegiado, '[^0-9]', '');

start transaction;

-- Queremos que todos tengan 6 dígitos (2 de provincia + 4 de número) y comiencen por COL-.
-- formato: COL-xx-xxxx
-- Si '999' tiene solo 3, LPAD le pondrá ceros a la izquierda: '000999'
UPDATE medicos 
SET num_colegiado = LPAD(num_colegiado, 6, '0');
UPDATE medicos 
SET 
    num_colegiado = CONCAT('COL-',
            LEFT(num_colegiado, 2),
            '-',
            SUBSTRING(num_colegiado, 3));

alter table medicos
add constraint chk_num_colegiado check (num_colegiado regexp '^COL-[0-9]{2}-[0-9]{4}$');

-- hice mal, debería haber guardado una tabla con los datos originales por el num_colegiado INV999
-- ahora le cambié sin consultar el num_colegiado pero estaba incorrecto desde un comienzo.


-- ==========3. Integridad Referencial=============

-- busco los médicos que no tienen una especialidad
SELECT 
    *
FROM
    medicos
WHERE
    especialidad_id NOT IN (SELECT 
            id
        FROM
            especialidades);

start transaction;
SELECT 
    *
FROM
    especialidades;
    
SELECT 
    *
FROM
    medicos;
    
-- corrijo aquellos médicos que no tenían especialidad y les agrego que ahora la especialidad sea 'Medicina General'
UPDATE medicos 
SET 
    especialidad_id = (SELECT 
            id
        FROM
            especialidades
        WHERE
            nombre = 'Medicina General')
WHERE
    especialidad_id NOT IN (SELECT 
            id
        FROM
            especialidades);

commit;


-- uno ambas tablas (medicos y especialidades) mediante especialidad_id
alter table medicos
add constraint fk_medicos_especialidades foreign key (especialidad_id)
references especialidades(id)
on update cascade on delete restrict;

-- ============4. Normalización y División de Tablas==============


-- creo la tabla de los seguros de los pacientes 
CREATE TABLE `seguros_pacientes` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `paciente_id` INT NOT NULL,
    `num_poliza` VARCHAR(50) NOT NULL,
    `estado_poliza` VARCHAR(20) NOT NULL DEFAULT 'ACTIVA',
    PRIMARY KEY (`id`),
    CONSTRAINT fk_seguros_pacientes_pacientes FOREIGN KEY (paciente_id)
        REFERENCES pacientes (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
)  ENGINE=INNODB AUTO_INCREMENT=10 DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_UNICODE_CI;

start transaction;

-- copio los datos del id, numero de poliza de los pacientes a la tabla seguros_pacientes
insert into seguros_pacientes(paciente_id,num_poliza,estado_poliza)
SELECT 
    id, -- selecciono el id de cada paciente para que sea la clave foránea de la tabla seguro_pacientes
    COALESCE(num_poliza, 'SIN-POLIZA'), -- si el paciente tiene numero de póliza este se copia, se marca que no tiene poliza (la poliza no puede ser null)
    CASE 
        WHEN num_poliza IS NULL THEN 'INACTIVA' -- si la poliza que se pasa es null el estado será 'inactiva' y se marcara como 'sin-poliza'
        ELSE 'ACTIVA' -- si existe la poliza, está 'activa' ya que es el estado por defecto
    END
FROM pacientes;

-- tengo que ver que hacer con el paciente con id 6 (paciente de borrado)
-- es un paciente que claramente no es útil pero como no hay instrucciones de momento lo dejo.


-- compruebo la tabla nueva
SELECT 
    *
FROM
    seguros_pacientes;
    
SELECT 
    *
FROM
    pacientes;

-- elimino la columna de num_poliza de pacientes para asegurar la integridad referencial
alter table pacientes drop column num_poliza;

SELECT 
    *
FROM
    visitas;

start transaction;

-- ======== sanear la columna de importes de las visitas (parte del punto 5)============
SELECT 
    importe_sucio
FROM
    visitas
WHERE
    importe_sucio NOT LIKE '%.%';

UPDATE visitas 
SET 
    importe_sucio = TRIM(importe_sucio);

SELECT 
    importe_sucio
FROM
    visitas
WHERE
    importe_sucio NOT LIKE '%.__';

UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, '€', '');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, 'EUR', '');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, 'Gratis', '0.00');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, 'GRATIS', '0.00');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, ',', '.');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, '$', '');
    

SELECT 
    importe_sucio
FROM
    visitas
WHERE
    importe_sucio NOT LIKE '% %';

UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, ' ', '');

-- creo tabla donde irán los importes ya limpios
alter table visitas
add column importe varchar (50)
after importe_sucio;

-- migro los importes ya saneados
UPDATE visitas 
SET 
    importe = importe_sucio;


explain visitas;



commit;

-- =========6. Ingesta de Datos Externos=======
-- dejo el punto 5) para despues, porque primero quiero terminar de sanear todas las columnas
-- y como aun hay importes que no están correctos que tengo que agregar, no puedo hacer la columna copago_estimado donde tengo que calcular a raiz del importe
SELECT 
    *
FROM
    pacientes;
    

SELECT 
    *
FROM
    raw_import_visitas;
    
-- comienzo migrando los datos que refieren a pacientes de la tabla raw_import_visitas.
-- ignore me permite que si el nif ya se encuentra (y este es único) salte la restricción, omita ese nif y continúe
INSERT IGNORE INTO pacientes (nif, nombre_completo, tel_contacto)
SELECT 
    TRIM(SUBSTRING_INDEX(raw_data, '|', 1)), -- Extraigo nif (primer bloque)
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(raw_data, '|', 2), '|', -1)), -- Extraigo nombre (bloque central)
    raw_phone -- Cogemos el teléfono tal cual viene (se saneará todo junto luego)
FROM raw_import_visitas;

-- comprobé que no haya duplicados
SELECT 
    *
FROM
    pacientes p1
        JOIN
    pacientes p2 ON p1.nif = p2.nif
WHERE
    p2.id < p1.id;

SELECT 
    *
FROM
    raw_import_visitas;
    
SELECT 
    *
FROM
    visitas;
    
explain visitas;

-- Hago lo mismo con los datos referidos a visitas de la tabla raw_import_pacientes
INSERT INTO visitas (paciente_id, fecha_visita, importe_sucio)
SELECT 
    p.id, -- selecciona el id de la tabla paciente (uno por uno)
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(riv.raw_data, '|', 3), '|', -1)),  -- Extraigo la Fecha (3er bloque)
    TRIM(SUBSTRING_INDEX(riv.raw_data, '|', -1))  -- Extraigo el importe sucio (4º bloque)
FROM raw_import_visitas riv 
JOIN pacientes p ON p.nif = TRIM(SUBSTRING_INDEX(riv.raw_data, '|', 1)); -- Busca que coincida el ID del paciente que acabamos de importar/actualizar

-- vuelvo a sanear importes de la tabla visitas

UPDATE visitas 
SET 
    importe_sucio = TRIM(importe_sucio);
    UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, '€', '');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, 'EUR', '');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, 'Gratis', '0.00');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, 'GRATIS', '0.00');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, ',', '.');
    
UPDATE visitas 
SET 
    importe_sucio = REPLACE(importe_sucio, '$', '');
    
UPDATE visitas 
SET 
    importe = importe_sucio;

-- ahora con todos los importes saneados modifico la columna a decimal y agrego un constraint para que no pueda haber importes negativos
alter table visitas modify column importe decimal(10,2) not null,
add constraint chk_importe check (importe >=0);

-- elimino la columna importe_sucio que ya no sirve 
alter table visitas drop column importe_sucio;


-- ===========5. Columnas Calculadas y Blindaje=========

alter table visitas add column copago_estimado decimal (10,2) not null
after importe;

alter table visitas modify column descuento_aplicado decimal(10,2);

start transaction;
UPDATE visitas 
SET 
    copago_estimado = importe * 0.20;
commit;

-- =========COSAS QUE QUEDARON PENDIENTES==========
-- CORREGIR EMAILS
-- buscar emails que están mal
SELECT 
    id, nif, email
FROM
    pacientes
WHERE
    email NOT LIKE '%@%.%';


start transaction;
-- CORREGIRLOS

UPDATE pacientes 
SET 
    email = REPLACE(email, ',con', '.com');
UPDATE pacientes 
SET 
    email = 'email-incorrecto'
WHERE
    email NOT LIKE '%@%.%';

select * from pacientes;

explain pacientes;

-- mi decisión es que de momento el email pueda ser null, porque tengo pacientes sin email, pero el email debe ser unique,
-- y si se quiere que el email sea obligatorio se le pondra el not null una vez solucionado los que son null de momento
alter table pacientes 
add constraint uq_email unique(email);


-- SANEAMIENTO DE TELÉFONOS
-- busco los que no son solo números (para filtrar un poco)
SELECT 
    id, nif, nombre_completo, tel_contacto
FROM
    pacientes
WHERE
    tel_contacto REGEXP '[^0-9]$';


start transaction;

UPDATE pacientes 
SET 
    tel_contacto = TRIM(tel_contacto);
    
UPDATE pacientes 
SET 
    tel_contacto = REPLACE(tel_contacto, '+34', '')
WHERE
    tel_contacto LIKE '+34%';
    
UPDATE pacientes 
SET 
    tel_contacto = REPLACE(tel_contacto, ' ', '');
    
UPDATE pacientes 
SET 
    tel_contacto = REPLACE(tel_contacto, '0034', '')
WHERE
    tel_contacto LIKE '0034%';
    
UPDATE pacientes 
SET 
    tel_contacto = REPLACE(tel_contacto, '-', '');

SELECT 
    *
FROM
    pacientes;
commit;

-- SANEAMIENTO FECHAS DE NACIMIENTO
start transaction;
-- convertimos los distintos formatos que hay de las fechas al formato date
UPDATE pacientes 
SET 
    f_nacimiento = CASE
        WHEN f_nacimiento LIKE '____.%.%' THEN STR_TO_DATE(f_nacimiento, '%Y.%m.%d')
        WHEN f_nacimiento LIKE '%-%-____' THEN STR_TO_DATE(f_nacimiento, '%d-%m-%Y')
        WHEN f_nacimiento LIKE '%/%/____' THEN STR_TO_DATE(f_nacimiento, '%d/%m/%Y')
        WHEN f_nacimiento LIKE '____-%-%' THEN STR_TO_DATE(f_nacimiento, '%Y-%m-%d')
        ELSE f_nacimiento
    END
WHERE
    f_nacimiento LIKE '____.%.%'
        OR f_nacimiento LIKE '%-%-____'
        OR f_nacimiento LIKE '%/%/____'
        OR f_nacimiento LIKE '____-%-%';

-- lo mismo que con email como tengo algunas que son null todavía no puedo poner la obligatoriedad
-- hubo un problema: que los pacientes nuevos de la tabla raw_import_pacientes no tenían fecha de nacimiento, 
-- se les "crea la ficha" igual (en pacientes) pero hay que conseguir fecha de nacimiento. De momento queda así

-- cambiamos el formato de cadena a date, para poder realizar operaciones con DATE
alter table pacientes modify column f_nacimiento date;

-- SANEAMIENTO DE FECHAS DE VISITAS
SELECT 
    *
FROM
    visitas;

start transaction;
-- igual que con las fechas de nacimiento, corregimos formato.
UPDATE visitas 
SET 
    fecha_visita = CASE
        WHEN fecha_visita LIKE '____.%.% %:%' THEN STR_TO_DATE(fecha_visita, '%Y.%m.%d %H:%i')
        WHEN fecha_visita LIKE '____.%.% %:%' THEN STR_TO_DATE(fecha_visita, '%Y.%d.%m %H:%i')
        WHEN fecha_visita LIKE '%-%-____ %:%' THEN STR_TO_DATE(fecha_visita, '%d-%m-%Y %H:%i')
        WHEN fecha_visita LIKE '%/%/____ %:%' THEN STR_TO_DATE(fecha_visita, '%d/%m/%Y %H:%i')
        WHEN fecha_visita LIKE '____-%-% %:%' THEN STR_TO_DATE(fecha_visita, '%Y-%m-%d %H:%i')
        WHEN fecha_visita LIKE '____.%.%' THEN STR_TO_DATE(fecha_visita, '%Y.%m.%d')
        WHEN fecha_visita LIKE '%-%-____' THEN STR_TO_DATE(fecha_visita, '%d-%m-%Y')
        WHEN fecha_visita LIKE '%/%/____' THEN STR_TO_DATE(fecha_visita, '%d/%m/%Y')
        WHEN fecha_visita LIKE '____-%-%' THEN STR_TO_DATE(fecha_visita, '%Y-%m-%d')
        ELSE fecha_visita
    END
WHERE
    fecha_visita LIKE '____.%.% %:%'
        OR fecha_visita LIKE '%-%-____ %:%'
        OR fecha_visita LIKE '%/%/____ %:%'
        OR fecha_visita LIKE '____-%-% %:%'
        OR fecha_visita LIKE '____.%.%'
        OR fecha_visita LIKE '%-%-____'
        OR fecha_visita LIKE '%/%/____'
        OR fecha_visita LIKE '____-%-%';


commit;

-- Se ha optado por el tipo DATETIME para garantizar la integridad estructural y permitir el uso de funciones cronológicas. 
-- Los registros que carecían de hora en el origen han sido normalizados a las 00:00:00, asumiendo esta marca como 'hora no disponible' 
-- para evitar la pérdida de la información del día

alter table visitas modify column fecha_visita datetime not null;

-- comprobamos
SELECT 
    *
FROM
    visitas
ORDER BY fecha_visita;

-- corroboramos que no haya duplicidad de visitas
SELECT paciente_id, fecha_visita, COUNT(*) 
FROM visitas 
GROUP BY paciente_id, fecha_visita 
HAVING COUNT(*) > 1;

-- me doy cuenta que hay un paciente que tiene dos visitas en el mismo horario y fecha, elimino esto, y agrego restricciones para que no suceda
-- tanto para pacientes como para médicos.

DELETE v1 FROM visitas v1
INNER JOIN visitas v2 
ON v1.paciente_id = v2.paciente_id 
   AND v1.fecha_visita = v2.fecha_visita
WHERE v1.id > v2.id;

-- compruebo 
SELECT paciente_id, fecha_visita, COUNT(*) 
FROM visitas 
GROUP BY paciente_id, fecha_visita 
HAVING COUNT(*) > 1;

ALTER TABLE visitas 
ADD CONSTRAINT uq_paciente_horario UNIQUE (paciente_id, fecha_visita),
ADD CONSTRAINT uq_medico_horario UNIQUE (medico_id, fecha_visita);

SELECT 
    *
FROM
    visitas;

set sql_safe_updates =1;
set sql_safe_updates =0;

select * from visitas;
-- al final con paciente inexistente, medico inexistente y para visitas que no están relacionadas a un medico_id
-- que no me permiten hacer la union entre visitas, pacientes y medicos
-- decidí extraerlos a otra tabla temporal (ya que tienen datos de importes que pueden ser valiosos), hasta resolver que hacer con esos datos

CREATE TABLE `visitas_huerfanas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `paciente_id` int DEFAULT NULL,
  `medico_id` int DEFAULT NULL,
  `fecha_visita` datetime NOT NULL,
  `importe` decimal(10,2) NOT NULL,
  `copago_estimado` decimal(10,2) NOT NULL,
  `descuento_aplicado` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `observaciones` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_paciente_horario` (`paciente_id`,`fecha_visita`),
  UNIQUE KEY `uq_medico_horario` (`medico_id`,`fecha_visita`),
  CONSTRAINT `chk_importe_huerfanos` CHECK ((`importe` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



INSERT INTO visitas_huerfanas
SELECT v.* FROM visitas v
LEFT JOIN pacientes p ON v.paciente_id = p.id
WHERE p.id IS NULL;

INSERT INTO visitas_huerfanas
SELECT v.* FROM visitas v
LEFT JOIN medicos m ON v.medico_id = m.id
WHERE m.id IS NULL;

SELECT 
    *
FROM
    visitas_huerfanas;
    
SELECT 
    *
FROM
    visitas;

-- elimino de visitas estas que ya están en visitas_huerfanas
DELETE v FROM visitas v
LEFT JOIN pacientes p ON v.paciente_id = p.id
LEFT JOIN medicos m ON v.medico_id = m.id
WHERE p.id IS NULL OR m.id IS NULL;

-- para poder hacer la union entre visitas-pacientes y visitas-medicos

alter table visitas 
add constraint fk_visitas_pacientes 
foreign key (paciente_id) references pacientes(id)
on delete restrict on update cascade;


alter table visitas 
add constraint fk_visitas_medicos 
foreign key (medico_id) references medicos(id)
on delete restrict on update cascade;

set sql_safe_updates=1;

-- elimino la tabla raw_import_visitas, ya no tiene ninguna utilidad y solo genera "ruido" en la base de datos
drop table raw_import_visitas;

-- averiguar insert into duplicate key
