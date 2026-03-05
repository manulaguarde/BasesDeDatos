DROP DATABASE IF EXISTS gestion_universidad;
CREATE DATABASE gestion_universidad;
USE gestion_universidad;

CREATE TABLE profesores(
	id_profesor SMALLINT UNSIGNED AUTO_INCREMENT,
    nif VARCHAR(9), 
    nombre_completo VARCHAR (50), 
    salario DECIMAL (14,2) DEFAULT 2000.00, 
    id_facultad SMALLINT UNSIGNED,
	CONSTRAINT pk_profesores PRIMARY KEY (id_profesor),
    CONSTRAINT chk_nif CHECK (nif IS NOT NULL AND LENGTH(nif) = 9),
    CONSTRAINT uq_nif UNIQUE (nif),
    CONSTRAINT uq_nombre_completo UNIQUE (nombre_completo),
    CONSTRAINT chk_nombre_completo CHECK (nombre_completo IS NOT NULL),
    CONSTRAINT chk_salario CHECK (salario > 0),
    CONSTRAINT chk_id_facultad CHECK (id_facultad IS NOT NULL)
);

CREATE TABLE facultades(
	id_facultad SMALLINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(4),
    nombre VARCHAR(100),
    id_decano SMALLINT DEFAULT NULL, 
    CONSTRAINT pk_facultades PRIMARY KEY (id_facultad),
    CONSTRAINT uq_codigo UNIQUE (codigo),
    CONSTRAINT chk_codigo CHECK (codigo IS NOT NULL),
	CONSTRAINT uq_nombre UNIQUE (nombre),
    CONSTRAINT chk_nombre CHECK (nombre IS NOT NULL AND LENGTH(nombre) =4 ), -- PREGUNTAR
    CONSTRAINT fk_facultades_profesores 
		FOREIGN KEY (id_decano)
        REFERENCES profesores(id_profesor)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

ALTER TABLE profesores
	ADD CONSTRAINT fk_profesores_facultades
    FOREIGN KEY (id_facultad)
    REFERENCES facultades(id_facultad)
    ON UPDATE CASCADE ON DELETE RESTRICT;
    
CREATE TABLE grados(
	id_grado SMALLINT UNSIGNED AUTO_INCREMENT, 
    nombre VARCHAR (50), 
    id_facultad SMALLINT UNSIGNED,
    CONSTRAINT pk_grados PRIMARY KEY (id_grado),
    CONSTRAINT uq_nombre UNIQUE (nombre),
    CONSTRAINT chk_nombre CHECK (nombre IS NOT NULL),
    CONSTRAINT chk_id_facultad CHECK (id_facultad IS NOT NULL),
    CONSTRAINT fk_grados_facultades 
		FOREIGN KEY (id_facultad)
        REFERENCES facultades(id_facultad)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE asignaturas(
	id_asignatura SMALLINT UNSIGNED AUTO_INCREMENT,
    codigo_asig VARCHAR(10), -- max 10
    nombre VARCHAR (50),
    creditos SMALLINT DEFAULT 6,
    CONSTRAINT pk_asignaturas PRIMARY KEY(id_asignatura),
    CONSTRAINT uq_codigo_asig UNIQUE (codigo_asig),
    CONSTRAINT chk_codigo_asig CHECK (codig_asig IS NOT NULL), -- PREGUNTAR
    CONSTRAINT chk_nombre CHECK (nombre IS NOT NULL),
    CONSTRAINT chk_creditos CHECK (creditos >= 3)
);
	
CREATE TABLE imparten(
	id_profesor SMALLINT UNSIGNED, -- PK, FK PROFESORES ON DELETE CASCADE
    id_asignatra SMALLINT UNSIGNED, -- PK, FK PROFESORES ON DELETE CASCADE
    tipo_grupo VARCHAR(50) DEFAULT 'TEORIA'-- ENUM: 'TEORIA','PRACTICA'
);