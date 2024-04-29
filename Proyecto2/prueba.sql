
EXEC registrarTipoCliente
	 @Nombre= 'Cliente Extraordinario', 
	 @Descripción='Este cliente no esta definido en el enunciado, es un tipo de cliente extra'
	 ;

EXEC registrarCliente
	 @Id_cliente = 1001, 
	 @Nombre = 'Juan Isaac',
	 @Apellidos = 'Perez Lopez',
	 @Teléfonos = '22888080',
	 @Correo ='micorreo@gmail.com',
	 @Usuario = 'jisaacp2024',
	 @Contraseña= '12345678',
	 @TipoCliente= '1';

EXEC registrarCliente
	 @Id_cliente = 1002, 
	 @Nombre = 'Maria Isabel',
	 @Apellidos = 'Gonzalez Perez',
	 @Teléfonos = '22805050-22808080',
	 @Correo ='micorreo1@gmail.com|micorreo2@gmail.com',
	 @Usuario = 'mariauser',
	 @Contraseña= '12345679',
	 @TipoCliente= '2';

EXEC registrarTipoCuenta
	@Nombre= 'Cuenta Extraordinaria',
	@Descripción= 'Cuenta Extraordinaria a enunciado';

EXEC registrarCuenta
	@Id_cuenta=3030206080, 
	@Monto_apertura = 500.00, 
    @Saldo_cuenta = 800.00, 
    @Descripción = 'Apertura de cuenta con Q500',
    @Fecha_de_apertura = NULL,  -- Usa NULL en lugar de una cadena vacía
    @Otros_detalles = '',
    @Tipo_Cuenta = 1,
    @IdCliente = 1001;

EXEC registrarCuenta
	@Id_cuenta=3030206081, 
	@Monto_apertura = 600.00, 
    @Saldo_cuenta = 600.00, 
    @Descripción = 'Apertura de cuenta con Q600',
    @Fecha_de_apertura = '01/04/2024 07:00:00',  -- Usa NULL en lugar de una cadena vacía
    @Otros_detalles = 'esta apertura tiene fecha',
    @Tipo_Cuenta = 1,
    @IdCliente = 1001;

EXEC registrarProductoServicio
	 @Codigo = 18,
	 @Tipo = 1,
	 @Costo = 50.80,
	 @Descripción = 'Este es un servicio el cual tiene un precio predefinido';

EXEC registrarProductoServicio
	 @Codigo = 19,
	 @Tipo = 2,
	 @Costo = NULL,
	 @Descripción = 'Este es un producto el cual tiene un precio variable';

EXEC registrarTipoTransaccion
	@Nombre = 'Compra',
	@Descripción = 'Transacción de compra';	

EXEC registrarTipoTransaccion
	@Nombre = 'Deposito',
	@Descripción = 'Transacción de deposito';

EXEC registrarTipoTransaccion
	@Nombre = 'Debito',
	@Descripción = 'Transacción de debito';

EXEC registrarCompra
	@Id_compra = 1111,
	@Fecha = '10/04/2024',
	@Importe_compra = 40,
	@Otros_detalles = 'compra de servicio',
	@Codigo_producto_servicio = 18,
	@Id_cliente = 1001;

EXEC registrarCompra
	@Id_compra  = 1112,
	@Fecha = '10/04/2024',
	@Importe_compra = 0,
	@Otros_detalles = 'compra de producto',
	@Codigo_producto_servicio = 19,
	@Id_cliente = 1001;

EXEC registrarCompra
	@Id_compra  = 1113,
	@Fecha = '10/04/2024',
	@Importe_compra = 50,
	@Otros_detalles = 'compra de producto',
	@Codigo_producto_servicio = 19,
	@Id_cliente = 1001;

EXEC registrarDeposito
	@Id_deposito = 1114,
	@Fecha = '10/04/2024',
	@Monto = 100,
	@Otros_detalles = 'deposito de dinero',
	@Id_cliente = 1001;

EXEC registrarDeposito
	@Id_deposito = 1115,
	@Fecha = '10/04/2024',
	@Monto = 0,
	@Otros_detalles = 'deposito de dinero',
	@Id_cliente = 1001;

EXEC registrarDebito
	@Id_debito = 1116,
	@Fecha = '10/04/2024',
	@Monto = 100,
	@Otros_detalles = 'retiro de dinero',
	@Id_cliente = 1001;

EXEC registrarDebito
	@Id_debito = 1117,
	@Fecha = '10/04/2024',
	@Monto = 0,
	@Otros_detalles = 'retiro de dinero con error',
	@Id_cliente = 1001;

EXEC asignarTransaccion
	@Fecha = '10/04/2024',
	@Otros_Detalles = '',
	@Id_Tipo_Transaccion = 1,
	@Id_Compra = 1113,
	@No_cuenta = 3030206080;

EXEC asignarTransaccion
	@Fecha = '10/04/2024',
	@Otros_Detalles = '',
	@Id_Tipo_Transaccion = 2,
	@Id_Deposito = 1114,
	@No_cuenta = 3030206080;

EXEC asignarTransaccion
	@Fecha = '10/04/2024',
	@Otros_Detalles = 'este si tiene detalle',
	@Id_Tipo_Transaccion = 3,
	@Id_debito = 1116,
	@No_cuenta = 3030206080;


-- realizar compra
--              id,      fecha,   monto,  otrosdetalles, codProducto/Servicio, idcliente
realizarCompra(1111, '10/04/2024', 40, 'compra de servicio', 18, 1001); --aqui hay error ya que el monto deberia de ser cero por que ya tiene un precio preestablecido por ser un servicio
realizarCompra(1112, '10/04/2024', 0, 'compra de producto', 19, 1001); --aqui hay error debido a que el monto deberia de ser > 0 ya que es un producto y no tiene un precio preestablecido
realizarCompra(1113, '10/04/2024', 50, 'compra de producto', 19, 1001); --aqui esta correcto ya que el monto es mayor a cero y es un producto

-- realizar deposito
--              id,      fecha,     monto,  otrosdetalles, idcliente
realizarDeposito(1114, '10/04/2024', 100, 'deposito de dinero', 1001);
realizarDeposito(1115, '10/04/2024', 0, 'deposito de dinero', 1001); --aqui hay error ya que el monto deberia de ser mayor a cero

realizarDebito(1116, '10/04/2024', 100, 'retiro de dinero', 1001);
realizarDebito(1117, '10/04/2024', 0, 'retiro de dinero con error', 1001); --aqui hay error ya que el monto deberia de ser mayor a cero

-- registrar transaccion
--              id,      fecha,  otrosdetalles, id_tipo_transaccion, idcompra/deposito/debito, nocuenta
asignarTransaccion(1118, '10/04/2024','', 1, 1113,0,0, 3030206080); -- aqui hay error debido a que no se tiene el saldo suficiente para realizar la compra
asignarTransaccion(1115, '10/04/2024','',2, 0,1114,0, 3030206080); -- se realia deposito *aqui se puede depositar a una cuenta que no es del cliente
asignarTransaccion(1120, '10/04/2024','este si tiene detalle',3, 0,0,1116, 3030206080); -- se realiza un debito




