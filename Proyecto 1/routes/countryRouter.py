import csv
import io
from flask import Blueprint, request, jsonify
from controllers.countryController import CountryController
from models.country import Country

# Creamos una instancia del controlador de países
country_controller = CountryController()

# Creamos un Blueprint para las rutas relacionadas con los países
country_app = Blueprint('country_app', __name__)

# Ruta para crear un nuevo país
@country_app.route('/create', methods=['POST'])
def create_country():
    data = request.json
    if 'nombre' not in data:
        return jsonify({"error": "El nombre del país es requerido"}), 400

    # Creamos una instancia del país
    new_country = Country(None, data['nombre'])

    # Intentamos crear el país
    if country_controller.create_country(new_country):
        return jsonify({"message": "País creado exitosamente"}), 201
    else:
        return jsonify({"error": "Ocurrió un error al crear el país"}), 500

# Ruta para obtener un país por su ID
@country_app.route('/get/<int:country_id>', methods=['GET'])
def get_country(country_id):
    country = country_controller.get_country(country_id)
    if country:
        return jsonify({"country": country.__dict__}), 200
    else:
        return jsonify({"error": "El país no existe"}), 404

# Ruta para actualizar un país por su ID
@country_app.route('/update/<int:country_id>', methods=['PUT'])
def update_country(country_id):
    data = request.json
    if 'name' not in data:
        return jsonify({"error": "El nombre del país es requerido"}), 400

    updated_country = Country(country_id, data['name'])

    if country_controller.update_country(country_id, updated_country):
        return jsonify({"message": "País actualizado exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al actualizar el país"}), 500

# Ruta para eliminar un país por su ID
@country_app.route('/delete/<int:country_id>', methods=['DELETE'])
def delete_country(country_id):
    if country_controller.delete_country(country_id):
        return jsonify({"message": "País eliminado exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al eliminar el país"}), 500

# Ruta para cargar países desde un archivo CSV
@country_app.route('/massiveLoad', methods=['POST'])
def load_countries_from_csv():
    try:
        if 'file' not in request.files:
            return jsonify({"error": "No se encontró el archivo"}), 400

        if country_controller.bulk_load_countries():
            return jsonify({"message": "Carga masiva de países exitosa"}), 201
        else:
            return jsonify({"error": "Ocurrió un error al cargar los países"}), 500
        
    except Exception as e:
        print("Error al cargar países masivamente:", e)
        return jsonify({"error": "Ocurrió un error al cargar los países"}), 500