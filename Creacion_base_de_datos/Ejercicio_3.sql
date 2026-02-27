DROP DATABASE IF EXISTS ejercicio3;
CREATE DATABASE ejercicio3;
USE ejercicio3;

CREATE TABLE empleados(
	id_empleado SMALLINT AUTO_INCREMENT,
    dni VARCHAR(10),
    salario FLOAT,
    estado VARCHAR(8) DEFAULT 'ACTIVO',
    CONSTRAINT pk_empleado PRIMARY KEY (id_empleado),
    CONSTRAINT uq_dni UNIQUE (dni),
    
    
);