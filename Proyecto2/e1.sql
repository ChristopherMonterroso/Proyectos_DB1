-- INSERCION DE DATOS CLIENTES Y CUENTAS.
-- REGISTROS CLIENTES
EXEC registrarCliente @Id_cliente = 202401, @Nombre = 'Cliente', @Apellidos = 'UnoNacional',    @Teléfonos = '50210001000', @Correo ='clienteuno@calificacion.com.gt', @Usuario = 'ClIeNtE1202401',@Contraseña= 'ClIeNtE1202401', @TipoCliente= '1';
EXEC registrarCliente @Id_cliente = 202402, @Nombre = 'Cliente', @Apellidos = 'DosExtranjero',  @Teléfonos = '50820002000', @Correo ='cliente2ext@calificacion.com.gt',@Usuario = 'userclienteextranjero',@Contraseña= 'ExtraNjer0Pass@word',@TipoCliente= '2';
EXEC registrarCliente @Id_cliente = 202403, @Nombre = 'Cliente', @Apellidos = 'TresPyme',       @Teléfonos = '50230223480-35503080-32803060-50235253030', @Correo ='clientetres@pyme.com.gt', @Usuario = 'userclientepyme', @Contraseña= 'PyMeeMpresa@pass', @TipoCliente= '3';
EXEC registrarCliente @Id_cliente = 202404, @Nombre = 'Cliente', @Apellidos = 'CuatroEmpresaSC',@Teléfonos = '50240004000-40014002', @Correo = 'EmpresaSC@noespyme.com.gt', @Usuario = 'userclienteEmpresaSC', @Contraseña = 'SCeMpreEsa@2024', @TipoCliente = '4';

-- VALIDACIONES DE CLIENTES

EXEC registrarCliente @Id_cliente = 202405,  @Nombre = 'Cliente', @Apellidos = 'numero5', @Teléfonos = '50240004000-40014002', @Correo = 'noregistrar@noespyme.com.gt', @Usuario = 'userclienteEmpresaSC', @Contraseña = 'SCeMpreEsa@2024', @TipoCliente = '5'; -- VALIDA APELLIDO
EXEC registrarCliente @Id_cliente = 202405, @Nombre = 'Cliente',@Apellidos = 'cinco',     @Teléfonos = '50240004000-40014002', @Correo = 'noregistrar@noespyme.com.gt',@Usuario = 'userclienteEmpresaSC',@Contraseña = 'SCeMpreEsa@2024', @TipoCliente = '5'; -- VALIDA USER
EXEC registrarCliente @Id_cliente = 20240t, @Nombre = 'Cliente',@Apellidos = 'cinco',     @Teléfonos = '50240004000-40014002', @Correo = 'noregistrar@noespyme.com.gt',@Usuario = 'userclienteEmpresaSC',@Contraseña = 'SCeMpreEsa@2024',@TipoCliente = '5'; -- VALIDA ID

-- REGISTROS TIPO CLIENTES

EXEC registrarTipoCliente @Nombre= 'ClienteExtra', @Descripción='Cliente Extraordinario' ;
-- VALIDACIONES DE TIPO CLIENTES
EXEC registrarTipoCliente  @Nombre= 'ClienteExtraDos', @Descripción='Cliente Extraordinario 2';-- error numeros
EXEC registrarTipoCliente @Nombre='ClienteExtra',@Descripción='Cliente Extraordinario' ; -- tipo de cliente ya existe

-- REGISTROS CUENTA
--            idcuenta, montoapertura,*saldo, descripcion,                   fechaapertura,             otrosdetalles,idtipocuenta,idcliente
EXEC registrarCuenta @Id_cuenta=20250001,@Monto_apertura =2800.00,@Saldo_cuenta =2800.00,@Descripción ='Apertura de cuenta cheques con Q2800.00',@Fecha_de_apertura ='03-05-2024 13:00:00',@Otros_detalles ='esta apertura tiene fecha',   @Tipo_Cuenta =1,@IdCliente =202401; -- cuenta cheques
EXEC registrarCuenta @Id_cuenta=20250030,@Monto_apertura =1800.00,@Saldo_cuenta =1800.00,@Descripción ='Apertura de cuenta cheques con Q1800.00',@Fecha_de_apertura ='03-05-2024 13:00:00',@Otros_detalles ='esta apertura tiene fecha',   @Tipo_Cuenta =1,@IdCliente =202401; -- cuenta cheques
EXEC registrarCuenta @Id_cuenta=20250002,@Monto_apertura =800.00, @Saldo_cuenta =800.00, @Descripción ='Apertura de cuenta ahorro con Q800.00',  @Fecha_de_apertura ='03-06-2024 14:00:00',@Otros_detalles ='esta apertura tiene fecha',   @Tipo_Cuenta =2,@IdCliente =202401; -- cuenta ahorro
EXEC registrarCuenta @Id_cuenta=20250003,@Monto_apertura =4900.00,@Saldo_cuenta =4900.00,@Descripción ='Apertura de cuenta plus con Q4900.00',   @Fecha_de_apertura ='',                   @Otros_detalles ='',                            @Tipo_Cuenta =3,@IdCliente =202402; -- ahorro plus
EXEC registrarCuenta @Id_cuenta=20250004,@Monto_apertura =100.00, @Saldo_cuenta =100.00, @Descripción ='Apertura de cuenta pequeña con Q100.00', @Fecha_de_apertura ='04-05-2024 09:00:00',@Otros_detalles ='esta apertura tiene fecha',   @Tipo_Cuenta =4,@IdCliente =202403; -- cuenta pequeña
EXEC registrarCuenta @Id_cuenta=20250005,@Monto_apertura =4200.00,@Saldo_cuenta =4200.00,@Descripción ='Apertura de cuenta nomina con Q4200.00', @Fecha_de_apertura ='',                   @Otros_detalles ='esta apertura no tiene fecha',@Tipo_Cuenta =5,@IdCliente =202404; -- cuenta nomina
EXEC registrarCuenta @Id_cuenta=20250006,@Monto_apertura =1100.00,@Saldo_cuenta =1100.00,@Descripción ='Apertura de cuenta inversion con Q1100.00',@Fecha_de_apertura ='',                 @Otros_detalles ='esta apertura no tiene fecha',@Tipo_Cuenta =6,@IdCliente =202404; -- cuenta inversión
-- VALIDACIONES DE CUENTA
EXEC registrarCuenta @Id_cuenta=20250007,@Monto_apertura =2800.00,@Saldo_cuenta =2800.10,@Descripción ='Apertura de cuenta cheques con Q2800.00',@Fecha_de_apertura ='01-04-2024 07:00:00',@Otros_detalles ='esta apertura tiene fecha',   @Tipo_Cuenta =1,@IdCliente =202401; -- error saldo
EXEC registrarCuenta @Id_cuenta=20250007,@Monto_apertura =1100.00,@Saldo_cuenta =1100.00,@Descripción ='Apertura de cuenta inversion con Q1100.00',@Fecha_de_apertura ='',                 @Otros_detalles ='esta apertura no tiene fecha',@Tipo_Cuenta =6,@IdCliente =202405; -- error cliente no existe
EXEC registrarCuenta @Id_cuenta=20250007,@Monto_apertura =1100.00,@Saldo_cuenta =1100.00,@Descripción ='Apertura de cuenta inversion con Q1100.00',@Fecha_de_apertura ='',                 @Otros_detalles ='no existe tipo de cuenta',    @Tipo_Cuenta =8,@IdCliente =202404; -- tipo de cuenta no existe
EXEC registrarCuenta @Id_cuenta=20250005,@Monto_apertura =4200.00,@Saldo_cuenta =4200.00,@Descripción ='Apertura de cuenta nomina con Q4200.00',@Fecha_de_apertura ='',                    @Otros_detalles ='esta apertura no tiene fecha',@Tipo_Cuenta =5,@IdCliente =202404; -- cuenta nominas ya existe

-- REGISTRO TIPO CUENTA
EXEC registrarTipoCuenta @Nombre='',@Descripción=''; -- error nombre y descripción vacíos


-- INGRESO TIPO TRANSACCION
--                    id, tipo, costo, descripcion
EXEC crearProductoServicio  @Codigo =18, @Tipo = 1, @Costo =37.25,@Descripción = 'Servicio de Calificacion';
EXEC crearProductoServicio  @Codigo =19, @Tipo = 2, @Costo = NULL,   @Descripción = 'ProductoCalificacion'; 
-- VALIDACIONES DE TIPO DE TRANSACCION
EXEC crearProductoServicio @Codigo =19, @Tipo =2, @Costo =37.25, @Descripción = 'Servicio de Calificacion con error'; -- error tipo 2 de producto no debe tener precio
EXEC crearProductoServicio @Codigo =20, @Tipo =2, @Costo =-15.25,@Descripción = 'ProductoCalificacionMalo'; -- error precio negativo

-- INGRESO COMPRAS
--              id,      fecha,   monto,  otrosdetalles, codProducto-Servicio, idcliente
EXEC realizarCompra @Id_compra =503801, @Fecha ='08-01-2024', @Importe_compra =40.00, @Otros_detalles ='compraproductocalificacion', @Codigo_producto_servicio =19, @Id_cliente =202401; 
EXEC realizarCompra @Id_compra =503802, @Fecha ='09-01-2024', @Importe_compra =0,     @Otros_detalles ='compraserviciocalificacion', @Codigo_producto_servicio =18, @Id_cliente =202401; 
EXEC realizarCompra @Id_compra =503803, @Fecha ='10-02-2024', @Importe_compra =0,     @Otros_detalles ='compraserviciotarjeta',      @Codigo_producto_servicio =1,  @Id_cliente =202401; 
EXEC realizarCompra @Id_compra =503804, @Fecha ='13-02-2024', @Importe_compra =0,     @Otros_detalles ='comprabancapersonal',        @Codigo_producto_servicio =4,  @Id_cliente =202401; 
EXEC realizarCompra @Id_compra =503805, @Fecha ='15-03-2024', @Importe_compra =500.00,@Otros_detalles ='pagoluzmarzo',               @Codigo_producto_servicio = 11,@Id_cliente =202401; 
EXEC realizarCompra @Id_compra =503806, @Fecha ='15-04-2024', @Importe_compra =550.00,@Otros_detalles ='pagoluzabril',               @Codigo_producto_servicio =11, @Id_cliente =202401; 
EXEC realizarCompra @Id_compra =503807, @Fecha ='15-05-2024', @Importe_compra =420.80,@Otros_detalles ='pagoluzmayo',                @Codigo_producto_servicio =11, @Id_cliente =202401; 
EXEC realizarCompra @Id_compra =503808, @Fecha ='08-01-2024', @Importe_compra =50.35, @Otros_detalles ='pagoagua',                   @Codigo_producto_servicio =12, @Id_cliente =202402; 
EXEC realizarCompra @Id_compra =503809, @Fecha ='09-02-2024', @Importe_compra =150.35,@Otros_detalles ='pagoagua',                   @Codigo_producto_servicio =12, @Id_cliente =202402; 
EXEC realizarCompra @Id_compra =503810, @Fecha ='10-03-2024', @Importe_compra =44.35, @Otros_detalles ='pagoagua',                   @Codigo_producto_servicio =12, @Id_cliente =202402; 
EXEC realizarCompra @Id_compra =503811, @Fecha ='08-01-2024', @Importe_compra =0,     @Otros_detalles ='segurodevidaplus',           @Codigo_producto_servicio =6,  @Id_cliente =202403; 
EXEC realizarCompra @Id_compra =503812, @Fecha ='09-02-2024', @Importe_compra =0,     @Otros_detalles ='segurodelcarro',             @Codigo_producto_servicio =7,  @Id_cliente =202403; 
EXEC realizarCompra @Id_compra =503813, @Fecha ='01-01-2020', @Importe_compra =1150.35,@Otros_detalles ='matriculausac',             @Codigo_producto_servicio =13, @Id_cliente =202404; 
EXEC realizarCompra @Id_compra =503814, @Fecha ='15-03-2024', @Importe_compra =500.50, @Otros_detalles ='pagocursovacas',            @Codigo_producto_servicio =14, @Id_cliente =202404; 
-- VALIDACIONES DE COMPRAS
EXEC realizarCompra @Id_compra =503814, @Fecha ='15-03-2024', @Importe_compra =500.50,    @Otros_detalles ='pagocursovacas', @Codigo_producto_servicio =14, @Id_cliente = 202404; -- compra ya existe
EXEC realizarCompra @Id_compra =505050, @Fecha ='15-03-2024', @Importe_compra =500.50,    @Otros_detalles ='pagocursovacas', @Codigo_producto_servicio =14, @Id_cliente = 123456987; -- error cliente no existe

-- INGRESO DEPOSITOS
--              id,      fecha,     monto,  otrosdetalles, idcliente
EXEC realizarDeposito @Id_deposito =329701, @Fecha ='01-01-2024', @Monto =200.00, @Otros_detalles ='deposito a 202401 de 202402', @Id_cliente =202402;
EXEC realizarDeposito @Id_deposito =329702, @Fecha ='02-04-2024', @Monto =300.00, @Otros_detalles ='deposito a 202403 de 202402', @Id_cliente =202402;
EXEC realizarDeposito @Id_deposito =329703, @Fecha ='01-01-2024', @Monto =1000.00,@Otros_detalles = 'deposito a 202404 de 202402',@Id_cliente = 202402;
EXEC realizarDeposito @Id_deposito =329704, @Fecha ='28-02-2024', @Monto =200.00, @Otros_detalles ='deposito a 202402 de 202401', @Id_cliente =202401;
-- VALIDACIONES DE DEPOSITOS
EXEC realizarDeposito @Id_deposito =329704, @Fecha ='28-02-2024', @Monto =200.00, @Otros_detalles ='deposito a 202402 de 202401', @Id_cliente = 202401; -- deposito ya existe
EXEC realizarDeposito @Id_deposito =329704, @Fecha ='28-02-2024', @Monto =200.00, @Otros_detalles ='deposito a 202402 de 202401', @Id_cliente = 123456789; -- error cliente no existe
EXEC realizarDeposito @Id_deposito =329797, @Fecha ='28-02-2024', @Monto =0.00,   @Otros_detalles ='deposito a 202402 de 202401', @Id_cliente = 123456789; -- error monto 0


-- INGRESO RETIROS
--              id,      fecha,     monto,  otrosdetalles, idcliente
EXEC realizarDebito @Id_debito =429701, @Fecha ='10-05-2024',@Monto = 600.00,@Otros_detalles = 'retiro de dinero de cliente UnoNacional',@Id_cliente = 202401;
EXEC realizarDebito @Id_debito =429702, @Fecha ='10-04-2024',@Monto = 100.55,@Otros_detalles = 'retiro de dinero DosExtranjero',         @Id_cliente = 202402;
EXEC realizarDebito @Id_debito =429703, @Fecha ='10-03-2024',@Monto = 50.45, @Otros_detalles ='retiro de dinero TresPyme',               @Id_cliente = 202403;
EXEC realizarDebito @Id_debito =429704, @Fecha ='10-02-2024',@Monto = 200.85,@Otros_detalles = 'retiro de dinero CuatroEmpresaSC',       @Id_cliente = 202404;
-- VALIDACIONES DE RETIROS
EXEC realizarDebito @Id_debito =429704, @Fecha ='10-02-2024',@Monto = 200.85,@Otros_detalles = 'retiro de dinero CuatroEmpresaSC',@Id_cliente =  202404; -- retiro ya existe
EXEC realizarDebito @Id_debito =429704, @Fecha ='10-02-2024',@Monto = 200.85,@Otros_detalles = 'retiro de dinero CuatroEmpresaSC',@Id_cliente =  123456789; -- error cliente no existe
EXEC realizarDebito @Id_debito =429704, @Fecha ='10-02-2024',@Monto = 0.00,  @Otros_detalles = 'retiro de dinero CuatroEmpresaSC',@Id_cliente = 202404; -- error monto 0


EXEC registrarTipoTransaccion
	@Nombre = 'Compra',
	@Descripción = 'Transacción de compra';	

EXEC registrarTipoTransaccion
	@Nombre = 'Deposito',
	@Descripción = 'Transacción de deposito';

EXEC registrarTipoTransaccion
	@Nombre = 'Debito',
	@Descripción = 'Transacción de debito';

-- REGISTRO TRANSACCIONES
--                id,  fecha,  otrosdetalles,     id_tipo_transaccion, idcompra-deposito-debito, nocuenta
EXEC asignarTransaccion @Fecha ='08-02-2024',  @Id_tipo_transaccion = 1, @Id_compra =   503801, @No_cuenta =20250001, @Otros_Detalles ='compraproductocalificacion'; -- transacción de compra
EXEC asignarTransaccion @Fecha ='09-01-2024',  @Id_tipo_transaccion = 1, @Id_compra =   503802, @No_cuenta =20250001, @Otros_Detalles ='compraserviciocalificacion'; -- transacción de compra
EXEC asignarTransaccion @Fecha ='10-02-2024',  @Id_tipo_transaccion = 1, @Id_compra =   503803, @No_cuenta =20250002, @Otros_Detalles ='compraserviciotarjeta'; -- transacción de compra
EXEC asignarTransaccion @Fecha ='13-02-2024',  @Id_tipo_transaccion = 1, @Id_compra =   503804, @No_cuenta =20250002, @Otros_Detalles ='comprabancapersonal'; -- transacción de compra
EXEC asignarTransaccion @Fecha ='15-03-2024',  @Id_tipo_transaccion = 1, @Id_compra =   503805, @No_cuenta =20250001, @Otros_Detalles ='pagoluzmarzo'; -- transacción de compra
EXEC asignarTransaccion @Fecha ='15-04-2024',  @Id_tipo_transaccion = 1, @Id_compra =   503806, @No_cuenta =20250002, @Otros_Detalles ='pagoluzabril'; -- transacción de compra
EXEC asignarTransaccion @Fecha ='15-05-2024',  @Id_tipo_transaccion = 1, @Id_compra =   503807, @No_cuenta =20250002, @Otros_Detalles ='pagoluzmayo'; -- transacción de compra
EXEC asignarTransaccion @Fecha ='10-05-2024',  @Id_tipo_transaccion = 3, @Id_debito = 429701, @No_cuenta =20250001, @Otros_Detalles ='debito'; -- transacción debito
EXEC asignarTransaccion @Fecha ='10-04-2024',  @Id_tipo_transaccion = 3, @Id_debito = 429702, @No_cuenta =20250003, @Otros_Detalles ='debito'; -- transacción debito
EXEC asignarTransaccion @Fecha ='10-03-2024',  @Id_tipo_transaccion = 3, @Id_debito = 429703, @No_cuenta =20250004, @Otros_Detalles ='debito'; -- transacción debito
EXEC asignarTransaccion @Fecha ='10-02-2024',  @Id_tipo_transaccion = 3, @Id_debito = 429704, @No_cuenta =20250006, @Otros_Detalles ='debito'; -- transacción debito
-- VALIDACIONES DE TRANSACCIONES
--EXEC asignarTransaccion 8, '10-02-2024','debito',3, 429704, 20250006; -- transacción ya existe

EXEC registrarTipoTransaccion @Nombre ='', @Descripción ='';  -- error nombre y descripción vacíos