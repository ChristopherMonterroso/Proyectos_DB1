USE P2BD1_finanzas;
DROP TABLE IF EXISTS Transaccion;
DROP TABLE IF EXISTS Debito;
DROP TABLE IF EXISTS Deposito;
DROP TABLE IF EXISTS Compra;
DROP TABLE IF EXISTS TipoTransaccion;
DROP TABLE IF EXISTS ProductoServicio;
DROP TABLE IF EXISTS Cuenta;
DROP TABLE IF EXISTS tipoCuenta;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS TipoCliente;
DROP TABLE IF EXISTS HistorialCambios;

-- Tabla para tipos de cliente
CREATE TABLE TipoCliente (
    Id INT IDENTITY(1,1) PRIMARY KEY,  -- ID autoincrementable como clave primaria
    Nombre VARCHAR(30),               -- Nombre del tipo de cliente
    Descripción VARCHAR(100),          -- Descripción del tipo de cliente
);

-- Tabla para clientes
CREATE TABLE Cliente (
    Id_cliente INT  PRIMARY KEY,  -- Clave primaria autoincremental
    Nombre VARCHAR(40),                        -- Nombre del cliente
    Apellidos VARCHAR(40),                     -- Apellidos del cliente
    Teléfonos VARCHAR(12),                     -- Número de teléfono sin código de área
    Correo VARCHAR(40),                        -- Correo electrónico
    Usuario VARCHAR(40) UNIQUE,                -- Usuario, debe ser único
    Contraseña VARCHAR(200),                   -- Contraseña, almacenamiento seguro
    TipoCliente INT,                           -- Clave foránea para el tipo de cliente
    -- Validaciones para solo letras en Nombre y Apellidos
    CONSTRAINT CHK_Nombre_SoloLetras CHECK (Nombre NOT LIKE '%[^a-zA-Z ]%'),
    CONSTRAINT CHK_Apellidos_SoloLetras CHECK (Apellidos NOT LIKE '%[^a-zA-Z ]%'),
    -- Validación para formato de correo electrónico
    CONSTRAINT CHK_Correo_Valido CHECK (Correo LIKE '%_@__%.__%'),
    -- Clave foránea para verificar que el TipoCliente exista
    FOREIGN KEY (TipoCliente) REFERENCES TipoCliente(Id)
);
-- Agregar la columna 'Salt' a la tabla 'Cliente'
ALTER TABLE Cliente
ADD Salt VARCHAR(16);  -- Tamaño suficiente para almacenar la sal generada por NEWID


-- Tabla para tipos de cuenta
CREATE TABLE tipoCuenta (
    Codigo INT IDENTITY(1,1) PRIMARY KEY,  -- Autoincrementable y clave primaria
    Nombre VARCHAR(30),                    -- Nombre del tipo de cuenta
    Descripción VARCHAR(120)               -- Descripción del tipo de cuenta
);

-- Tabla para cuentas
CREATE TABLE Cuenta (
    Id_cuenta BIGINT PRIMARY KEY, 
    Monto_apertura DECIMAL(12,2),             -- Monto de apertura
    Saldo_cuenta DECIMAL(12,2),               -- Saldo actual de la cuenta
    Descripción VARCHAR(50),                  -- Descripción de la cuenta
    Fecha_de_apertura DATETIME,               -- Fecha de apertura, sin valor por defecto
    Otros_detalles VARCHAR(100),              -- Campo opcional
    Tipo_Cuenta INT,                          -- Relación con tipo de cuenta
    IdCliente INT,                            -- Relación con cliente
    
    -- Validación para Monto_apertura para ser positivo
    CONSTRAINT CHK_Monto_apertura_Positive CHECK (Monto_apertura > 0),

    -- Validación para Saldo_cuenta para ser no negativo
    CONSTRAINT CHK_Saldo_cuenta_Positive CHECK (Saldo_cuenta >= 0),

    -- Relación con tipoCuenta
    FOREIGN KEY (Tipo_Cuenta) REFERENCES tipoCuenta(Codigo),

    -- Relación con Cliente
    FOREIGN KEY (IdCliente) REFERENCES Cliente(Id_cliente)
);


-- Tabla para productos y servicios
CREATE TABLE ProductoServicio (
    Codigo INT PRIMARY KEY,  -- Clave primaria, el código del producto/servicio
    Tipo INT,                -- 1 para servicio, 2 para producto
    Costo DECIMAL(12,2) NULL, -- Costo, obligatorio para servicios
    Descripción VARCHAR(100) -- Descripción del producto/servicio
);

-- Restricción para asegurarse de que el costo sea obligatorio si es un servicio
ALTER TABLE ProductoServicio
ADD CONSTRAINT CHK_Costo_Para_Servicio
CHECK (
    (Tipo = 1 AND Costo IS NOT NULL)  -- Si es un servicio, el costo debe tener un valor
    OR
    (Tipo = 2 AND Costo IS NULL)      -- Si es un producto, el costo puede ser nulo
);


-- Tabla para tipo de transacciones
CREATE TABLE TipoTransaccion (
    Codigo INT IDENTITY(1,1) PRIMARY KEY,  -- Clave primaria autoincrementable
    Nombre VARCHAR(20) NOT NULL,           -- Nombre de la transacción
    Descripción VARCHAR(40)                -- Descripción de la transacción
);

-- Tabla para compras
CREATE TABLE Compra (
    Id_compra INT  PRIMARY KEY,  -- Clave primaria autoincrementable
    Fecha DATE NOT NULL,                       -- Fecha de la compra
    Importe_compra DECIMAL(12,2),              -- Importe de la compra
    Otros_Detalles VARCHAR(40),                -- Campo opcional para detalles adicionales
    Codigo_producto_servicio INT,              -- Clave foránea para producto/servicio
    Id_cliente INT,                            -- Clave foránea para el cliente

    -- Validación para Importe_compra: obligatorio para productos
    CONSTRAINT CHK_Importe_Para_Producto CHECK (
        (Codigo_producto_servicio IS NOT NULL AND Importe_compra IS NOT NULL) OR
        (Codigo_producto_servicio IS NULL)
    ),

    -- Relación con ProductoServicio
    FOREIGN KEY (Codigo_producto_servicio) REFERENCES ProductoServicio(Codigo),

    -- Relación con Cliente
    FOREIGN KEY (Id_cliente) REFERENCES Cliente(Id_cliente)
);

-- Tabla para depositos
CREATE TABLE Deposito (
    Id_deposito INT  PRIMARY KEY,  -- Clave primaria autoincrementable
    Fecha DATE NOT NULL,                        -- Fecha del depósito
    Monto DECIMAL(12,2) NOT NULL,               -- Monto del depósito
    Otros_Detalles VARCHAR(40),                 -- Campo opcional para detalles adicionales
    Id_cliente INT,                             -- Clave foránea para cliente

    -- Validación para Monto: debe ser positivo
    CONSTRAINT CHK_Monto_Deposito_Positive CHECK (Monto > 0),

    -- Relación con Cliente
    FOREIGN KEY (Id_cliente) REFERENCES Cliente(Id_cliente)
);

-- Tabla para debitos
CREATE TABLE Debito (
    Id_debito INT  PRIMARY KEY,  -- Clave primaria autoincrementable
    Fecha DATE NOT NULL,                       -- Fecha del débito
    Monto DECIMAL(12,2) NOT NULL,              -- Monto del débito
    Otros_Detalles VARCHAR(40),                -- Campo opcional para detalles adicionales
    Id_cliente INT,                            -- Clave foránea para cliente

    -- Validación para Monto: debe ser positivo
    CONSTRAINT CHK_Monto_Debito_Positive CHECK (Monto > 0),

    -- Relación con Cliente
    FOREIGN KEY (Id_cliente) REFERENCES Cliente(Id_cliente)
);


-- Tabla para transacciones
CREATE TABLE Transaccion (
    Id_transaccion INT IDENTITY(1,1) PRIMARY KEY,  -- Clave primaria autoincrementable
    Fecha DATE NOT NULL,                           -- Fecha de la transacción
    Otros_Detalles VARCHAR(40),                    -- Campo opcional para detalles adicionales
    Id_tipo_transaccion INT,                       -- Clave foránea para tipo de transacción
    Id_compra INT NULL,                            -- Referencia a Compra
    Id_deposito INT NULL,                          -- Referencia a Depósito
    Id_debito INT NULL,                            -- Referencia a Débito
    No_cuenta BIGINT,                              -- Número de cuenta, debe corresponder al cliente
    
    -- Relación con tipo de transacción
    FOREIGN KEY (Id_tipo_transaccion) REFERENCES TipoTransaccion(Codigo),
    
    -- Relación con Cuenta
    FOREIGN KEY (No_cuenta) REFERENCES Cuenta(Id_cuenta),

    -- Relación con Compra
    FOREIGN KEY (Id_compra) REFERENCES Compra(Id_compra),
    
    -- Relación con Depósito
    FOREIGN KEY (Id_deposito) REFERENCES Deposito(Id_deposito),
    
    -- Relación con Débito
    FOREIGN KEY (Id_debito) REFERENCES Debito(Id_debito)
);

-- Ahora se puede crear un índice en la columna No_cuenta para mejorar el rendimiento en búsquedas
CREATE INDEX IDX_Transaccion_Cuenta ON Transaccion (No_cuenta);

CREATE TABLE HistorialCambios (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATETIME DEFAULT GETDATE(),  -- Fecha y hora del evento
    Descripción VARCHAR(255),          -- Descripción del evento
    Tipo VARCHAR(10)                   -- Tipo de operación (INSERT, UPDATE, DELETE)
);


-- Inserta datos en la tabla tipoCuenta
INSERT INTO tipoCuenta (Nombre, Descripción)
VALUES 
    ('Cuenta de Cheques', 'Este tipo de cuenta ofrece la facilidad de emitir cheques para realizar transacciones monetarias.'),
    ('Cuenta de Ahorros', 'Esta cuenta genera un interés anual del 2%, lo que la hace ideal para guardar fondos a largo plazo.'),
    ('Cuenta de Ahorro Plus', 'Con una tasa de interés anual del 10%, esta cuenta de ahorros ofrece mayores rendimientos.'),
    ('Pequeña Cuenta', 'Una cuenta de ahorros con un interés semestral del 0.5%, ideal para pequeños ahorros y movimientos.'),
    ('Cuenta de Nómina', 'Diseñada para recibir depósitos de sueldo y realizar pagos, con acceso a servicios bancarios básicos.'),
    ('Cuenta de Inversión', 'Orientada a inversionistas, ofrece opciones de inversión y rendimientos más altos que una cuenta de ahorros estándar.');

INSERT INTO tipoCliente (Nombre, Descripción)
VALUES
    ('Individual Nacional', 'Este tipo de cliente es una persona individual de nacionalidad guatemalteca.'),
    ('Individual Extranjero', 'Este tipo de cliente es una persona individual de nacionalidad extranjera.'),
    ('Empresa PyMe', 'Este tipo de cliente es una empresa de tipo pequeña o mediana.'),
    ('Empresa S.C', 'Este tipo de cliente corresponde a las empresa grandes que tienen una sociedad colectiva.');

INSERT INTO ProductoServicio (Codigo, Tipo, Costo, Descripción)
VALUES
    (1,1,10.00, 'Servicio de tarjeta de debito'),
    (2,1,20.00, 'Servicio de chequera'),
    (3,1,400.00,'Servicio de asesoramiento financiero'),
    (4,1,5.00,  'Servicio de banca personal'),
    (5,1,30.00, 'Seguro de vida'),
    (6,1,100.00,'Seguro de vida plus'),
    (7,1,300.00,'Seguro de automóvil'),
    (8,1,500.00,'Seguro de automóvil plus'),
    (9,1,0.05,'Servicio de depósito'),
    (10,1,0.10,'Servicio de débito'),
    (11,2,NULL,'Pago de energía Eléctrica (EEGSA)'),
    (12,2,NULL,'Pago de agua potable(Empagua)'),
    (13,2,NULL,'Pago de Matricula USAC'),
    (14,2,NULL,'Pago de curso vacaciones USAC'),
    (15,2,NULL,'Pago de servicio de internet'),
    (16,2,NULL,'Servicio de suscripción plataformas streaming'),
    (17,2,NULL,'Servicios Cloud');
