from config import db
from models.category import Category
from flask import request
import csv
import io
class CategoryController:
    def create_category(self, category):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("INSERT INTO CATEGORIA (id_categoria,nombre) VALUES (?,?)", (category.id_category, category.name,))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error creating category:", e)
            return False

    def get_category(self, category_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM CATEGORIA WHERE id_categoria = ?", (category_id,))
            category_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            if category_data:
                return Category(category_data[0], category_data[1])
            else:
                return None
        except Exception as e:
            print("Error getting category:", e)
            return None

    def update_category(self, category_id, new_category_data):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("UPDATE Categories SET Name = ? WHERE Id = ?",
                           (new_category_data.name, category_id))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error updating category:", e)
            return False

    def delete_category(self, category_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("DELETE FROM Categories WHERE Id = ?", (category_id,))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error deleting category:", e)
            return False
    def bulk_load_categories(self):
        try:
            csv_file = request.files['file']
            content = csv_file.stream.read().decode("UTF8")

            # Convierte el contenido en un objeto StringIO
            new_csv_file = io.StringIO(content)

            # Crea un objeto lector CSV
            csv_reader = csv.reader(new_csv_file, delimiter=';')
            next(csv_reader, None)
            # Itera sobre cada fila en el archivo CSV
            for row in csv_reader:
                
                category = Category(row[0], row[1])
                
                # Llamamos al método create_category para agregarla a la base de datos
                self.create_category(category)
           
            return True
        except Exception as e:
            print("Error bulk loading categories:", e)
            return False
        