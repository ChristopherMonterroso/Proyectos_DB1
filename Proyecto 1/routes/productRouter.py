from flask import Flask, request, jsonify
from controllers.productController import ProductController
from models.product import Product
from flask import Blueprint

product_app = Blueprint('product_app', __name__)


# Crea una instancia del controlador de productos
product_controller = ProductController()

# Ruta para crear un nuevo producto
@product_app.route('/create', methods=['POST'])
def create_product():
    data = request.json
    name = data.get('name')
    price = data.get('price')
    category = data.get('category')
    if not name or not price or not category:
        return jsonify({'error': 'Missing required fields'}), 400
    new_product = Product(name, price, category)
    if product_controller.create_product(new_product):
        return jsonify({'message': 'Product created successfully'}), 201
    else:
        return jsonify({'error': 'Failed to create product'}), 500

# Ruta para obtener un producto por su ID
@product_app.route('/get/<int:product_id>', methods=['GET'])
def get_product(product_id):
    product = product_controller.get_product(product_id)
    if product:
        return jsonify({'product': {'name': product.name, 'price': product.price, 'category': product.category}}), 200
    else:
        return jsonify({'error': 'Product not found'}), 404

# Ruta para actualizar un producto por su ID
@product_app.route('/update/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    data = request.json
    name = data.get('name')
    price = data.get('price')
    category = data.get('category')
    if not name or not price or not category:
        return jsonify({'error': 'Missing required fields'}), 400
    new_product_data = Product(name, price, category)
    if product_controller.update_product(product_id, new_product_data):
        return jsonify({'message': 'Product updated successfully'}), 200
    else:
        return jsonify({'error': 'Failed to update product'}), 500

# Ruta para eliminar un producto por su ID
@product_app.route('/delete/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    if product_controller.delete_product(product_id):
        return jsonify({'message': 'Product deleted successfully'}), 200
    else:
        return jsonify({'error': 'Failed to delete product'}), 500
    

@product_app.route('/massiveLoad', methods=['POST'])
def load_products_from_csv():
    try:
        if 'file' not in request.files:
            return jsonify({"error": "No se ha proporcionado un archivo CSV"}), 400

        if product_controller.bulk_load_products():
            return jsonify({"message": "Productos cargados exitosamente desde el archivo CSV"}), 200
        else:
            return jsonify({"error": "Ocurrió un error al cargar los productos desde el archivo CSV"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500
if __name__ == '__main__':
    product_app.run(debug=True)
