import csv
import io
from flask import request
from config import db
from models.employee import Employee

class EmployeeController:
    def create_employee(self, employee):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("INSERT INTO VENDEDOR (id_VENDEDOR,nombre,id_pais) VALUES (?,?,?)", (employee.id,employee.name,employee.country))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error creating employee:", e)
            return False
    
    def get_employee(self, employee_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM VENDEDOR WHERE id_VENDEDOR = ?", (employee_id,))
            employee_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            if employee_data:
                return Employee(employee_data[0], employee_data[1], employee_data[2], employee_data[3], employee_data[4])
            else:
                return None
        except Exception as e:
            print("Error getting employee:", e)
            return None
    
    def update_employee(self, employee_id, new_employee_data):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("UPDATE VENDEDOR SET nombre = ?,  id_pais = ? WHERE id_VENDEDOR = ?", (new_employee_data.name, new_employee_data.country, employee_id))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error updating employee:", e)
            return False
    
    def delete_employee(self, employee_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("DELETE FROM VENDEDOR WHERE id_VENDEDOR = ?", (employee_id,))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error deleting employee:", e)
            return False
    
    def employee_exists(self, employee_name):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM VENDEDOR WHERE nombre = ?", (employee_name,))
            employee_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            if employee_data:
                return True
            else:
                return False
        except Exception as e:
            print("Error checking if employee exists:", e)
            return False
    def get_employees(self):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM VENDEDOR")
            employees_data = cursor.fetchall()
            cursor.close()
            db.disconnectDB(conn)
            employees = []
            for employee in employees_data:
                employees.append(Employee(employee[0], employee[1], employee[2]))
            return employees
        except Exception as e:
            print("Error getting employees:", e)
            return None
        
    def import_employees(self):

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
                cursor.execute("INSERT INTO VENDEDOR (id_VENDEDOR,nombre,id_pais) VALUES (?,?,?)", (row[0], row[1], row[2]))
                cursor.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True

        except Exception as e:
            print("Error importing employees:", e)
            return False