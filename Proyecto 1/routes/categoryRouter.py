from flask import Blueprint, request, jsonify
from controllers.categoryController import CategoryController
from models.category import Category

category_controller = CategoryController()
category_app = Blueprint('category_app', __name__)


@category_app.route('/create', methods=['POST'])
def create_category():
    data = request.json
    if 'nombre' not in data:
        return jsonify({"error": "El nombre de la categoría es requerido"}), 400
    new_category = Category(None, data['nombre'])

    if category_controller.create_category(new_category):
        return jsonify({"message": "Categoría creada exitosamente"}), 201
    else:
        return jsonify({"error": "Ocurrió un error al crear la categoría"}), 500

@category_app.route('/get/<int:category_id>', methods=['GET'])
def get_category(category_id):
    category = category_controller.get_category(category_id)
    if category:
        return jsonify({"category": category.__dict__}), 200
    else:
        return jsonify({"error": "La categoría no existe"}), 404

@category_app.route('/update/<int:category_id>', methods=['PUT'])
def update_category(category_id):
    data = request.json
    if 'name' not in data:
        return jsonify({"error": "El nombre de la categoría es requerido"}), 400

    updated_category = Category(category_id, data['name'])

    if category_controller.update_category(category_id, updated_category):
        return jsonify({"message": "Categoría actualizada exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al actualizar la categoría"}), 500

@category_app.route('/delete/<int:category_id>', methods=['DELETE'])
def delete_category(category_id):
    if category_controller.delete_category(category_id):
        return jsonify({"message": "Categoría eliminada exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al eliminar la categoría"}), 500

@category_app.route('/massiveLoad', methods=['POST'])
def load_categories_from_csv():

    if 'file' not in request.files:
        return jsonify({"error": "No se ha proporcionado el archivo."}), 400
    if category_controller.bulk_load_categories():
        return jsonify({"message": "Categorías cargadas exitosamente desde el archivo CSV"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al cargar las categorías desde el archivo CSV"}), 500
