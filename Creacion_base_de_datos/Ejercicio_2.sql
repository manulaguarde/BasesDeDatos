DROP DATABASE IF EXISTS ejercicio2;
CREATE DATABASE ejercicio2;
USE ejercicio2;

CREATE TABLE laboratorio (
	id_laboratorio SMALLINT UNSIGNED AUTO_INCREMENT,
    nombre_laboratorio VARCHAR(25) NOT NULL,
    id_investigador SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_laboratorio PRIMARY KEY (id_laboratorio)
    /*SI LO PONGO AQUI FALLA
    CONSTRAINT fk_laboratorio_investigador
		FOREIGN KEY (id_investigador)
		REFERENCES investigador(id_investigador)
        ON DELETE RESTRICT ON UPDATE CASCADE*/
);
CREATE TABLE investigador(
	id_investigador SMALLINT UNSIGNED AUTO_INCREMENT,
    nombre_investigador VARCHAR(25) NOT NULL,
    id_laboratorio SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_investigador PRIMARY KEY (id_investigador),
    CONSTRAINT fk_investigador_laboratorio 
		FOREIGN KEY (id_laboratorio)
        REFERENCES laboratorio(id_laboratorio)
        ON DELETE RESTRICT ON UPDATE CASCADE
);



ALTER TABLE laboratorio
	ADD CONSTRAINT fk_laboratorio_investigador 
    FOREIGN KEY (id_investigador)
        REFERENCES investigador(id_investigador)
        ON DELETE RESTRICT ON UPDATE CASCADE;

