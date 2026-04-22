-- TRIGGERS
-- es un procedimiento que se ejecuta siempre que te interese (de manera automática)
-- permite hacerlo antes o despues de un insert, update o delete
-- sirve para mantener la coherencia de los datos

-- como funcionan?
-- tienen dos parámetros de entrada new y old, siempre se ejecutan en una tabla (trigger on table)

-- Auditoría de Pagos: Trigger que guarde en una tabla audit_payments cualquier
-- cambio en el campo amount.

use sakila;
create table audit_payments(
	id int auto_increment primary key,
    old_amount decimal (5,2),
    new_amount decimal (5,2),
    payment_id_updated smallint unsigned,
    constraint fk_audit_payment_payment foreign key (payment_id_updated)
    references payment(payment_id)
    on update cascade on delete cascade
    );
    
drop trigger if exists auditoria_de_pagos;

DELIMITER //
create trigger auditoria_de_pagos after update on payment -- cuando 
for each row
begin
	if old.amount <> new.amount then
		insert into audit_payments (old_amount, new_amount, payment_id_updated)
        values (old.amount, new.amount, new.payment_id);
	end if;
end //
delimiter ;


-- Protección de Actores: Trigger que impida borrar actores que han participado en
-- más de 20 películas.

delimiter //
create trigger no_borrar_actores_relevantes before delete on actor
for each row
begin 
	declare v_contador int;
	select actor_id, count(film_id) into v_contador 
	if v
    end if;
end //
delimiter ;

 -- Auto-Mayúsculas: Trigger que asegure que el first_name de un cliente siempre se
-- guarde en mayúsculas tras un UPDATE.  

delimiter //
create trigger mayusculas_first_name before insert on actor
for each row
begin 
	set new.first_name = upper(new.first_name);
end //
delimiter ;
    
    
    
    
    
    
    
    
    
    
    