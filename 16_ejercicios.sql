/* 
1) Tablas necesarias. 
2) Columnas que relacionan. Si no se relacionan directamente, buscar tablas intermedias.
3) Filtros (where)
4) ¿Agrupaciones? Si las hay, agregaciones.
5) Filtro post-agregado (HAVING)
6) ¿Ordenación?
*/

-- 1) Listar cada id del pedido con el nombre del cliente que lo realizó.
--    Orden: cliente ASC, y a igualdad de cliente por pedido ASC.
/* 
1) Tablas necesarias. 
pedidos y clientes
2) Columnas que relacionan. Si no se relacionan directamente, buscar tablas intermedias.
id_cliente
3) Filtros (where)
4) ¿Agrupaciones? Si las hay, agregaciones.
5) Filtro post-agregado (HAVING)
6) ¿Ordenación?
*/

SELECT 
    pedidos.id_pedido, clientes.nombre
FROM
    clientes
        JOIN
    pedidos ON pedidos.id_cliente = clientes.id_cliente
ORDER BY clientes.nombre ASC , id_pedido ASC;



-- 2) Listar cada línea de detalle con el nombre del producto y el id del pedido.
--    Columnas EXACTAS y alias:
--      - producto (pr.nombre)
--      - pedido   (dp.id_pedido)
--    Orden: producto ASC, y a igualdad de producto por pedido ASC.
/* 
1) Tablas necesarias. 
productos y detalle_pedido
2) Columnas que relacionan. Si no se relacionan directamente, buscar tablas intermedias.
id_producto
3) Filtros (where)
4) ¿Agrupaciones? Si las hay, agregaciones.
5) Filtro post-agregado (HAVING)
6) ¿Ordenación?
*/

SELECT 
    productos.nombre AS producto,
    detalle_pedido.id_pedido AS pedido
FROM
    productos
        JOIN
    detalle_pedido ON productos.id_producto = detalle_pedido.id_producto
ORDER BY productos.nombre ASC , detalle_pedido.id_pedido ASC;


-- 3) Listar cada pedido con el nombre del cliente y su coste total.
--    Columnas EXACTAS y alias:
--      - cliente      (c.nombre)
--      - pedido       (p.id_pedido)
--      - coste_total  (p.coste_total)
--    Orden: coste_total DESC y, en empates, pedido ASC.
/* 
1) Tablas necesarias. 
pedidos y clientes
2) Columnas que relacionan. Si no se relacionan directamente, buscar tablas intermedias.
id_cliente
3) Filtros (where)
4) ¿Agrupaciones? Si las hay, agregaciones.
5) Filtro post-agregado (HAVING)
6) ¿Ordenación?
*/

SELECT 
    clientes.nombre AS cliente,
    pedidos.id_pedido AS pedido,
    pedidos.coste_total AS coste_total
FROM
    pedidos
        JOIN
    clientes ON clientes.id_cliente = pedidos.id_cliente
ORDER BY pedidos.coste_total DESC , pedido ASC;

-- 4) Listar pedidos realizados a partir del 1 de enero de 2024 (incluido), con nombre del cliente y fecha.
--    Columnas y alias:
--      - pedido        (p.id_pedido)
--      - cliente       (c.nombre)
--      - fecha_pedido  (p.fecha_pedido)
--    Orden: fecha_pedido ASC; en empate, pedido ASC.
-- WHERE p.fecha_pedido >= '2024-01-01 00:00:00'

/* 
1) Tablas necesarias. 
pedidos y clientes
2) Columnas que relacionan. Si no se relacionan directamente, buscar tablas intermedias.
id_cliente
3) Filtros (where)
date(fecha_pedido) between 
4) ¿Agrupaciones? Si las hay, agregaciones.
5) Filtro post-agregado (HAVING)
6) ¿Ordenación?
*/

SELECT 
    pedidos.id_pedido AS pedido,
    clientes.nombre AS cliente,
    pedidos.fecha_pedido AS fecha_pedido
FROM
    pedidos
        JOIN
    clientes ON pedidos.id_cliente = clientes.id_cliente
WHERE
    pedidos.fecha_pedido >= '2024-01-01 00:00:00'
ORDER BY fecha_pedido ASC;


-- 5) Listar pedidos cuyo estado sea 'cancelado' o 'pendiente', con cliente y coste_total.
--    Columnas y alias:
--      - pedido       (p.id_pedido)
--      - cliente      (c.nombre)
--      - estado       (p.estado)
--      - coste_total  (p.coste_total)
--    Orden: estado ASC (cancelado < pendiente por orden alfabético), y dentro de cada estado coste_total DESC.
/* 
1) Tablas necesarias. 
pedidos y clientes
2) Columnas que relacionan. Si no se relacionan directamente, buscar tablas intermedias.
id_cliente
3) Filtros (where)
estado in 'cancelado', 'pendiente'
4) ¿Agrupaciones? Si las hay, agregaciones.
5) Filtro post-agregado (HAVING)
6) ¿Ordenación?
*/

SELECT 
    pedidos.id_pedido AS pedido,
    clientes.nombre AS cliente,
    pedidos.estado AS estado,
    pedidos.coste_total AS coste_total
FROM
    pedidos
        JOIN
    clientes ON clientes.id_cliente = pedidos.id_cliente
WHERE
    estado IN ('cancelado' , 'pendiente')
ORDER BY estado ASC , coste_total DESC;



-- 6) Listar pagos con su pedido y cliente, mostrando el método de pago.
--    Columnas y alias:
--      - pedido       (p.id_pedido)
--      - cliente      (c.nombre)
--      - metodo_pago  (pa.metodo_pago)
--    Importante: solo pedidos con al menos un pago (INNER JOIN).
--    Orden: pedido ASC.

/* 
1) Tablas necesarias. 
pagos, pedidos, clientes
2) Columnas que relacionan. Si no se relacionan directamente, buscar tablas intermedias.
id_cliente con pedidos, id_pedido con pagos
3) Filtros (where)
4) ¿Agrupaciones? Si las hay, agregaciones.
5) Filtro post-agregado (HAVING)
6) ¿Ordenación?
*/

SELECT 
    pedidos.id_pedido AS pedido,
    clientes.nombre AS cliente,
    pagos.metodo_pago AS metodo_pago
FROM
    clientes
        JOIN
    pedidos ON clientes.id_cliente = pedidos.id_cliente
        INNER JOIN
    pagos ON pedidos.id_pedido = pagos.id_pedido
ORDER BY pedido ASC;

-- 7) Listar las líneas del pedido con id 10, incluyendo nombre del producto, cantidad y precio unitario.
--    Columnas y alias:
--      - producto         (pr.nombre)
--      - cantidad         (dp.cantidad)
--      - precio_unitario  (dp.precio_unitario)
--    Orden: producto ASC.

/* 
1) Tablas necesarias. 
productos y detalle pedido
2) Columnas que relacionan. Si no se relacionan directamente, buscar tablas intermedias.
id_producto
3) Filtros (where)
id_producto = 10
4) ¿Agrupaciones? Si las hay, agregaciones.
5) Filtro post-agregado (HAVING)
6) ¿Ordenación?
*/

SELECT 
    productos.nombre AS producto,
    detalle_pedido.cantidad AS cantidad,
    detalle_pedido.precio_unitario AS precio_unitario
FROM
    productos
        JOIN
    detalle_pedido ON productos.id_producto = detalle_pedido.id_producto
WHERE
    id_pedido = 10;



-- 8) Listar pedidos con estado 'entregado' con nombre del cliente y fecha del pedido.
--    Columnas y alias:
--      - pedido        (p.id_pedido)
--      - cliente       (c.nombre)
--      - fecha_pedido  (p.fecha_pedido)
--    Orden: fecha_pedido ASC; en empate, pedido ASC.

/* 
1) Tablas necesarias. 
clientes y pedidos
2) Columnas que relacionan. Si no se relacionan directamente, buscar tablas intermedias.
id_cliente
3) Filtros (where)
where estado = 'entregado'
4) ¿Agrupaciones? Si las hay, agregaciones.
5) Filtro post-agregado (HAVING)
6) ¿Ordenación?
*/

SELECT 
    pedidos.id_pedido AS pedido,
    clientes.id_cliente AS cliente,
    pedidos.fecha_pedido AS fecha_pedido
FROM
    pedidos
        JOIN
    clientes ON clientes.id_cliente = pedidos.id_cliente
WHERE
    estado = 'entregado'
ORDER BY fecha_pedido ASC , pedido ASC;


-- 9) Calcular la suma total pagada por cada pedido que tenga al menos un pago.
--    Columnas y alias:
--      - pedido        (p.id_pedido)
--      - total_pagado  (SUM(pa.total_pagado))
--    Agrupación: por p.id_pedido exclusivamente.
--    Orden: total_pagado DESC; en empate, pedido ASC.

SELECT 
    pedidos.id_pedido AS pedido,
    SUM(pagos.total_pagado) AS total_pagado
FROM
    pedidos
        INNER JOIN
    pagos ON pedidos.id_pedido = pagos.id_pedido
GROUP BY pedidos.id_pedido
ORDER BY total_pagado DESC , pedido ASC;

-- 10) Contar el número de pedidos realizados por cada cliente.
--     Columnas y alias:
--       - cliente        (c.nombre)
--       - total_pedidos  (COUNT(p.id_pedido))
--     Agrupación: por c.id_cliente y c.nombre (ambos campos, para evitar ambigüedad).
--     Orden: total_pedidos DESC; en empate, cliente ASC.

SELECT 
    clientes.nombre AS cliente,
    COUNT(pedidos.id_pedido) AS total_pedidos
FROM
    clientes
        JOIN
    pedidos ON clientes.id_cliente = pedidos.id_cliente
GROUP BY clientes.id_cliente , clientes.nombre
ORDER BY total_pedidos DESC , cliente ASC;

-- 11) Listar los clientes que poseen MÁS DE 3 pedidos (estrictamente > 3).
--     Columnas y alias:
--       - cliente        (c.nombre)
--       - total_pedidos  (COUNT(p.id_pedido))
--     Agrupación: por c.id_cliente y c.nombre.
--     Orden: total_pedidos DESC; en empate, cliente ASC.

SELECT 
    clientes.nombre AS cliente,
    COUNT(pedidos.id_pedido) AS total_pedidos
FROM
    clientes
        JOIN
    pedidos ON clientes.id_cliente = pedidos.id_cliente
GROUP BY clientes.id_cliente , clientes.nombre
HAVING total_pedidos > 3
ORDER BY total_pedidos DESC , cliente ASC;

-- 12) Calcular los ingresos totales por cada producto (cantidad * precio_unitario) considerando SOLO líneas existentes.
--     Columnas y alias:
--       - producto  (pr.nombre)
--       - ingresos  (SUM(dp.cantidad * dp.precio_unitario))
--     Agrupación: por pr.id_producto y pr.nombre.
--     Orden: ingresos DESC; en empate, producto ASC.

select productos.nombre as producto, sum(detalle_pedido.cantidad * detalle_pedido.precio_unitario) as ingresos
from productos
inner join detalle_pedido on productos.id_producto = detalle_pedido.id_producto
group by productos.id_producto, productos.nombre
order by ingresos desc, producto asc;

-- 13) Listar los productos cuyo ingreso total (cantidad * precio_unitario) sea superior a 10.000,00 euros.
--     Columnas y alias:
--       - producto  (pr.nombre)
--       - ingresos  (SUM(dp.cantidad * dp.precio_unitario))
--     Agrupación: por pr.id_producto y pr.nombre.
--     Orden: ingresos DESC; en empate, producto ASC.

select productos.nombre as producto, sum(cantidad*precio_unitario) as ingresos
from productos 
join detalle_pedido on productos.id_producto = detalle_pedido.id_producto
group by productos.id_producto, productos.nombre
having ingresos > 10000
order by ingresos desc, producto asc;

-- 14) Listar los pedidos cuyo estado sea 'entregado' O 'enviado' y cuyo cliente tenga país 'España' O 'México'.
--     Columnas y alias:
--       - pedido   (p.id_pedido)
--       - cliente  (c.nombre)
--       - pais     (c.pais)
--       - estado   (p.estado)
--     Orden: pais ASC, luego estado ASC y finalmente pedido ASC.

SELECT 
    pedidos.id_pedido AS pedido,
    clientes.nombre AS clientes,
    clientes.pais AS pais,
    pedidos.estado AS estado
FROM
    clientes
        JOIN
    pedidos ON clientes.id_cliente = pedidos.id_cliente
WHERE
    estado IN ('entregado' , 'enviado')
        AND pais IN ('España' , 'México')
ORDER BY pais ASC , estado ASC , pedido ASC;

-- 15) Listar productos con precio_unitario > 200 en líneas pertenecientes a pedidos CANCELADOS.
--     Columnas y alias (sin duplicados en misma consulta):
--       - producto        (pr.nombre)
--       - precio_unitario (dp.precio_unitario)
--       - estado          (p.estado)
--     Selección DISTINCT para evitar filas repetidas por combinaciones idénticas.
--     Orden: precio_unitario DESC; en empate, producto ASC.

SELECT DISTINCT
    (productos.nombre) AS producto,
    detalle_pedido.precio_unitario AS precio_unitario,
    pedidos.estado AS estado
FROM
    productos
        JOIN
    detalle_pedido ON productos.id_producto = detalle_pedido.id_producto
        JOIN
    pedidos ON detalle_pedido.id_pedido = pedidos.id_pedido
WHERE
    detalle_pedido.precio_unitario > 200
        AND pedidos.estado = 'cancelado'
ORDER BY precio_unitario DESC , producto ASC;

-- 16) Listar clientes registrados en 2024 que tengan al menos un pedido en estado 'pendiente' O 'enviado' (no entregado ni cancelado).
--     Columnas y alias (sin duplicados por cliente-estado):
--       - cliente        (c.nombre)
--       - fecha_registro (c.fecha_registro)
--       - estado         (p.estado)
--     DISTINCT para evitar múltiples filas idénticas por mismo cliente y estado.
--     Orden: cliente ASC, y en empate por estado ASC.

SELECT 
	distinct(pedidos.estado) AS estado,
    clientes.nombre AS cliente,
    clientes.fecha_registro AS fecha_registro
FROM
    clientes
        INNER JOIN
    pedidos ON clientes.id_cliente = pedidos.id_cliente
WHERE
    YEAR(clientes.fecha_registro) = '2024'
        AND pedidos.estado IN ('pendiente, enviado')
ORDER BY cliente ASC , estado ASC;
