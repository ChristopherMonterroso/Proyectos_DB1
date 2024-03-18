import csv
import io
from config import db
from models.country import Country
from flask import request

class CountryController:
    def create_country(self, country):
        try:
            # Verificar si el país ya existe
            if self.country_exists(country.name):
                print("El país ya existe.")
                return False

            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("INSERT INTO PAIS (id_pais,nombre) VALUES (?,?)", (country.id,country.name,))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error creating country:", e)
            return False
    
    def get_country(self, country_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM PAIS WHERE id_pais = ?", (country_id,))
            country_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            if country_data:
                return Country(country_data[0], country_data[1])
            else:
                return None
        except Exception as e:
            print("Error getting country:", e)
            return None
    
    def update_country(self, country_id, new_country_data):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("UPDATE PAIS SET nombre = ? WHERE id_pais = ?", (new_country_data.name, country_id))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error updating country:", e)
            return False
    
    def delete_country(self, country_id):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("DELETE FROM PAIS WHERE id_pais = ?", (country_id,))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error deleting country:", e)
            return False
    
    def country_exists(self, country_name):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM PAIS WHERE nombre = ?", (country_name,))
            country_data = cursor.fetchone()
            cursor.close()
            db.disconnectDB(conn)
            if country_data:
                return True
            else:
                return False
        except Exception as e:
            print("Error checking if country exists:", e)
            return False
    
    def get_countries(self):
        try:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM PAIS")
            countries_data = cursor.fetchall()
            cursor.close()
            db.disconnectDB(conn)
            countries = []
            for country in countries_data:
                countries.append(Country(country[0], country[1]))
            return countries
        except Exception as e:
            print("Error getting countries:", e)
            return None
    
    def bulk_load_countries(self):
        try:
            csv_file = request.files['file']
            content = csv_file.stream.read().decode("UTF8")
            stream = io.StringIO(content)
            csv_reader = csv.reader(stream, delimiter=';')
            next(csv_reader, None)
            conn = db.connectDB()
            cursor = conn.cursor()
            for row in csv_reader:
                cursor.execute("INSERT INTO PAIS (id_pais,nombre) VALUES (?,?)", (row[0],row[1]))
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return True
        except Exception as e:
            print("Error importing countries:", e)
            return False