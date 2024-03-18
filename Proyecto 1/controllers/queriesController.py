class  QueriesController:

    def __init__(self):
        self.queries = {
            "consulta1": self.query1,
            "consulta2": self.query2,
            "consulta3": self.query3,
            "consulta4": self.query4,
            "consulta5": self.query5,
            "consulta6": self.query6,
            "consulta7": self.query7,
            "consulta8": self.query8,
            "consulta9": self.query9,
            "consulta10": self.query10,
            "deleteTables": self.deleteTables,
            "deleteData": self.deleteData,
            "createTables": self.createTables,
        }
        
    def query1(self):
        return """
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
        """
    def query2(self):
        return """
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
        """
    def query3(self):
        return """
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
        """
    def query4(self):
        return """ 
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
        """
    
    def query5(self):
        return """
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
 """
    
    def query6(self):
        return """
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
    """

    def query7(self):
        return """
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
    """

    def query8(self):
        return """
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
    """

    def query9(self):
        return """
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

        """

    def query10(self):
        return """
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

    """
    def deleteTables(self):
        return """
        DROP TABLE ORDEN_VENTA;
        DROP TABLE CLIENTE;
        DROP TABLE VENDEDOR;
        DROP TABLE PRODUCTO;
        DROP TABLE CATEGORIA;
        DROP TABLE PAIS;
        """
    
    def deleteData(self):
        return """
        DELETE FROM ORDEN_VENTA;
        DELETE FROM CLIENTE;
        DELETE FROM VENDEDOR;
        DELETE FROM PRODUCTO;
        DELETE FROM CATEGORIA;
        DELETE FROM PAIS;
        """
    
    def createTables(self):
        return """
        CREATE TABLE CATEGORIA (
        id_categoria INTEGER PRIMARY KEY,
        nombre VARCHAR(50)
        );
        CREATE TABLE PAIS (
            id_pais INTEGER PRIMARY KEY,
            nombre VARCHAR(50)
        );
        CREATE TABLE PRODUCTO (
            id_producto INTEGER PRIMARY KEY,
            nombre VARCHAR(100),
            precio FLOAT(2),
            id_categoria INTEGER,
            FOREIGN KEY (id_categoria) REFERENCES CATEGORIA(id_categoria)
        );



        CREATE TABLE VENDEDOR (
            id_vendedor INTEGER PRIMARY KEY,
            nombre VARCHAR(50),
            id_pais INTEGER,
            FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais)
        );

        CREATE TABLE CLIENTE (
            id_cliente INTEGER PRIMARY KEY,
            nombre VARCHAR(50),
            apellido VARCHAR(50),
            direccion VARCHAR(200),
            telefono VARCHAR(20),
            tarjeta_credito VARCHAR(20),
            edad INTEGER,
            genero VARCHAR(1),
            salario FLOAT(2),
            id_pais INTEGER,
            FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais)
        );

        CREATE TABLE ORDEN_VENTA (
            id_orden INTEGER,
            linea_orden INTEGER,
            fecha_orden DATE,
            id_vendedor INTEGER,
            id_cliente INTEGER,
            id_producto INTEGER,
            cantidad INTEGER,
            FOREIGN KEY (id_vendedor) REFERENCES VENDEDOR(id_vendedor),
            FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente),
            FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto)
        );
        """

