import csv
import io
from flask import request
from config import db
from models.customer import Customer

class CustomerController:
    def create_customer(self, customer):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("INSERT INTO CLIENTE (id_cliente,nombre,apellido,direccion,telefono,tarjeta_credito,edad,genero,salario,id_pais) VALUES (?,?,?,?,?,?,?,?,?,?)", (customer.id,customer.name,customer.lastname,customer.address,
                                                                                                                                                                            customer.phone,customer.creditCard,customer.age,
                                                                                                                                                                            customer.gender,customer.salary,customer.country))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error creating customer:", e)
            return False

    def get_customer(self, customer_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM CLIENTE WHERE id_cliente = ?", (customer_id,))
            customer_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            if customer_data:
                return Customer(customer_data[0], customer_data[1], customer_data[2], customer_data[3], customer_data[4], customer_data[5], customer_data[6], customer_data[7], customer_data[8], customer_data[9])
            else:
                return None
        except Exception as e:
            print("Error getting customer:", e)
            return None
    
    def update_customer(self, customer_id, new_customer_data):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("UPDATE CLIENTE SET nombre = ?, apellido = ?, direccion = ?, telefono = ?, tarjeta_credito = ?, edad = ?, genero = ?, salario = ?, id_pais = ? WHERE id_cliente = ?", (new_customer_data.name, new_customer_data.lastname, new_customer_data.address, new_customer_data.phone, new_customer_data.creditCard, new_customer_data.age, new_customer_data.gender, new_customer_data.salary, new_customer_data.country, customer_id))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error updating customer:", e)
            return False
    
    def delete_customer(self, customer_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("DELETE FROM CLIENTE WHERE id_cliente = ?", (customer_id,))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error deleting customer:", e)
            return False
    
    def bulk_load_customers(self):
        try:
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
                cursor.execute("INSERT INTO CLIENTE (id_cliente,nombre,apellido,direccion,telefono,tarjeta_credito,edad,genero,salario,id_pais) VALUES (?,?,?,?,?,?,?,?,?,?)", (row[0], row[1], row[2], row[3], row[4], row[5], row[6],row[8], row[7] ,row[9]))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error loading customers from CSV:", e)
            return False
                                                                                                                                                                                                