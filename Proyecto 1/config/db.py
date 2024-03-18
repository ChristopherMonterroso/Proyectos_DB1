import pyodbc

def connectDB():
    try:
        conn = pyodbc.connect(
            'DRIVER={SQL Server};'
            'SERVER=DESKTOP-E8GKA5B\\SQLEXPRESS;'
            'DATABASE=DB_Proyecto1;'
            'UID=sa;'
            'PWD=adipul28'
            )
        #print('Conectado a la base de datos')
        return conn
    except Exception as e:
        print('Error al conectar a la base de datos:', e)

def disconnectDB(conn):
    try:
        conn.close()
    except Exception as e:
        print('Error al desconectar de la base de datos:', e)
