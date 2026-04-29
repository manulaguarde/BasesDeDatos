drop database if exists grupo_alumno;
create database grupo_alumno;
use grupo_alumno;

create table alumnos(
	id smallint primary key auto_increment,
    nombre varchar(25) not null,
    edad smallint not null,
    calificacion decimal (10,2),
    constraint chk_calificacion check (calificacion >=0 and calificacion <=10),
    constraint chk_edad check (edad >=17 and edad <=100)
);



select * from alumnos;