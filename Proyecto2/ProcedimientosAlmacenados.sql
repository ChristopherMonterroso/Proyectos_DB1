DROP PROCEDURE IF EXISTS registrarTipoCliente;
DROP PROCEDURE IF EXISTS registrarCliente;
DROP PROCEDURE IF EXISTS registrarTipoCuenta;
DROP PROCEDURE IF EXISTS registrarCuenta;
DROP PROCEDURE IF EXISTS registrarProductoServicio;
DROP PROCEDURE IF EXISTS registrarTipoTransaccion;
DROP PROCEDURE IF EXISTS registrarCompra;
DROP PROCEDURE IF EXISTS registrarDeposito;
DROP PROCEDURE IF EXISTS registrarDebito;
DROP PROCEDURE IF EXISTS asignarTransaccion;

-- Procedimientos almacenados para la base de datos
-- Procedimientos para registrar un nuevo tipo de cliente 
CREATE PROCEDURE registrarTipoCliente
    @Nombre VARCHAR(20),
    @Descripción VARCHAR(40)
AS
BEGIN
    -- Validación de solo letras y espacios para la descripción
    IF @Descripción LIKE '%[^a-zA-Z ]%'
    BEGIN
        RAISERROR('La descripción solo puede contener letras y espacios.', 16, 1);
        RETURN;
    END
    
    -- Inserción de datos en la tabla (sin especificar ID)
    INSERT INTO TipoCliente (Nombre, Descripción)
    VALUES (@Nombre, @Descripción);

    -- Confirmación de inserción
    PRINT 'Tipo de cliente insertado correctamente';
END;



-- Procedimiento para registrar un nuevo cliente
CREATE PROCEDURE registrarCliente
    @Id_cliente INT,
    @Nombre VARCHAR(40),
    @Apellidos VARCHAR(40),
    @Teléfonos VARCHAR(12),
    @Correo VARCHAR(40),
    @Usuario VARCHAR(40),
    @Contraseña VARCHAR(200),
    @TipoCliente INT
AS
BEGIN
    -- Validación para que el ID no esté duplicado
    IF EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
    BEGIN
        RAISERROR('El ID del cliente ya existe.', 16, 1);
        RETURN;
    END
    
    -- Validación de solo letras y espacios para Nombre y Apellidos
    IF @Nombre LIKE '%[^a-zA-Z ]%'
    BEGIN
        RAISERROR('El nombre solo puede contener letras y espacios.', 16, 1);
        RETURN;
    END
    
    IF @Apellidos LIKE '%[^a-zA-Z ]%'
    BEGIN
        RAISERROR('Los apellidos solo pueden contener letras y espacios.', 16, 1);
        RETURN;
    END
    
    -- Validación para el formato del correo electrónico
    IF @Correo NOT LIKE '%_@__%.__%'
    BEGIN
        RAISERROR('El formato del correo no es válido.', 16, 1);
        RETURN;
    END
    
    -- Validación para asegurar que el Usuario no está duplicado
    IF EXISTS (SELECT 1 FROM Cliente WHERE Usuario = @Usuario)
    BEGIN
        RAISERROR('El usuario ya está en uso.', 16, 1);
        RETURN;
    END
    
    -- Validación para verificar que el TipoCliente exista
    IF NOT EXISTS (SELECT 1 FROM TipoCliente WHERE Id = @TipoCliente)
    BEGIN
        RAISERROR('El tipo de cliente especificado no existe.', 16, 1);
        RETURN;
    END
    
    -- Sal para aumentar la seguridad del hash
    DECLARE @Salt VARCHAR(16) = LEFT(NEWID(), 16);  -- Generar un salt de 16 caracteres aleatorios
    
    -- Crear el hash de la contraseña con el salt usando SHA-256
    DECLARE @ContraseñaHasheada VARBINARY(256);
    SET @ContraseñaHasheada = HASHBYTES('SHA2_256', @Salt + @Contraseña);

    -- Inserción del nuevo cliente
    INSERT INTO Cliente (Id_cliente, Nombre, Apellidos, Teléfonos, Correo, Usuario, Contraseña, TipoCliente, Salt)
    VALUES (@Id_cliente, @Nombre, @Apellidos, @Teléfonos, @Correo, @Usuario, @ContraseñaHasheada, @TipoCliente, @Salt);

    -- Confirmación de inserción
    PRINT 'Cliente registrado correctamente';
END;

-- Procedimiento para registrar un nuevo tipo de cuenta
CREATE PROCEDURE registrarTipoCuenta
    @Nombre VARCHAR(20),
    @Descripción VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación para evitar duplicaciones de código

    -- Validación para evitar duplicaciones del nombre
    IF EXISTS (SELECT 1 FROM tipoCuenta WHERE Nombre = @Nombre)
    BEGIN
        RAISERROR('El nombre del tipo de cuenta ya está en uso.', 16, 1);
        RETURN;
    END
    ELSE
    BEGIN
        -- Si el código no se especifica, se permite el autoincremento
        INSERT INTO tipoCuenta (Nombre, Descripción)
        VALUES (@Nombre, @Descripción);
    END

    -- Confirmación de inserción
    PRINT 'Tipo de cuenta registrado correctamente';
END;


--Procedimiento para registrar una nueva cuenta
CREATE PROCEDURE registrarCuenta
    @Id_cuenta BIGINT,  -- Código opcional para permitir autoincremento
    @Monto_apertura DECIMAL(12,2),
    @Saldo_cuenta DECIMAL(12,2),
    @Descripción VARCHAR(50),
    @Fecha_de_apertura DATETIME = NULL,  -- Permitir especificar o dejar nulo
    @Otros_detalles VARCHAR(100),
    @Tipo_Cuenta INT,
    @IdCliente INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación para asegurar que el Monto_apertura sea positivo
    IF @Monto_apertura <= 0
    BEGIN
        RAISERROR('El monto de apertura debe ser positivo.', 16, 1);
        RETURN;
    END
    
    -- Validación para asegurar que el Saldo_cuenta no sea negativo
    IF @Saldo_cuenta < 0
    BEGIN
        RAISERROR('El saldo de la cuenta no puede ser negativo.', 16, 1);
        RETURN;
    END
    
    -- Validación para asegurar que el Tipo_Cuenta exista
    IF NOT EXISTS (SELECT 1 FROM tipoCuenta WHERE Codigo = @Tipo_Cuenta)
    BEGIN
        RAISERROR('El tipo de cuenta especificado no existe.', 16, 1);
        RETURN;
    END
    
    -- Validación para asegurar que el IdCliente exista
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @IdCliente)
    BEGIN
        RAISERROR('El cliente especificado no existe.', 16, 1);
        RETURN;
    END
    
    -- Inserción de datos en la tabla Cuenta
    INSERT INTO Cuenta (Id_cuenta, Monto_apertura, Saldo_cuenta, Descripción, Otros_detalles, Tipo_Cuenta, IdCliente, Fecha_de_apertura)
    VALUES (@Id_cuenta, @Monto_apertura, @Saldo_cuenta, @Descripción, @Otros_detalles, @Tipo_Cuenta, @IdCliente, ISNULL(@Fecha_de_apertura, GETDATE()));

    -- Confirmación de inserción
    PRINT 'Cuenta registrada correctamente';
END;



-- Procedimiento para crear un nuevo producto o servicio

CREATE PROCEDURE registrarProductoServicio
    @Codigo INT,
    @Tipo INT,
    @Costo DECIMAL(12,2) = NULL,
    @Descripción VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación para asegurarse de que el código no esté duplicado
    IF EXISTS (SELECT 1 FROM ProductoServicio WHERE Codigo = @Codigo)
    BEGIN
        RAISERROR('El código del producto o servicio ya existe.', 16, 1);
        RETURN;
    END

    -- Validación para asegurarse de que el costo es obligatorio para servicios
    IF @Tipo = 1 AND @Costo IS NULL
    BEGIN
        RAISERROR('El costo es obligatorio para servicios.', 16, 1);
        RETURN;
    END

    -- Validación para asegurar que productos no tengan costo o tengan costo igual a cero
    IF @Tipo = 2 AND @Costo > 0
    BEGIN
        RAISERROR('El costo no debe ser especificado o debe ser cero para productos.', 16, 1);
        RETURN;
    END

    -- Inserción de datos en la tabla ProductoServicio
    INSERT INTO ProductoServicio (Codigo, Tipo, Costo, Descripción)
    VALUES (@Codigo, @Tipo, @Costo, @Descripción);

    -- Confirmación de inserción
    PRINT 'Producto o servicio registrado correctamente';
END;


--Procedimiento para registrar un tipo de transaccion
CREATE PROCEDURE registrarTipoTransaccion
    @Nombre VARCHAR(20),
    @Descripción VARCHAR(40) = NULL
AS 
BEGIN
    SET NOCOUNT ON;

    -- Validación para asegurarse de que el nombre no esté vacío
    IF @Nombre IS NULL OR LEN(@Nombre) = 0
    BEGIN
        RAISERROR('El nombre de la transacción es obligatorio.', 16, 1);
        RETURN;
    END
    
    -- Validación para evitar duplicados de nombre
    IF EXISTS (SELECT 1 FROM TipoTransaccion WHERE Nombre = @Nombre)
    BEGIN
        RAISERROR('El nombre de la transacción ya existe.', 16, 1);
        RETURN;
    END

    -- Inserción de datos en la tabla TipoTransaccion, permitiendo autoincremento del ID
    INSERT INTO TipoTransaccion (Nombre, Descripción)
    VALUES (@Nombre, @Descripción);

    -- Confirmación de inserción
    PRINT 'Tipo de transacción registrado correctamente';
END;

-- Procedimiento almacenado para registrar una compra
-- Procedimiento almacenado para registrar una compra usando RAISEERROR
CREATE PROCEDURE registrarCompra
    @Id_compra INT,
    @Fecha DATE,
    @Importe_compra DECIMAL(12,2),
    @Otros_Detalles VARCHAR(40),
    @Codigo_producto_servicio INT,
    @Id_cliente INT
AS
BEGIN
    -- Iniciar una transacción para mantener consistencia
    BEGIN TRANSACTION

    -- Verificar que el cliente existe
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR(N'El cliente especificado no existe.', 16, 1)
        RETURN
    END

    -- Verificar que el producto/servicio existe
    IF NOT EXISTS (SELECT 1 FROM ProductoServicio WHERE Codigo = @Codigo_producto_servicio)
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR(N'El producto/servicio especificado no existe.', 16, 1)
        RETURN
    END

    -- Verificar si el producto/servicio es un servicio y el importe es obligatorio
    DECLARE @Tipo INT
    SELECT @Tipo = Tipo FROM ProductoServicio WHERE Codigo = @Codigo_producto_servicio

    IF @Tipo = 1 AND @Importe_compra IS NULL
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR(N'Para servicios, el importe de la compra es obligatorio.', 16, 1)
        RETURN
    END

    -- Insertar en la tabla Compra
    INSERT INTO Compra (
        Id_compra,
        Fecha,
        Importe_compra,
        Otros_Detalles,
        Codigo_producto_servicio,
        Id_cliente
    )
    VALUES (
        @Id_compra,
        @Fecha,
        @Importe_compra,
        @Otros_Detalles,
        @Codigo_producto_servicio,
        @Id_cliente
    )

    -- Confirmar la transacción para completar la operación
    COMMIT TRANSACTION
END




-- Procedimiento para registrar un depósito
-- Procedimiento almacenado para registrar un depósito
CREATE PROCEDURE registrarDeposito
    @Id_deposito INT,
    @Fecha DATE,
    @Monto DECIMAL(12,2),
    @Otros_Detalles VARCHAR(40),
    @Id_cliente INT
AS
BEGIN
    -- Iniciar la transacción para mantener consistencia
    BEGIN TRANSACTION

    -- Verificar que el cliente existe
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR('El cliente especificado no existe.', 16, 1)
    END

    -- Verificar que el monto es positivo
    IF @Monto <= 0
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR('El monto del depósito debe ser positivo.', 16, 1)
    END

    -- Insertar en la tabla Deposito
    INSERT INTO Deposito (
        Id_deposito,
        Fecha,
        Monto,
        Otros_Detalles,
        Id_cliente
    )
    VALUES (
        @Id_deposito,
        @Fecha,
        @Monto,
        @Otros_Detalles,
        @Id_cliente
    )

    -- Commit para completar la transacción
    COMMIT TRANSACTION
END



-- Procedimiento para registrar un débito
CREATE  PROCEDURE registrarDebito
    @Id_debito INT,
    @Fecha DATE,
    @Monto DECIMAL(12,2),
    @Otros_Detalles VARCHAR(40),
    @Id_cliente INT
AS
BEGIN
    -- Iniciar transacción para consistencia
    BEGIN TRANSACTION

    -- Verificar existencia del cliente
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR('El cliente especificado no existe.', 16, 1)
        RETURN
    END

    -- Validar que el monto sea positivo
    IF @Monto <= 0
    BEGIN
        ROLLBACK TRANSACTION
        RAISERROR('El monto del débito debe ser positivo.', 16, 1)
        RETURN
    END

    -- Insertar en la tabla Debito
    INSERT INTO Debito (
        Id_debito,
        Fecha,
        Monto,
        Otros_Detalles,
        Id_cliente
    )
    VALUES (
        @Id_debito,
        @Fecha,
        @Monto,
        @Otros_Detalles,
        @Id_cliente
    )

    -- Confirmar la transacción para completar la operación
    COMMIT TRANSACTION
END



-- Procedimiento almacenado para asignar una transacción
CREATE OR ALTER PROCEDURE asignarTransaccion
    @Fecha DATE,
    @Otros_Detalles VARCHAR(40),
    @Id_tipo_transaccion INT,
    @Id_CompraDebitoDeposito INT,
    @No_cuenta BIGINT
AS
BEGIN
    -- Verificar que el tipo de transacción exista
    IF NOT EXISTS (SELECT 1 FROM TipoTransaccion WHERE Codigo = @Id_tipo_transaccion)
    BEGIN
        THROW 50000, 'El tipo de transacción no existe', 1;
    END

    -- Verificar si el Id_CompraDebitoDeposito corresponde a Compra, Deposito, o Debito
    IF NOT EXISTS (
        SELECT 1
        FROM Compra
        WHERE Id_compra = @Id_CompraDebitoDeposito
    )
    AND NOT EXISTS (
        SELECT 1
        FROM Deposito
        WHERE Id_deposito = @Id_CompraDebitoDeposito
    )
    AND NOT EXISTS (
        SELECT 1
        FROM Debito
        WHERE Id_debito = @Id_CompraDebitoDeposito
    )
    BEGIN
        THROW 50000, 'El ID de Compra, Depósito o Débito no es válido', 1;
    END

    -- Verificar que la cuenta exista y corresponda a un cliente
    IF NOT EXISTS (SELECT 1 FROM Cuenta WHERE Id_cuenta = @No_cuenta)
    BEGIN
        THROW 50000, 'El número de cuenta no existe', 1;
    END

    -- Validar que la cuenta tenga saldo suficiente para compras y débitos
    IF @Id_tipo_transaccion IN (1, 2)  -- Asumiendo que 1 y 2 son para compra y débito
    BEGIN
        DECLARE @Monto DECIMAL(12,2)

        -- Obtener el monto asociado a la transacción
        SELECT @Monto = 
            CASE
                WHEN EXISTS (SELECT 1 FROM Compra WHERE Id_compra = @Id_CompraDebitoDeposito) THEN
                    (SELECT Importe_compra FROM Compra WHERE Id_compra = @Id_CompraDebitoDeposito)
                WHEN EXISTS (SELECT 1 FROM Debito WHERE Id_debito = @Id_CompraDebitoDeposito) THEN
                    (SELECT Monto FROM Debito WHERE Id_debito = @Id_CompraDebitoDeposito)
            END

        IF @Monto IS NULL
        BEGIN
            THROW 50000, 'El monto asociado a la transacción no es válido', 1;
        END

        -- Verificar el saldo de la cuenta
        DECLARE @Saldo DECIMAL(12,2)
        SELECT @Saldo = Saldo_cuenta FROM Cuenta WHERE Id_cuenta = @No_cuenta

        IF @Saldo < @Monto
        BEGIN
            THROW 50000, 'Saldo insuficiente en la cuenta para completar la transacción', 1;
        END
    END

    -- Insertar la nueva transacción
    INSERT INTO Transaccion (Fecha, Otros_Detalles, Id_tipo_transaccion, Id_CompraDebitoDeposito, No_cuenta)
    VALUES (@Fecha, @Otros_Detalles, @Id_tipo_transaccion, @Id_CompraDebitoDeposito, @No_cuenta);

    -- Actualizar el saldo de la cuenta si es un débito o compra
    IF @Id_tipo_transaccion IN (1, 2)
    BEGIN
        UPDATE Cuenta
        SET Saldo_cuenta = Saldo_cuenta - @Monto
        WHERE Id_cuenta = @No_cuenta;
    END
END

