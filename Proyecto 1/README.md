# <center>**PROYECTO 1**</center>
*

### TECNOLOGIAS
- Python
- Flask
- SQL SERVER

### API
 Para la api se utiliza el framework Flask de python, siguiendo la siguiente estructura:
 ```
 /config/
 /controllers/
 /models/
 /routes/
 app.py
```
- config: En esta carpeta se encuentra la configuración a la base de datos.
- controllers: En esta carpeta se encuentra todos los controladores para cada modelo de la base de datos, tales como función para carga masiva, crear, obtener, actualizar y eliminar información.
- models: En esta carpeta se encuentran la representación en python(clases) de cada modelo de la base de datos.
- routes: En esta carpeta se encuentran los archivos que manejan los endpoints para cada controlador, además se encuentra el archivo index.py el cual expone todas las rutas.
- app.py: Archivo principal, este activa la aplicación.


### BASE DE DATOS
- Se utiliza el siguiente query para crear la base de datos de forma manual.
```
	CREATE  DATABASE  DB_Proyecto1;
	USE DB_Proyecto1;
```	
	

- Función para conectarse a la base de datos.
```
def  connectDB():

	try:

	conn  =  pyodbc.connect(

	'DRIVER={SQL Server};'

	'SERVER=DESKTOP-E8GKA5B\\SQLEXPRESS;'

	'DATABASE=DB_Proyecto1;'

	'UID=sa;'

	'PWD=adipul28'

	)

	return  conn

	except  Exception  as  e:

	print('Error al conectar a la base de datos:', e)
```
-  Función para desconectarse de la base de datos
```
def  disconnectDB(conn):

	try:

	conn.close()

	except  Exception  as  e:

	print('Error al desconectar de la base de datos:', e)
```
- Para cargar los modelos de forma manual ver el archivo tables.sql el cuál contiene el Script completo o utilizar los siguientes endpoints:

| Descripción |Endpoint|
|-------------|---------|
|Crear tablas |/api/queries/createTables|
|Eliminar todos los datos de las tablas| /api/queries/deleteData|
|Eliminar tablas | /api/queries/deleteTables|
|Cargar información categorías |/api/categories/massiveLoad|
|Cargar información países |/api/countries/massiveLoad|
|Cargar información productos |/api/products/massiveLoad|
|Cargar información vendedores |/api/employees/massiveLoad|
|Cargar información clientes |/api/customers/massiveLoad|
|Cargar información ordenes de venta |/api/saleOrders/massiveLoad|

### Reportes
Para los reportes y gestión de base de datos se utiliza la siguiente función:
```
@queries_app.route('/<string:name>', methods=['GET'])
def  query(name):
	try:
```
		if  name  not  in  queries_controller.queries:
			return  jsonify({"error": "La consulta no existe"}), 404

Verifica si el nombre de la consulta no está en el diccionario `queries_controller.queries`. Si no está presente, devuelve un error JSON con un mensaje de que la consulta no existe y un código de estado HTTP 404 (No encontrado).

		if  name  !=  "deleteTables"  and  name  !=  "createTables"  and  name  !=  "deleteData":

			conn  =  db.connectDB()
			cursor  =  conn.cursor()
			cursor.execute(queries_controller.queries[name]())
Establece una conexión a la base de datos sí se comprueba que es una consulta a la base de datos y no una modificación, crea un cursor y ejecuta la consulta correspondiente obtenida del diccionario `queries_controller.queries` utilizando el nombre de la consulta como clave.

			query_result  =  cursor.fetchall()
Obtiene todos los resultados de la consulta ejecutada.

		if  query_result:
			result_json  = []
			column_names  = [column[0] for  column  in  cursor.description]
			for  row  in  query_result:
			result_json.append(dict(zip(column_names, row)))
			cursor.close()
			db.disconnectDB(conn)
			return  jsonify({f"{name} result": result_json}), 200
		else:
			cursor.close()
			db.disconnectDB(conn)
			return  jsonify({f"{name} result": "No hay resultados"}), 200
Si hay resultados de la consulta, los convierte en una lista de diccionarios donde las claves son los nombres de las columnas y los valores son los valores correspondientes de cada fila. Luego, devuelve estos resultados como JSON con un código de estado HTTP 200 (Éxito). Si no hay resultados, devuelve un mensaje indicando que no hay resultados.

		else:
			conn  =  db.connectDB()
			cursor  =  conn.cursor()
			cursor.execute(queries_controller.queries[name]())
			conn.commit()
			cursor.close()
			db.disconnectDB(conn)
		return  jsonify({f"{name} result": "Operación exitosa"}), 200
Si el nombre de la consulta coincide con uno de los valores específicos ("deleteTables", "createTables", "deleteData"), ejecuta la consulta correspondiente y realiza la operación indicada. Luego, devuelve un mensaje de éxito como JSON con un código de estado HTTP 200.

	except  Exception  as  e:
		print(f"Error executing {name}:", e)
		return  jsonify({"error": "Ocurrió un error al ejecutar la consulta"}), 500
Captura cualquier excepción que ocurra durante la ejecución de la función y devuelve un mensaje de error JSON junto con un código de estado HTTP 500 (Error interno del servidor). Además, imprime el nombre de la consulta y el error en la consola para facilitar el seguimiento y la depuración.



Para testear los reportes seguir la siguiente tabla de endpoints:

| Consulta | Endpoint | Detalle |
|----------|----------|---------|
| <center>1| /api/queries/consulta1 |El cliente que más ha comprado|
|<center>2| /api/queries/consulta2 |El producto más y menos comprado|
|<center>3| /api/queries/consulta3 |La persona que más ha vendido|
|<center>4| /api/queries/consulta4 |El país que más y menos ha vendido|
|<center>5| /api/queries/consulta5 |Top 5 de países que más han comprado en orden ascendente|
|<center>6| /api/queries/consulta6 |La categoría que más y menos se ha comprado|
|<center>7| /api/queries/consulta7 |La categoría más comprada por cada país|
|<center>8| /api/queries/consulta8 |Las ventas por mes de Inglaterra|
|<center>9| /api/queries/consulta9 |El mes con más y menos ventas|
|<center>10| /api/queries/consulta10 |Las ventas de cada producto de la categoría deportes|
- Consulta 1, respuesta esperada: 
 ```
"consulta1 result":  [
	{
	"apellido":  "Olson",
	"id_cliente":  19887,
	"monto_total":  1894.130012512207,
	"nombre":  "Evelyn",
	"numero_compras":  43,
	"pais":  "Inglaterra"
	}
]
```
- Consulta 2, respuesta esperada: 
 ``` 
 {
"consulta2 result":  [
	{
	"cantidad_unidades":  37,
	"categoria":  "Accion",
	"id_producto":  28,
	"monto_vendido":  517.6300086975098,
	"nombre_producto":  "ACADEMY ANTHEM"
	}
]
}
 ```
 - Consulta 3, respuesta esperada: 
 ```
{
	"consulta3 result":  [
	{
	"id_vendedor":  94,
	"monto_total_vendido":  26956.510139465332,
	"nombre_vendedor":  "Samuel Snodgrass"
	}
]
}
 ```
 - Consulta 4, respuesta esperada: 
 ```
 {
"consulta4 result":  [
{
	"monto_maximo_vendido":  317023.9611644745,
	"monto_minimo_vendido":  119695.18047904968,
	"pais_mas_vendido":  "Polonia",
	"pais_menos_vendido":  "Rusia"
	}
	]
}
 ```
 - Consulta 5, respuesta esperada: 
 ```
 {
	"consulta5 result":  [
	{
	"ID_Pais":  7,
	"Monto":  110226.98043823242,
	"Nombre":  "Japon"
	},
	{
	"ID_Pais":  6,
	"Monto":  116289.89038658142,
	"Nombre":  "Alemania"
	},
	{
	"ID_Pais":  10,
	"Monto":  116802.63041877747,
	"Nombre":  "Inglaterra"
	},
	{
	"ID_Pais":  8,
	"Monto":  119224.40048027039,
	"Nombre":  "Rusia"
	},
	{
	"ID_Pais":  5,
	"Monto":  122133.02045440674,
	"Nombre":  "Francia"
	}
	]
}
 ```
 - Consulta 6, respuesta esperada: 
 ```
 {
	"consulta6 result":  [
	{
	"cantidad_unidades_mas_comprada":  7920,
	"categoria_mas_comprada":  "Extrajeros"
	},
	{
	"cantidad_unidades_mas_comprada":  7066,
	"categoria_mas_comprada":  "Drama"
	}
	]
}
 ```
 - Consulta 7, respuesta esperada: 
 ```
 {

	"consulta7 result":  [
	{
	"Categoria":  "Extrajeros",
	"Pais":  "Rusia",
	"Unidades":  417
	},
	{
	"Categoria":  "Clasicos",
	"Pais":  "Polonia",
	"Unidades":  443
	},
	{
	"Categoria":  "Documentales",
	"Pais":  "Japon",
	"Unidades":  382
	},
	{
	"Categoria":  "Nuevo",
	"Pais":  "Inglaterra",
	"Unidades":  408
	},
	{
	"Categoria":  "Familia",
	"Pais":  "Francia",
	"Unidades":  431
	},
	{
	"Categoria":  "Documentales",
	"Pais":  "Estados Unidos",
	"Unidades":  4006
	},
	{
	"Categoria":  "Clasicos",
	"Pais":  "China",
	"Unidades":  454
	},
	{
	"Categoria":  "Extrajeros",
	"Pais":  "Chile",
	"Unidades":  443
	},
	{
	"Categoria":  "Animacion",
	"Pais":  "Canada",
	"Unidades":  483
	},
	{
	"Categoria":  "Viajes",
	"Pais":  "Australia",
	"Unidades":  471
	},
	{
	"Categoria":  "Documentales",
	"Pais":  "Alemania",
	"Unidades":  459
	}
	]
} 
 ```
 - Consulta 8, respuesta esperada: 
 ```
 {
	"consulta8 result":  [
	{
	"Monto":  23519.000091552734,
	"Numero_Mes":  1
	},
	{
	"Monto":  24837.57010269165,
	"Numero_Mes":  2
	},
	{
	"Monto":  25417.360118865967,
	"Numero_Mes":  3
	},
	{
	"Monto":  24633.760118484497,
	"Numero_Mes":  4
	},
	{
	"Monto":  23470.27007675171,
	"Numero_Mes":  5
	},
	{
	"Monto":  26132.200103759766,
	"Numero_Mes":  6
	},
	{
	"Monto":  24917.540075302124,
	"Numero_Mes":  7
	},
	{
	"Monto":  23974.000101089478,
	"Numero_Mes":  8
	},
	{
	"Monto":  23417.3000831604,
	"Numero_Mes":  9
	},
	{
	"Monto":  27114.370121002197,
	"Numero_Mes":  10
	},
	{
	"Monto":  27395.47014427185,
	"Numero_Mes":  11
	},
	{
	"Monto":  23573.850101470947,
	"Numero_Mes":  12
	}
	]
}
 ```
  - Consulta 9, respuesta esperada: 
 ```
	 {
	"consulta9 result":  [
	{
	"Monto_Total":  206283.36075019836,
	"Numero_Mes":  10,
	"Tipo_Mes":  "Mes con más ventas"
	},
	{
	"Monto_Total":  196948.13069915771,
	"Numero_Mes":  12,
	"Tipo_Mes":  "Mes con menos ventas"
	}
	]
}
 ```
  - Consulta 10, respuesta esperada: 
 ```
 {
	"consulta10 result":  [
			{
			"Numero_de_Filas":  624
			}
	]
}
 ```
