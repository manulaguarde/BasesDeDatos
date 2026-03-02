DROP DATABASE IF EXISTS ejercicio3;
CREATE DATABASE ejercicio3;
USE ejercicio3;

CREATE TABLE empleados(
	id_empleado SMALLINT AUTO_INCREMENT,
    dni VARCHAR(10) NOT NULL,
    salario DECIMAL (10,2) DEFAULT 1200.00, -- 1200 por defecto
    estado VARCHAR(8) DEFAULT 'ACTIVO',
    CONSTRAINT pk_empleado PRIMARY KEY (id_empleado),
    CONSTRAINT uq_dni UNIQUE (dni),
    CONSTRAINT chk_salario CHECK (salario>=0),
    CONSTRAINT chk_estado CHECK (estado IN('ACTIVO','INACTIVO'))
);

CREATE TABLE proyectos(
	id_proyecto SMALLINT AUTO_INCREMENT, 
    nombre VARCHAR(20) NOT NULL, 
	id_departamento SMALLINT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    CONSTRAINT pk_proyectos PRIMARY KEY (id_proyecto),
    CONSTRAINT uq_nombre UNIQUE (nombre),
    CONSTRAINT fk_proyecto_departamento 
		FOREIGN KEY (id_departamento)
        REFERENCES departamentos(id_departamento),
	CONSTRAINT chk_fechas_fin CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio)
);

CREATE TABLE asignaciones(
	id_empleado SMALLINT,
    id_proyecto SMALLINT, 
    horas_asignadas SMALLINT DEFAULT 0,
    CONSTRAINT pk_asignaciones PRIMARY KEY (id_empleado,id_proyecto),
    CONSTRAINT fk_asignaciones_empleado FOREIGN KEY (id_empleado)
		REFERENCES empleados(id_empleado) ON DELETE CASCADE,
	CONSTRAINT fk_asignaciones_proyecto FOREIGN KEY (id_proyecto)
		REFERENCES proyectos(id_proyecto) ON DELETE CASCADE
);

CREATE TABLE departamentos(
	id_departamento SMALLINT AUTO_INCREMENT,
    codigo_depto VARCHAR(5) NOT NULL,
    nombre VARCHAR(30) NOT NULL, 
    presupuesto DECIMAL (14,2) NOT NULL, 
    CONSTRAINT pk_departamentos PRIMARY KEY (id_departamento),
    CONSTRAINT uq_codigo_depto UNIQUE (codigo_depto),
    CONSTRAINT chk_presupuesto CHECK (presupuesto >= 0)
);