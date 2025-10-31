use ejemplos_tipos_join;

select * from alumnos
left join matriculas using (id_alumno);

 -- 3 Ejercicios: enunciados y resultados esperados
-- Nota: En este apartado no se incluyen las soluciones SQL. Están al final, en el Anexo.
-- Ejercicio 1
-- Enunciado: Listado de alumnos con sus id_curso (sólo emparejados).
-- Resultado esperado (4 filas):

SELECT 
    a.id_alumno AS id_alumno,
    a.nombre AS nombre,
    m.id_curso AS id_curso
FROM
    alumnos a
        JOIN
    matriculas m USING (id_alumno);
 
-- Ejercicio 2
-- Enunciado: Alumnos sin ninguna matrícula (anti-join)
 
 SELECT 
    a.id_alumno, a.nombre
FROM
    alumnos a
        LEFT JOIN
    matriculas m USING (id_alumno)
WHERE
    m.id_matricula IS NULL;
 
-- Ejercicio 3
-- Enunciado: Matrículas sin alumno (huérfanas)
 
SELECT 
    m.id_matricula, m.id_alumno, m.id_curso
FROM
    alumnos a
        RIGHT JOIN
    matriculas m USING (id_alumno)
WHERE
    a.id_alumno IS NULL;
    
-- Ejercicio 4
-- Enunciado: Cursos del catálogo sin ninguna matrícula.

SELECT 
    c.id_curso, c.nombre_curso
FROM
    cursos c
        LEFT JOIN
    matriculas USING (id_curso)
WHERE
    matriculas.id_matricula IS NULL;
    
-- Ejercicio 5
-- Enunciado: Número de matrículas por alumno (incluye 0)
 
 SELECT 
    a.id_alumno, a.nombre, COUNT(m.id_matricula) AS n_matriculas
FROM
    alumnos a
        LEFT JOIN
    matriculas m USING (id_alumno)
GROUP BY a.id_alumno , a.nombre;

-- Ejercicio 6
-- Enunciado: Alumnos con más de un curso.

 SELECT 
    a.id_alumno, a.nombre, COUNT(m.id_matricula) AS n_matriculas
FROM
    alumnos a
        LEFT JOIN
    matriculas m USING (id_alumno)
GROUP BY a.id_alumno , a.nombre
HAVING COUNT(m.id_matricula) > 1;

-- Ejercicio 7
-- Enunciado: FULL OUTER JOIN emulado (alumnos y sus matrículas, incluyendo huérfanas).
 
 SELECT 
    a.id_alumno, a.nombre, m.id_matricula, m.id_curso
FROM
    alumnos a
        LEFT JOIN
    matriculas m USING (id_alumno) 
UNION SELECT 
    a.id_alumno, a.nombre, m.id_matricula, m.id_curso
FROM
    alumnos a
        RIGHT JOIN
    matriculas m USING (id_alumno);

-- Ejercicio 8
-- Enunciado: Para cada curso del catálogo, número de alumnos con matrícula válida (alumno y
-- curso existen).

SELECT 
    c.id_curso, c.nombre_curso, COUNT(a.id_alumno)
FROM
    cursos c
        LEFT JOIN
    matriculas m USING (id_curso)
        LEFT JOIN
    alumnos a USING (id_alumno)
GROUP BY c.id_curso , c.nombre_curso;

