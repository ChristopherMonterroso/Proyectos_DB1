DROP PROCEDURE IF EXISTS saldoCliente;

CREATE PROCEDURE saldoCliente
    @Numero_de_cuenta BIGINT
AS
BEGIN
    -- Verificar si el número de cuenta existe
    IF NOT EXISTS (SELECT 1 FROM Cuenta WHERE Id_cuenta = @Numero_de_cuenta)
    BEGIN
        THROW 51000, 'El número de cuenta no existe.', 1;
    END

    -- Extraer información relevante
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

EXEC consultarSaldoCliente 3030206080;

CREATE PROCEDURE consultarCliente
    @Id_cliente INT
AS
BEGIN
    -- Verificar si el cliente existe
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
    BEGIN
        THROW 51000, 'El cliente no existe.', 1;
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

EXEC consultarCliente 1001;

CREATE PROCEDURE consultarMovsCliente
    @Id_cliente INT
AS
BEGIN
    -- Verificar si el cliente existe
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
    BEGIN
        THROW 51000, 'El cliente no existe.', 1;
    END

    -- Obtener información de transacciones del cliente
    SELECT 
        t.Id_transaccion,
        tt.Nombre AS Tipo_Transaccion,
        CASE 
            WHEN c.Id_compra IS NOT NULL THEN 'Compra'
            WHEN d.Id_deposito IS NOT NULL THEN 'Depósito'
            WHEN db.Id_debito IS NOT NULL THEN 'Débito'
            ELSE 'Desconocido'
        END AS Tipo_Servicio,
        t.Otros_Detalles,
        ct.Id_cuenta AS Numero_de_Cuenta,
        tc2.Nombre AS Tipo_Cuenta
    FROM 
        Transaccion t
    JOIN 
        TipoTransaccion tt ON t.Id_tipo_transaccion = tt.Codigo
    LEFT JOIN 
        Compra c ON t.Id_CompraDebitoDeposito = c.Id_compra
    LEFT JOIN 
        Deposito d ON t.Id_CompraDebitoDeposito = d.Id_deposito
    LEFT JOIN 
        Debito db ON t.Id_CompraDebitoDeposito = db.Id_debito
    JOIN 
        Cuenta ct ON t.No_cuenta = ct.Id_cuenta
    JOIN 
        tipoCuenta tc2 ON ct.Tipo_Cuenta = tc2.Codigo
    WHERE 
        ct.IdCliente = @Id_cliente
    ORDER BY 
        t.Fecha DESC;
END;


--4

CREATE PROCEDURE consultarTipoCuentas
    @Id_tipo_cuenta INT
AS
BEGIN
    -- Verificar si el tipo de cuenta existe
    IF NOT EXISTS (SELECT 1 FROM tipoCuenta WHERE Codigo = @Id_tipo_cuenta)
    BEGIN
        THROW 51000, 'El tipo de cuenta no existe.', 1;
    END

    -- Obtener el código del tipo de cuenta, el nombre del tipo de cuenta y la cantidad de clientes
    SELECT 
        tc.Codigo AS Codigo_de_Tipo_de_Cuenta,
        tc.Nombre AS Nombre_de_Tipo_de_Cuenta,
        COUNT(DISTINCT c.Id_cliente) AS Cantidad_de_Clientes
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

EXEC consultarTipoCuentas 1;


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
EXEC consultarProductoServicio

--Falta 3, 5 y 6
