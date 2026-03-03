DROP DATABASE IF EXISTS ejercicio1;
CREATE DATABASE ejercicio1;
USE ejercicio1;

CREATE TABLE vehiculos(
	id_vehiculo INT AUTO_INCREMENT,
    matricula VARCHAR(10),
    tipo VARCHAR (50),
    precio FLOAT,
    fecha_compra TIMESTAMP,
    CONSTRAINT pk_vehiculos PRIMARY KEY(id_vehiculo),
    CONSTRAINT uq_unique UNIQUE (matricula),
    -- CONSTRAINT chk_longitud_minima_matricula CHECK (LENGTH(matricula) >6),
    CONSTRAINT chk_matricula_alfanumerica CHECK (matricula REGEXP '^[BCDFGHJKLMNPQRSTVWXYZ0-9]{6,10}$'),
	CONSTRAINT chk_precio_no_negativo CHECK (precio >=0)
);
-- exprecion regular : REGEXP
-- '^ =>empieza por....
-- 0-9 de 0 hasta 9
-- {6,10} que tenga entre 6 y 10 carácteres

