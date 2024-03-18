import csv
import io
from flask import request
from config import db
from models.saleOrder import SaleOrder
from datetime import datetime
class SaleOrderController:
    def create_sale_order(self,saleOrder):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("INSERT INTO ORDEN_VENTA (id_orden_venta,id_cliente,id_empleado,fecha,id_producto,cantidad) VALUES (?,?,?,?,?,?)", (saleOrder.id,saleOrder.idCustomer,saleOrder.idEmployee,saleOrder.date,saleOrder.idproduct,saleOrder.amount))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)


            return True
        except:
            return False
    def get_sale_order(self, sale_order_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM ORDEN_VENTA WHERE id_orden_venta = ?", (sale_order_id,))
            sale_order_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            if sale_order_data:
                return SaleOrder(sale_order_data[0], sale_order_data[1], sale_order_data[2], sale_order_data[3], sale_order_data[4], sale_order_data[5])
            else:
                return None
        except:
            return None
    
    def update_sale_order(self, sale_order_id, new_sale_order_data):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("UPDATE ORDEN_VENTA SET id_cliente = ?, id_empleado = ?, fecha = ?, id_producto = ?, cantidad = ? WHERE id_orden_venta = ?", (new_sale_order_data.idCustomer, new_sale_order_data.idEmployee, new_sale_order_data.date, new_sale_order_data.idproduct, new_sale_order_data.amount, sale_order_id))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except:
            return False
    
    def delete_sale_order(self, sale_order_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("DELETE FROM ORDEN_VENTA WHERE id_orden_venta = ?", (sale_order_id,))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except:
            return False
    def load_sale_orders_from_csv(self):
        
            if 'file' not in request.files:
                return False
            csv_file = request.files['file']
            content = csv_file.stream.read().decode("UTF8")
            stream = io.StringIO(content)
            csv_reader = csv.reader(stream, delimiter=';')
            next(csv_reader, None)
            conn = db.connectDB()
            cursor = conn.cursor()
            for row in csv_reader:
    # Convertir la fecha al formato YYYY-MM-DD
                fecha_str = row[2]
                fecha_obj = datetime.strptime(fecha_str, "%d/%m/%Y")
                fecha_sql = fecha_obj.strftime("%Y-%m-%d")

                # Resto de tu código para insertar en la base de datos...
                cursor.execute("INSERT INTO ORDEN_VENTA (id_orden,linea_orden,fecha_orden,id_cliente,id_vendedor,id_producto,cantidad) VALUES (?,?,?,?,?,?,?)", (row[0], row[1], fecha_sql, row[3], row[4], row[5], row[6]))
                conn.commit()
            cursor.close()
            db.disconnectDB(conn)

                    
            
            return True
        