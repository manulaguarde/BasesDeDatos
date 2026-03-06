use gestion_universidad;


INSERT INTO `gestion_universidad`.`facultades`
(`id_facultad`,
`codigo`,
`nombre`)
VALUES
(4,
2227,
'hasta luego');

select * from facultades;



INSERT INTO `gestion_universidad`.`profesores`
(`id_profesor`,
`nif`,
`nombre_completo`,
`id_facultad`,
`salario`)
VALUES
(16,
'568923144',
'viviana canosa',
4,
1400);


select * from profesores;





