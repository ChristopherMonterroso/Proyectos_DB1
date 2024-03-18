import csv
import io
from config import db
from models.product import Product
from flask import request

class ProductController:
    def create_product(self, product):
        try:
            # Verificar si el producto ya existe
            if self.product_exists(product.name):
                print("El producto ya existe.")
                return False

            # Verificar si la categoría existe
            if not self.category_exists(product.id_category):
                print("La categoría no existe.")
                return False

            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("INSERT INTO PRODUCTO (id_producto, nombre, precio, id_categoria) VALUES (?,?, ?, ?)",
                           (product.id_product ,product.name, product.price, product.id_category))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error creating product:", e)
            return False

    def get_product(self, product_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM PRODUCTO WHERE id_producto = ?", (product_id,))
            product_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            if product_data:
                return Product(product_data[1], product_data[2], product_data[3])
            else:
                return None
        except Exception as e:
            print("Error getting product:", e)
            return None

    def update_product(self, product_id, new_product_data):
        try:
            # Verificar si la categoría existe
            if not self.category_exists(new_product_data.id_category):
                print("La categoría no existe.")
                return False

            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("UPDATE PRODUCTO SET nombre = ?, precio = ?, id_categoria = ? WHERE id_producto = ?",
                           (new_product_data.name, new_product_data.price, new_product_data.id_category, product_id))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error updating product:", e)
            return False

    def delete_product(self, product_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("DELETE FROM PRODUCTO WHERE id_producto = ?", (product_id,))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error deleting product:", e)
            return False

    def product_exists(self, product_name):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM PRODUCTO WHERE nombre = ?", (product_name,))
            product_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            return True if product_data else False
        except Exception as e:
            print("Error checking if product exists:", e)
            return False

    def category_exists(self, category_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM CATEGORIA WHERE id_categoria = ?", (category_id,))
            category_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            return True if category_data else False
        except Exception as e:
            print("Error checking if category exists:", e)
            return False

    def bulk_load_products(self):
        try:
            if 'file' not in request.files:
                return False

            csv_file = request.files['file']
            content = csv_file.stream.read().decode("UTF8")
            new_csv_file = io.StringIO(content)
            csv_reader = csv.reader(new_csv_file, delimiter=';')
            next(csv_reader, None)
            for row in csv_reader:
                if len(row) >= 3:  # Verifica que haya al menos 3 elementos en la fila (nombre, precio, id_categoria)
                    id_producto = row[0]
                    name = row[1]
                    price = float(row[2])
                    id_category = int(row[3])

                    # Crea una instancia de Product con los valores obtenidos
                    product = Product(id_producto,name, price, id_category)
                    
                    # Verificar si el producto ya existe antes de crearlo
                    if not self.product_exists(product.name):
                        # Verificar si la categoría existe antes de crear el producto
                        if self.category_exists(product.id_category):
                            # Llama al método create_product para agregar el producto a la base de datos
                            self.create_product(product)
                        else:
                            print("No se pudo cargar el producto. La categoría no existe.")
                    else:
                        print("No se pudo cargar el producto. El producto ya existe.")
                else:
                    print("La fila no tiene suficientes elementos:", row)

            return True
        except Exception as e:
            print("Error bulk loading products:", e)
            return False
