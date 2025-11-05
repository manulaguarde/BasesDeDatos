-- 18) Productos NUNCA vendidos.

SELECT DISTINCT
    pr.id_producto, pr.nombre AS nombre_producto
FROM
    productos pr
        LEFT JOIN
    detalle_pedido dp USING (id_producto)
WHERE
    dp.id_detalle IS NULL;
    
-- 20) Pedidos sin pagos, con cliente y coste_total
SELECT 
    p.id_pedido,
    c.nombre AS nombre_cliente,
    SUM(p.coste_total) AS coste_total
FROM
    clientes c
        RIGHT JOIN
    pedidos p USING (id_cliente)
        LEFT JOIN
    pagos USING (id_pedido)
WHERE
    pagos.id_pago IS NULL
GROUP BY p.id_pedido , c.nombre
ORDER BY coste_total DESC;

-- 28) Pedidos con pagos parciales (suma pagos < coste_total y ≥ 1 pago).
SELECT 
    p.id_pedido,
    c.nombre AS cliente,
    pa.total_pagado,
    p.coste_total
FROM
    clientes c
        JOIN
    pedidos p USING (id_cliente)
        JOIN
    pagos pa USING (id_pedido)
WHERE
    p.estado = 'pendiente'
        OR p.estado = 'cancelado'
ORDER BY pa.total_pagado ASC;


-- 29) Nº de productos distintos comprados por cliente.
SELECT 
    c.nombre,
    COUNT(DISTINCT dp.id_producto) AS productos_distintos
FROM
    clientes c
        LEFT JOIN
    pedidos USING (id_cliente)
        LEFT JOIN
    detalle_pedido dp USING (id_pedido)
GROUP BY c.id_cliente , c.nombre
ORDER BY productos_distintos DESC;

-- 35) Clientes 2025 SIN pedidos aún.
SELECT 
    c.id_cliente, c.nombre, COUNT(DISTINCT p.id_pedido)
FROM
    clientes c
        LEFT JOIN
    pedidos p USING (id_cliente)
WHERE
    YEAR(fecha_pedido) = '2025'
        AND p.id_pedido IS NULL
GROUP BY c.id_cliente , c.nombre;


    
