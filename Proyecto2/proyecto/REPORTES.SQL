DROP PROCEDURE IF EXISTS consultarSaldoCliente;
DROP PROCEDURE IF EXISTS consultarCliente;
DROP PROCEDURE IF EXISTS consultarMovsCliente;
DROP PROCEDURE IF EXISTS consultarTipoCuentas;
DROP PROCEDURE IF EXISTS consultarMovsGenFech;
DROP PROCEDURE IF EXISTS consultarMovsFechClien;
DROP PROCEDURE IF EXISTS consultarProductoServicio;

--1 
CREATE PROCEDURE consultarSaldoCliente
    @Numero_de_cuenta BIGINT
AS
BEGIN
    -- Verificar si el número de cuenta existe
    IF NOT EXISTS (SELECT 1 FROM Cuenta WHERE Id_cuenta = @Numero_de_cuenta)
    BEGIN
        RAISERROR('El tipo de cuenta no existe.', 16, 1);
    END

    SELECT 
        c.Nombre AS Nombre_Cliente,
        tc.Nombre AS Tipo_Cliente,
        tc2.Nombre AS Tipo_Cuenta,
        ct.Saldo_cuenta,
        ct.Monto_apertura
    FROM 
        Cuenta ct
    JOIN
        Cliente c ON ct.IdCliente = c.Id_cliente
    JOIN
        TipoCliente tc ON c.TipoCliente = tc.Id
    JOIN
        tipoCuenta tc2 ON ct.Tipo_Cuenta = tc2.Codigo
    WHERE
        ct.Id_cuenta = @Numero_de_cuenta;
END;

--2
CREATE PROCEDURE consultarCliente
    @Id_cliente INT
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
    BEGIN
        RAISERROR('El tipo de cuenta no existe.', 16, 1);
    END

    -- Obtener la información del cliente
    SELECT 
        c.Id_cliente,
        (c.Nombre + ' ' + c.Apellidos) AS Nombre_Completo,
        c.Usuario,
        c.Teléfonos,
        c.Correo,
        COUNT(ct.Id_cuenta) AS Numero_de_Cuentas,
        STRING_AGG(tc2.Nombre, ', ') AS Tipos_de_Cuenta
    FROM 
        Cliente c
    LEFT JOIN
        Cuenta ct ON ct.IdCliente = c.Id_cliente
    LEFT JOIN
        tipoCuenta tc2 ON ct.Tipo_Cuenta = tc2.Codigo
    WHERE
        c.Id_cliente = @Id_cliente
    GROUP BY 
        c.Id_cliente, c.Nombre, c.Apellidos, c.Usuario, c.Teléfonos, c.Correo;
END;

--3
CREATE PROCEDURE consultarMovsCliente
    @idCliente INT
AS
BEGIN

    IF NOT EXISTS (
        SELECT 1 
        FROM Cliente 
        WHERE Id_cliente = @idCliente
    )
    BEGIN
        RAISERROR('El cliente con el ID especificado no existe.', 16, 1);
        RETURN;
    END
    
    -- Consulta para obtener las transacciones del cliente
    SELECT 
        t.Id_transaccion AS 'Id transacción',
        tt.Nombre AS 'Tipo transacción',
        CASE 
            WHEN t.Id_compra IS NOT NULL THEN c.Importe_compra
            WHEN t.Id_deposito IS NOT NULL THEN d.Monto
            WHEN t.Id_debito IS NOT NULL THEN db.Monto
        END AS 'Monto',
        CASE 
            WHEN t.Id_compra IS NOT NULL THEN 'Compra'
            WHEN t.Id_deposito IS NOT NULL THEN 'Depósito'
            WHEN t.Id_debito IS NOT NULL THEN 'Débito'
        END AS 'Tipo de servicio',
        t.No_cuenta AS 'No. cuenta',
        tc.Nombre AS 'Tipo cuenta'
    FROM 
        Transaccion t
        JOIN TipoTransaccion tt ON t.Id_tipo_transaccion = tt.Codigo
        JOIN Cuenta cta ON t.No_cuenta = cta.Id_cuenta
        JOIN tipoCuenta tc ON cta.Tipo_Cuenta = tc.Codigo
        LEFT JOIN Compra c ON t.Id_compra = c.Id_compra
        LEFT JOIN Deposito d ON t.Id_deposito = d.Id_deposito
        LEFT JOIN Debito db ON t.Id_debito = db.Id_debito
    WHERE 
        cta.IdCliente = @idCliente
    ORDER BY 
        t.Fecha;  -- Ordenar por fecha 
END

--4
CREATE PROCEDURE consultarTipoCuentas
    @Id_tipo_cuenta INT
AS
BEGIN

    IF NOT EXISTS (SELECT 1 FROM tipoCuenta WHERE Codigo = @Id_tipo_cuenta)
    BEGIN
        RAISERROR('El tipo de cuenta no existe.', 16, 1);
    END

    -- Obtener el código del tipo de cuenta, el nombre del tipo de cuenta y la cantidad de clientes
    SELECT 
        tc.Codigo AS Codigo_de_Tipo_de_Cuenta,
        tc.Nombre AS Nombre_de_Tipo_de_Cuenta,
        COUNT(c.Id_cliente) AS Cantidad_de_Clientes
    FROM 
        Cuenta ct
    JOIN 
        tipoCuenta tc ON ct.Tipo_Cuenta = tc.Codigo
    JOIN 
        Cliente c ON ct.IdCliente = c.Id_cliente
    WHERE 
        tc.Codigo = @Id_tipo_cuenta
    GROUP BY 
        tc.Codigo, tc.Nombre;
END;

--5 
CREATE PROCEDURE consultarMovsGenFech
    @FechaInicio VARCHAR(10),
    @FechaFin VARCHAR(10)
AS
BEGIN
    DECLARE @DateFormat INT
    SET @DateFormat = 105 

    DECLARE @FechaInicioDate DATE
    DECLARE @FechaFinDate DATE

    -- Validar formato de fecha
    BEGIN TRY
        SET @FechaInicioDate = CONVERT(DATE, @FechaInicio, @DateFormat)
        SET @FechaFinDate = CONVERT(DATE, @FechaFin, @DateFormat)
    END TRY
    BEGIN CATCH
        RAISERROR('Formato de fecha no válido. Debe ser DD-MM-YY.', 16, 1);
        RETURN;
    END CATCH

    IF @FechaInicioDate > @FechaFinDate
    BEGIN
        RAISERROR('La fecha de inicio no puede ser mayor que la fecha final.', 16, 1);
        RETURN;
    END
    
    -- Consulta para obtener las transacciones dentro del rango de fechas
    SELECT 
        t.Id_transaccion AS 'Id transacción',  -- Revisa que el nombre de la columna coincida con el de la tabla
        tt.Nombre AS 'Tipo transacción',  -- Revisa el nombre de la columna
        CASE 
            WHEN t.Id_compra IS NOT NULL THEN 'Compra'
            WHEN t.Id_deposito IS NOT NULL THEN 'Depósito'
            WHEN t.Id_debito IS NOT NULL THEN 'Débito'
        END AS 'Tipo de servicio',
        cl.Nombre + ' ' + cl.Apellidos AS 'Nombre Cliente',
        t.No_cuenta AS 'No cuenta',
        tc.Nombre AS 'Tipo de cuenta',
        t.Fecha,
        CASE 
            WHEN t.Id_compra IS NOT NULL THEN c.Importe_compra
            WHEN t.Id_deposito IS NOT NULL THEN d.Monto
            WHEN t.Id_debito IS NOT NULL THEN db.Monto
        END AS 'Monto',
        t.Otros_Detalles AS 'Otros detalles'
    FROM 
        Transaccion t
        JOIN TipoTransaccion tt ON t.Id_tipo_transaccion = tt.Codigo  -- Verifica que el nombre de la columna es correcto
        JOIN Cuenta cta ON t.No_cuenta = cta.Id_cuenta
        JOIN tipoCuenta tc ON cta.Tipo_Cuenta = tc.Codigo
        JOIN Cliente cl ON cta.IdCliente = cl.Id_cliente
        LEFT JOIN Compra c ON t.Id_compra = c.Id_compra
        LEFT JOIN Deposito d ON t.Id_deposito = d.Id_deposito
        LEFT JOIN Debito db ON t.Id_debito IS NOT NULL
    WHERE 
        t.Fecha BETWEEN @FechaInicioDate AND @FechaFinDate
    ORDER BY 
        t.Fecha;  -- Ordenar por fecha 

--6
CREATE PROCEDURE consultarMovsFechClien
    @idCliente INT,
    @FechaInicio VARCHAR(10),  
    @FechaFin VARCHAR(10)  
AS
BEGIN
    -- Comprobar si el cliente existe
    IF NOT EXISTS (
        SELECT 1 
        FROM Cliente 
        WHERE Id_cliente = @idCliente
    )
    BEGIN
        RAISERROR('El cliente con el ID especificado no existe.', 16, 1);
        RETURN;
    END
    
    -- Validar fechas
    IF @FechaInicio IS NULL OR @FechaFin IS NULL
    BEGIN
        RAISERROR('Ambas fechas deben ser válidas.', 16, 1);
        RETURN;
    END

    -- Declarar y validar las fechas
    DECLARE @DateFormat INT
    SET @DateFormat = 105  -- Código de estilo para DD-MM-YY

    DECLARE @FechaInicioDate DATE
    DECLARE @FechaFinDate DATE

    -- Intentar convertir las fechas
    BEGIN TRY
        SET @FechaInicioDate = CONVERT(DATE, @FechaInicio, @DateFormat)  -- Usar estilo 105 para DD-MM-YY
        SET @FechaFinDate = CONVERT(DATE, @FechaFin, @DateFormat)  
    END TRY
    BEGIN CATCH
        
        RAISERROR('Formato de fecha no válido. Use DD-MM-YY.', 16, 1);
        RETURN;
    END CATCH

    IF @FechaInicioDate > @FechaFinDate
    BEGIN
        RAISERROR('La fecha de inicio no puede ser mayor que la fecha final.', 16, 1);
        RETURN;
    END
    
    -- Consulta para obtener transacciones por rango de fechas para un cliente específico
    SELECT 
        t.Id_transaccion AS 'Id transacción',
        tt.Nombre AS 'Tipo transacción',
        CASE 
            WHEN t.Id_compra IS NOT NULL THEN 'Compra'
            WHEN t.Id_deposito IS NOT NULL THEN 'Depósito'
            WHEN t.Id_debito IS NOT NULL THEN 'Débito'
        END AS 'Tipo de servicio',
        cl.Nombre + ' ' + cl.Apellidos AS 'Nombre Cliente',
        t.No_cuenta AS 'No cuenta',
        tc.Nombre AS 'Tipo de cuenta',
        t.Fecha,
        CASE 
            WHEN t.Id_compra IS NOT NULL THEN c.Importe_compra
            WHEN t.Id_deposito IS NOT NULL THEN d.Monto
            WHEN t.Id_debito IS NOT NULL THEN db.Monto
        END AS 'Monto',
        t.Otros_Detalles AS 'Otros detalles'
    FROM 
        Transaccion t
        JOIN TipoTransaccion tt ON t.Id_tipo_transaccion = tt.Codigo
        JOIN Cuenta cta ON t.No_cuenta = cta.Id_cuenta
        JOIN tipoCuenta tc ON cta.Tipo_Cuenta = tc.Codigo
        JOIN Cliente cl ON cta.IdCliente = cl.Id_cliente
        LEFT JOIN Compra c ON t.Id_compra = c.Id_compra
        LEFT JOIN Deposito d ON t.Id_deposito IS NOT NULL
        LEFT JOIN Debito db ON t.Id_debito IS NOT NULL
    WHERE 
        cl.Id_cliente = @idCliente
        AND t.Fecha BETWEEN @FechaInicioDate AND @FechaFinDate
    ORDER BY 
        t.Fecha;  
END

--7
CREATE PROCEDURE consultarProductoServicio
AS
BEGIN
    -- Obtener el listado de todos los productos y servicios
    SELECT 
        Codigo AS Codigo_Producto_Servicio,
        Descripción AS Descripcion,
        CASE
            WHEN Tipo = 1 THEN 'Servicio'
            WHEN Tipo = 2 THEN 'Producto'
            ELSE 'Desconocido'
        END AS Tipo
    FROM 
        ProductoServicio
    ORDER BY 
        Tipo, Codigo;
END;


