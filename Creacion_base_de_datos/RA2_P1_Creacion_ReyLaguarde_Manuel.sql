DROP DATABASE IF EXISTS gestion_universidad;
CREATE DATABASE gestion_universidad;
USE gestion_universidad;

CREATE TABLE profesores(
	id_profesor SMALLINT UNSIGNED AUTO_INCREMENT,
    nif CHAR(9), 
    nombre_completo VARCHAR (50), 
    salario DECIMAL (14,2) DEFAULT 2000.00, 
    id_facultad SMALLINT UNSIGNED NOT NULL,
	CONSTRAINT pk_profesores PRIMARY KEY (id_profesor),
    CONSTRAINT chk_nif CHECK (nif IS NOT NULL AND LENGTH(nif) = 9),
    CONSTRAINT uq_nif UNIQUE (nif),
    CONSTRAINT uq_nombre_completo UNIQUE (nombre_completo),
    CONSTRAINT chk_nombre_completo CHECK (nombre_completo IS NOT NULL),
    CONSTRAINT chk_salario CHECK (salario > 0)
    
);

CREATE TABLE facultades(
	id_facultad SMALLINT UNSIGNED AUTO_INCREMENT,
    codigo CHAR(4),
    nombre VARCHAR(100),
    id_decano SMALLINT UNSIGNED, 
    CONSTRAINT pk_facultades PRIMARY KEY (id_facultad),
    CONSTRAINT uq_codigo UNIQUE (codigo),
    CONSTRAINT chk_codigo CHECK (codigo IS NOT NULL AND LENGTH(codigo) =4 ),
	CONSTRAINT uq_nombre UNIQUE (nombre),
    CONSTRAINT chk_nombre CHECK (nombre IS NOT NULL), 
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
    id_facultad SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_grados PRIMARY KEY (id_grado),
    CONSTRAINT uq_nombre UNIQUE (nombre),
    CONSTRAINT chk_nombre_grado CHECK (nombre IS NOT NULL),
    CONSTRAINT fk_grados_facultades 
		FOREIGN KEY (id_facultad)
        REFERENCES facultades(id_facultad)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE asignaturas(
	id_asignatura SMALLINT UNSIGNED AUTO_INCREMENT,
    codigo_asig VARCHAR(10),
    nombre VARCHAR (50),
    creditos SMALLINT DEFAULT 6,
    CONSTRAINT pk_asignaturas PRIMARY KEY(id_asignatura),
    CONSTRAINT uq_codigo_asig UNIQUE (codigo_asig),
    CONSTRAINT chk_codigo_asig CHECK (codigo_asig IS NOT NULL), 
    CONSTRAINT chk_nombre_asig CHECK (nombre IS NOT NULL),
    CONSTRAINT chk_creditos CHECK (creditos >= 3)
);
	
CREATE TABLE imparten(
	id_profesor SMALLINT UNSIGNED, 
    id_asignatura SMALLINT UNSIGNED,
    tipo_grupo ENUM ('TEORIA','PRACTICA') DEFAULT 'TEORIA',
    CONSTRAINT pk_imparten PRIMARY KEY(id_profesor,id_asignatura),
    CONSTRAINT fk_imparten_profesores
		FOREIGN KEY (id_profesor)
        REFERENCES profesores(id_profesor)
        ON UPDATE CASCADE ON DELETE CASCADE,
		CONSTRAINT fk_imparten_asignaturas
		FOREIGN KEY (id_asignatura)
        REFERENCES asignaturas(id_asignatura)
        ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE VIEW v_cuadro_docente AS
    SELECT 
        p.nombre_completo AS profesor,
        p.nif AS nif_profesor,
        a.nombre AS asignatura,
        i.tipo_grupo AS modalidad,
        f.nombre AS facultad_origen
    FROM
        facultades f
            JOIN
        profesores p USING (id_facultad)
            JOIN
        imparten i USING (id_profesor)
            JOIN
        asignaturas a USING (id_asignatura);
    
CREATE VIEW v_resumen_facultades AS
    SELECT 
        f.nombre AS facultad,
        f.codigo AS codigo_facultad,
        COUNT(p.id_profesor) AS num_profesores,
        SUM(p.salario) AS masa_salarial,
        ROUND(AVG(p.salario),2) AS salario_medio
    FROM
        facultades f
            LEFT JOIN
        profesores p USING (id_facultad)
    GROUP BY f.id_facultad, f.nombre, f.codigo;