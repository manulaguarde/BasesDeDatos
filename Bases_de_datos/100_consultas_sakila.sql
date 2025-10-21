-- 1) Para cada idioma, obtener el replacement_cost máximo y mínimo de sus películas (idioma con >=10 películas).
-- Salida obligatoria (alias en orden): language_id, language_name, max_replacement_cost, min_replacement_cost

use sakila;

select * from film
where language_id =;

select * from language;

select 
	language.name as lengua,
    film.original_language_id,
    film.language_id
from language
join film on film.language_id = language.language_id
group by language.name, film.original_language_id, film.language_id;
    
