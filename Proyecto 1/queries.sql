--Consulta 1
/* Mostrar el cliente que más ha comprado. Se debe de mostrar el id del cliente,
nombre, apellido, país y monto total.
*/
SELECT TOP 1
    c.id_cliente,
    c.nombre,
    c.apellido,
    p.nombre AS pais,
    COUNT(ov.id_orden) AS numero_compras,
    SUM(pr.precio * ov.cantidad) AS monto_total
FROM
    CLIENTE c
JOIN
    ORDEN_VENTA ov ON c.id_cliente = ov.id_cliente
JOIN
    PRODUCTO pr ON ov.id_producto = pr.id_producto
JOIN
    PAIS p ON c.id_pais = p.id_pais
GROUP BY
    c.id_cliente,
    c.nombre,
    c.apellido,
    p.nombre
ORDER BY
    monto_total DESC;

--Consulta 2
/* Mostrar el producto más y menos comprado. Se debe mostrar el id del producto,
nombre del producto, categoría, cantidad de unidades y monto vendido.
*/
-- Producto más comprado
SELECT TOP 1
    pr.id_producto,
    pr.nombre AS nombre_producto,
    ca.nombre AS categoria,
    SUM(ov.cantidad) AS cantidad_unidades,
    SUM(ov.cantidad * pr.precio) AS monto_vendido
FROM
    PRODUCTO pr
JOIN
    ORDEN_VENTA ov ON pr.id_producto = ov.id_producto
JOIN
    CATEGORIA ca ON pr.id_categoria = ca.id_categoria
GROUP BY
    pr.id_producto,
    pr.nombre,
    ca.nombre
ORDER BY
    cantidad_unidades DESC;

-- Producto menos comprado
SELECT TOP 1
    pr.id_producto,
    pr.nombre AS nombre_producto,
    ca.nombre AS categoria,
    SUM(ov.cantidad) AS cantidad_unidades,
    SUM(ov.cantidad * pr.precio) AS monto_vendido
FROM
    PRODUCTO pr
JOIN
    ORDEN_VENTA ov ON pr.id_producto = ov.id_producto
JOIN
    CATEGORIA ca ON pr.id_categoria = ca.id_categoria
GROUP BY
    pr.id_producto,
    pr.nombre,
    ca.nombre
ORDER BY
    cantidad_unidades ASC;

--Consulta 3
/*Mostrar a la persona que más ha vendido. Se debe mostrar el id del vendedor,
nombre del vendedor, monto total vendido.
*/
SELECT TOP 1
    v.id_vendedor,
    v.nombre AS nombre_vendedor,
    SUM(pr.precio * ov.cantidad) AS monto_total_vendido
FROM
    VENDEDOR v
JOIN
    ORDEN_VENTA ov ON v.id_vendedor = ov.id_vendedor
JOIN
    PRODUCTO pr ON ov.id_producto = pr.id_producto
GROUP BY
    v.id_vendedor,
    v.nombre
ORDER BY
    monto_total_vendido DESC;

--Consulta 4
/*Mostrar el país que más y menos ha vendido. Debe mostrar el nombre del país y el
monto. (Una sola consulta).
*/

WITH VentasPorPais AS (
    SELECT
        p.nombre AS nombre_pais,
        SUM(pr.precio * ov.cantidad) AS monto_total
    FROM
        ORDEN_VENTA ov
    JOIN
        VENDEDOR v ON ov.id_vendedor = v.id_vendedor
    JOIN
        PAIS p ON v.id_pais = p.id_pais
    JOIN
        PRODUCTO pr ON ov.id_producto = pr.id_producto
    GROUP BY
        p.nombre
)

SELECT
    (SELECT TOP 1 nombre_pais FROM VentasPorPais ORDER BY monto_total DESC) AS pais_mas_vendido,
    (SELECT TOP 1 nombre_pais FROM VentasPorPais ORDER BY monto_total ASC) AS pais_menos_vendido,
    (SELECT MAX(monto_total) FROM VentasPorPais) AS monto_maximo_vendido,
    (SELECT MIN(monto_total) FROM VentasPorPais) AS monto_minimo_vendido;

--Consulta 5
/*Top 5 de países que más han comprado en orden ascendente. Se le solicita mostrar
el id del país, nombre y monto total.
*/

WITH VentasPorPais AS (
    SELECT 
        pa.id_pais AS ID_Pais,
        pa.nombre AS Nombre,
        SUM(p.precio * o.cantidad) AS Monto
    FROM 
        PAIS pa
    JOIN 
        CLIENTE c ON pa.id_pais = c.id_pais
    JOIN 
        ORDEN_VENTA o ON c.id_cliente = o.id_cliente
    JOIN 
        PRODUCTO p ON o.id_producto = p.id_producto
    GROUP BY 
        pa.id_pais, pa.nombre
)
SELECT TOP 5
    ID_Pais,
    Nombre,
    Monto
FROM 
    VentasPorPais
ORDER BY 
    Monto ASC;


--Consulta 6
/*Mostrar la categoría que más y menos se ha comprado. Debe de mostrar el nombre
de la categoría y cantidad de unidades. (Una sola consulta).*/

WITH CantidadPorCategoria AS (
    SELECT
        cat.nombre AS nombre_categoria,
        SUM(ov.cantidad) AS cantidad_total,
        ROW_NUMBER() OVER (ORDER BY SUM(ov.cantidad) DESC) AS ranking_mas_comprada,
        ROW_NUMBER() OVER (ORDER BY SUM(ov.cantidad) ASC) AS ranking_menos_comprada
    FROM
        ORDEN_VENTA ov
    JOIN
        PRODUCTO pr ON ov.id_producto = pr.id_producto
    JOIN
        CATEGORIA cat ON pr.id_categoria = cat.id_categoria
    GROUP BY
        cat.nombre
)

SELECT
    nombre_categoria AS categoria_mas_comprada,
    cantidad_total AS cantidad_unidades_mas_comprada
FROM
    CantidadPorCategoria
WHERE
    ranking_mas_comprada = 1

UNION ALL

SELECT
    nombre_categoria AS categoria_menos_comprada,
    cantidad_total AS cantidad_unidades_menos_comprada
FROM
    CantidadPorCategoria
WHERE
    ranking_menos_comprada = 1;

--Consulta 7
/*Mostrar la categoría más comprada por cada país. Se debe de mostrar el nombre del
país, nombre de la categoría y cantidad de unidades*/

WITH VentasPorPaisCategoria AS (
    SELECT 
        pa.nombre AS Pais,
        c.nombre AS Categoria,
        SUM(o.cantidad) AS Unidades
    FROM 
        PAIS pa
    JOIN 
        CLIENTE cl ON pa.id_pais = cl.id_pais
    JOIN 
        ORDEN_VENTA o ON cl.id_cliente = o.id_cliente
    JOIN 
        PRODUCTO p ON o.id_producto = p.id_producto
    JOIN 
        CATEGORIA c ON p.id_categoria = c.id_categoria
    GROUP BY 
        pa.nombre, c.nombre
),
MaxVentasPorPais AS (
    SELECT 
        Pais,
        MAX(Unidades) AS MaxUnidades
    FROM 
        VentasPorPaisCategoria
    GROUP BY 
        Pais
)
SELECT 
    v.Pais,
    v.Categoria,
    v.Unidades
FROM 
    VentasPorPaisCategoria v
JOIN 
    MaxVentasPorPais m ON v.Pais = m.Pais AND v.Unidades = m.MaxUnidades;

--Consulta 8
/*Mostrar las ventas por mes de inglaterra. Debe mostrar el número de mes y monto. (Una sola consulta).*/
SELECT
    MONTH(fecha_orden) AS Numero_Mes,
    SUM(precio * cantidad) AS Monto
FROM
    ORDEN_VENTA OV
JOIN
    PRODUCTO P ON OV.id_producto = P.id_producto
JOIN
    VENDEDOR V ON OV.id_vendedor = V.id_vendedor
WHERE
    V.id_pais = (SELECT id_pais FROM PAIS WHERE nombre = 'Inglaterra')
GROUP BY
    MONTH(fecha_orden)
ORDER BY
    Numero_Mes;



--Consulta 9
/*Mostrar el mes con más y menos ventas. Se debe de mostrar el número de mes y
monto. (Una sola consulta).*/
-- Mes con más ventas
WITH VentasPorMes AS (
    SELECT 
        MONTH(fecha_orden) AS Numero_Mes,
        SUM(precio * cantidad) AS Monto_Total
    FROM ORDEN_VENTA
    JOIN PRODUCTO ON ORDEN_VENTA.id_producto = PRODUCTO.id_producto
    GROUP BY MONTH(fecha_orden)
)
SELECT 
    'Mes con más ventas' AS Tipo_Mes,
    Numero_Mes,
    Monto_Total
FROM VentasPorMes
WHERE Monto_Total = (SELECT MAX(Monto_Total) FROM VentasPorMes)

UNION ALL

SELECT 
    'Mes con menos ventas' AS Tipo_Mes,
    Numero_Mes,
    Monto_Total
FROM VentasPorMes
WHERE Monto_Total = (SELECT MIN(Monto_Total) FROM VentasPorMes);


--Consulta 10
/* Mostrar las ventas de cada producto de la categoría deportes. Se debe de mostrar el
id del producto, nombre y monto*/

SELECT 
    COUNT(*) AS Numero_de_Filas
FROM (
    SELECT 
        p.id_producto AS ID_Producto,
        p.nombre AS Nombre,
        SUM(p.precio * o.cantidad) AS Monto
    FROM 
        PRODUCTO p
    JOIN 
        ORDEN_VENTA o ON p.id_producto = o.id_producto
    JOIN 
        CATEGORIA c ON p.id_categoria = c.id_categoria
    WHERE 
        c.nombre = 'deportes'
    GROUP BY 
        p.id_producto, p.nombre
) AS Subconsulta;


--Eliminar información 
DELETE FROM ORDEN_VENTA;
DELETE FROM CLIENTE;
DELETE FROM VENDEDOR;
DELETE FROM PRODUCTO;
DELETE FROM CATEGORIA;
DELETE FROM PAIS;

--Eliminar tablas
DROP TABLE ORDEN_VENTA;
DROP TABLE CLIENTE;
DROP TABLE VENDEDOR;
DROP TABLE PRODUCTO;
DROP TABLE CATEGORIA;
DROP TABLE PAIS;
