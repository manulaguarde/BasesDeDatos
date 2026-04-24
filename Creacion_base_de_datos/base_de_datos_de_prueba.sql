create database bd_clientes;

use bd_clientes;

create table clientes(
	id varchar(10) primary key,
    nombre varchar(20),
    edad int
);

insert into clientes values ("124a","Maria",35);

update clientes set nombre= "pedro",edad=26 where id="123a";

select * from clientes;