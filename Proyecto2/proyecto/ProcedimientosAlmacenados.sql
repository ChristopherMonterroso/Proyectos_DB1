DROP PROCEDURE IF EXISTS registrarTipoCliente;
DROP PROCEDURE IF EXISTS registrarCliente;
DROP PROCEDURE IF EXISTS registrarTipoCuenta;
DROP PROCEDURE IF EXISTS registrarCuenta;
DROP PROCEDURE IF EXISTS crearProductoServicio
DROP PROCEDURE IF EXISTS registrarTipoTransaccion;
DROP PROCEDURE IF EXISTS realizarCompra
DROP PROCEDURE IF EXISTS realizarDeposito;
DROP PROCEDURE IF EXISTS realizarDebito;
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
    IF EXISTS (SELECT 1 FROM TipoCliente WHERE Nombre = @Nombre)
    BEGIN
        RAISERROR('Este tipo de cliente ya existe', 16, 1);
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
    -- Intentar convertir @Id_cliente a INT
    DECLARE @IdClienteInt INT;
    BEGIN TRY
        SET @IdClienteInt = CAST(@Id_cliente AS INT);
    END TRY
    BEGIN CATCH
        RAISERROR('El ID del cliente debe ser un número entero.', 16, 1);
        RETURN;
    END CATCH
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

    IF LEN(@Nombre) = 0 OR LEN(@Descripción) =0
    BEGIN
        RAISERROR('El nombre y la descripción son obligatorios.', 16, 1);
        RETURN;
    END

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
    IF @Saldo_cuenta != @Monto_apertura
    BEGIN
        RAISERROR('El saldo de la cuenta debe ser igual al monto de apertura.', 16, 1);
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
    
    IF EXISTS (SELECT 1 FROM Cuenta WHERE Id_cuenta = @Id_cuenta)
    BEGIN
        RAISERROR('Esta cuenta ya existe.', 16, 1);
        RETURN;
    END

    -- Inserción de datos en la tabla Cuenta
    INSERT INTO Cuenta (Id_cuenta, Monto_apertura, Saldo_cuenta, Descripción, Otros_detalles, Tipo_Cuenta, IdCliente, Fecha_de_apertura)
    VALUES (@Id_cuenta, @Monto_apertura, @Saldo_cuenta, @Descripción, @Otros_detalles, @Tipo_Cuenta, @IdCliente, ISNULL(@Fecha_de_apertura, GETDATE()));

    -- Confirmación de inserción
    PRINT 'Cuenta registrada correctamente';
END;



-- Procedimiento para crear un nuevo producto o servicio

CREATE PROCEDURE crearProductoServicio
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
    IF @Tipo = 2 AND @Costo < 0
    BEGIN
        RAISERROR('El costo no debe ser negativo.', 16, 1);
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
    @Descripción VARCHAR(40) 
AS 
BEGIN
    SET NOCOUNT ON;

    -- Validación para asegurarse de que el nombre no esté vacío
    IF LEN(@Nombre) = 0 OR LEN(@Descripción) =0
    BEGIN
        RAISERROR('El nombre y/o descripción de la transacción es obligatorio.', 16, 1);
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
CREATE PROCEDURE realizarCompra
    @Id_compra INT,
    @Fecha VARCHAR(10),
    @Importe_compra DECIMAL(12,2),
    @Otros_Detalles VARCHAR(40),
    @Codigo_producto_servicio INT,
    @Id_cliente INT
AS
BEGIN
    BEGIN TRY
        -- Iniciar la transacción
        DECLARE @FechaDate DATE;
        SET @FechaDate = CONVERT(DATE, @Fecha, 103);
        BEGIN TRANSACTION

        IF EXISTS (SELECT 1 FROM Compra WHERE Id_compra = @Id_compra)
        BEGIN
            RAISERROR('La compra ya existe.', 16, 1);
            ROLLBACK;  -- Hacer rollback si el ID de la compra ya existe
            RETURN;
        END
        -- Verificar que el cliente existe
        IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
        BEGIN
            RAISERROR('El cliente especificado no existe.', 16, 1);
            ROLLBACK;  -- Hacer rollback si el cliente no existe
            RETURN;
        END
        
        -- Verificar que el producto/servicio existe
        IF NOT EXISTS (SELECT 1 FROM ProductoServicio WHERE Codigo = @Codigo_producto_servicio)
        BEGIN
            RAISERROR('El producto/servicio especificado no existe.', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        -- Verificar el tipo de producto/servicio
        DECLARE @Tipo INT
        SELECT @Tipo = Tipo FROM ProductoServicio WHERE Codigo = @Codigo_producto_servicio
        
        IF @Tipo = 1 AND @Importe_compra > 0 
        BEGIN
            RAISERROR('Para servicios, el importe de la compra debería ser cero.', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        IF @Tipo = 2 AND @Importe_compra <= 0
        BEGIN
            RAISERROR('Para productos, el importe de la compra debe ser mayor a cero.', 16, 1);
            ROLLBACK;
            RETURN;
        END
        
        -- Establecer el valor del servicio si es un servicio
        IF @Tipo = 1 
        BEGIN
            SET @Importe_compra = (SELECT Costo FROM ProductoServicio WHERE Codigo = @Codigo_producto_servicio)
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
            @FechaDate,
            @Importe_compra,
            @Otros_Detalles,
            @Codigo_producto_servicio,
            @Id_cliente
        )
        
        -- Confirmar la transacción si todo está correcto
        COMMIT
        
        PRINT 'Compra registrada correctamente'
    
    END TRY
    BEGIN CATCH
        -- Hacer rollback si ocurre un error
        IF @@TRANCOUNT > 0
            ROLLBACK
        
        -- Devolver un mensaje de error
        DECLARE @ErrorMessage VARCHAR(255)
        DECLARE @ErrorSeverity INT
        DECLARE @ErrorState INT
        
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);  -- Usar RAISEERROR para devolver el error
        
    END CATCH
END

-- Procedimiento para registrar un depósito
CREATE PROCEDURE realizarDeposito
    @Id_deposito INT,
    @Fecha VARCHAR(10),
    @Monto DECIMAL(12,2),
    @Otros_Detalles VARCHAR(40),
    @Id_cliente INT
AS
BEGIN
    -- Verificar que el cliente existe
    DECLARE @FechaDate DATE;
    SET @FechaDate = CONVERT(DATE, @Fecha, 103);

    IF EXISTS (SELECT 1 FROM Deposito WHERE Id_deposito = @Id_deposito)
    BEGIN
        RAISERROR('El depósito ya existe.', 16, 1)
        RETURN
    END
    IF @Monto <= 0
    BEGIN
        RAISERROR('El monto del depósito debe ser mayor a 0.', 16, 1)
        RETURN
    END
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
    BEGIN
        RAISERROR('El cliente especificado no existe.', 16, 1)
        RETURN
    END

    -- Verificar que el monto es positivo
    

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
        @FechaDate,
        @Monto,
        @Otros_Detalles,
        @Id_cliente
    )
    PRINT 'Depósito registrado correctamente'
END



-- Procedimiento para registrar un débito
CREATE  PROCEDURE realizarDebito
    @Id_debito INT,
    @Fecha VARCHAR(10),
    @Monto DECIMAL(12,2),
    @Otros_Detalles VARCHAR(40),
    @Id_cliente INT
AS
BEGIN
    DECLARE @FechaDate DATE;
    SET @FechaDate = CONVERT(DATE, @Fecha, 103);

    IF EXISTS (SELECT 1 FROM Debito WHERE Id_debito = @Id_debito)
    BEGIN
        RAISERROR('El débito ya existe.', 16, 1)
        RETURN
    END
    -- Verificar existencia del cliente
    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE Id_cliente = @Id_cliente)
    BEGIN
        RAISERROR('El cliente especificado no existe.', 16, 1)
        RETURN
    END

    -- Validar que el monto sea positivo
    IF @Monto <= 0
    BEGIN
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
        @FechaDate,
        @Monto,
        @Otros_Detalles,
        @Id_cliente
    )
    PRINT 'Débito registrado correctamente'
END



-- Procedimiento almacenado para asignar una transacción
CREATE PROCEDURE asignarTransaccion
(
    @Fecha VARCHAR(10),
    @Id_tipo_transaccion INT,
    @No_cuenta BIGINT,
    @Id_compra INT = NULL,
    @Id_deposito INT = NULL,
    @Id_debito INT = NULL,
    @Otros_Detalles VARCHAR(40) = NULL
)
AS
BEGIN
    DECLARE @Id_cliente INT;
    DECLARE @Saldo DECIMAL(12,2);
    DECLARE @Monto DECIMAL(12,2);

    DECLARE @FechaDate DATE;
    SET @FechaDate = CONVERT(DATE, @Fecha, 103);


    -- Validar que el tipo de transacción sea válido
    IF NOT EXISTS (SELECT 1 FROM TipoTransaccion WHERE Codigo = @Id_tipo_transaccion)
    BEGIN
        RAISERROR ('El tipo de transacción no es válido.', 16, 1);
        RETURN;
    END
    
    -- Validar que la cuenta exista
    IF @Id_compra IS NOT NULL 
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Compra WHERE Id_compra = @Id_compra)
        BEGIN
            RAISERROR ('La compra especificada no existe.', 16, 1);
            RETURN;
        END

        SELECT @Id_cliente = Id_cliente FROM Compra WHERE Id_compra = @Id_compra;

        -- Aqui valido que el número de cuenta le pertenezca al cliente
        IF NOT EXISTS (SELECT 1 FROM Cuenta WHERE Id_cuenta = @No_cuenta AND IdCliente = @Id_cliente)
        BEGIN
            RAISERROR ('El número de cuenta no pertenece al cliente de la compra.', 16, 1);
            RETURN;
        END

        SELECT @Saldo = Saldo_cuenta FROM Cuenta WHERE Id_cuenta = @No_cuenta;
        SELECT @Monto = Importe_compra FROM Compra WHERE Id_compra = @Id_compra;

        IF @Saldo < @Monto
        BEGIN
            RAISERROR ('El saldo de la cuenta es insuficiente para realizar la compra.', 16, 1);
            RETURN;
        END
        --Se actualiza el saldo de la cuenta
        SELECT @Saldo = @Saldo - @Monto;
        UPDATE Cuenta SET Saldo_cuenta = @Saldo WHERE Id_cuenta = @No_cuenta;

        INSERT INTO Transaccion (Fecha, Id_tipo_transaccion, No_cuenta, Id_compra, Id_deposito, Id_debito, Otros_Detalles)
        VALUES (@FechaDate, @Id_tipo_transaccion, @No_cuenta, @Id_compra, @Id_deposito, @Id_debito, @Otros_Detalles);  
        PRINT 'Transacción registrada correctamente';
    END
    IF @Id_deposito IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Deposito WHERE Id_deposito = @Id_deposito)
        BEGIN
            RAISERROR ('El depósito especificado no existe.', 16, 1);
            RETURN;
        END
        SELECT @Id_cliente = Id_cliente FROM Deposito WHERE Id_deposito = @Id_deposito;

        IF NOT EXISTS (SELECT 1 FROM Cuenta WHERE Id_cuenta = @No_cuenta AND IdCliente = @Id_cliente)
        BEGIN
            RAISERROR ('El número de cuenta no pertenece al cliente del depósito.', 16, 1);
            RETURN;
        END
        -- Se obtiene el saldo de la cuenta y el monto del depósito
        SELECT @Saldo = Saldo_cuenta FROM Cuenta WHERE Id_cuenta = @No_cuenta;
        SELECT @Monto = Monto FROM Deposito WHERE Id_deposito = @Id_deposito;
        -- se suma el monto al saldo de la cuenta
        SELECT @Saldo = @Saldo + @Monto;
        UPDATE Cuenta SET Saldo_cuenta = @Saldo WHERE Id_cuenta = @No_cuenta;

        INSERT INTO Transaccion (Fecha, Id_tipo_transaccion, No_cuenta, Id_compra, Id_deposito, Id_debito, Otros_Detalles)
        VALUES(@FechaDate , @Id_tipo_transaccion, @No_cuenta, @Id_compra, @Id_deposito, @Id_debito, @Otros_Detalles);
        PRINT 'Transacción registrada correctamente';
    END  

    IF @Id_debito IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Debito WHERE Id_debito = @Id_debito)
        BEGIN
            RAISERROR ('El débito especificado no existe.', 16, 1);
            RETURN;
        END
        SELECT @Id_cliente = Id_cliente FROM Debito WHERE Id_debito = @Id_debito;

        IF NOT EXISTS (SELECT 1 FROM Cuenta WHERE Id_cuenta = @No_cuenta AND IdCliente = @Id_cliente)
        BEGIN
            RAISERROR ('El número de cuenta no pertenece al cliente del débito.', 16, 1);
            RETURN;
        END
        SELECT @Saldo = Saldo_cuenta FROM Cuenta WHERE Id_cuenta = @No_cuenta;
        SELECT @Monto = Monto FROM Debito WHERE Id_debito = @Id_debito;

        IF @Saldo < @Monto
        BEGIN
            RAISERROR ('El saldo de la cuenta es insuficiente para realizar el débito.', 16, 1);
            RETURN;
        END
         --Se actualiza el saldo de la cuenta
        SELECT @Saldo = @Saldo - @Monto;
        UPDATE Cuenta SET Saldo_cuenta = @Saldo WHERE Id_cuenta = @No_cuenta;

        INSERT INTO Transaccion (Fecha, Id_tipo_transaccion, No_cuenta, Id_compra, Id_deposito, Id_debito, Otros_Detalles)
        VALUES (@FechaDate, @Id_tipo_transaccion, @No_cuenta, @Id_compra, @Id_deposito, @Id_debito, @Otros_Detalles);

        PRINT 'Transacción registrada correctamente';
    END
END;