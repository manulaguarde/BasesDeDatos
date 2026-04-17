select * from rental;
explain rental;

DELIMITER //
CREATE procedure insertar_alquiler(in p_customer_id int, p_inventory_id int,p_staff_id int)
	begin
		insert into rental(customer_id,inventory_id,staff_id,rental_date)
        values (p_customer_id,p_inventory_id,p_staff_id,now());
end //
delimiter ;

call insertar_alquiler(1,1,1);
select * from rental r
where r.customer_id = 1;

select * from staff;
delimiter //
create procedure mover_empleados(in p_store_id int)
	begin
		update staff set store_id=

select * from film;
drop procedure if exists incrementar_rental_rate;

delimiter //
create procedure incrementar_rental_rate(in porcentaje decimal(3,2))
	begin
		update film set rental_rate= rental_rate*porcentaje;
end //
delimiter ;

drop procedure if exists cantidad_peliculas_y_duracion_media_por_actor;
delimiter //
create procedure cantidad_peliculas_y_duracion_media_por_actor(in v_actor_id int, out v_total_peliculas int,out v_duracion_media decimal(10,2))
	begin 
		select a.actor_id, count(f.film_id), avg(f.length) into v_actor_id,v_total_peliculas,v_duracion_media
        from actor a
        join film_actor using (actor_id)
        join film f using (film_id);
end //
delimiter ;

call cantidad_peliculas_y_duracion_media_por_actor(1,@ret_val_total_peliculas,@ret_val_duracion_media);
