from flask import Blueprint, request, jsonify
from controllers.customerController import CustomerController
from models.customer import Customer

# Creamos una instancia del controlador de clientes
customer_controller = CustomerController()

# Creamos un Blueprint para las rutas relacionadas con los clientes
customer_app = Blueprint('customer_app', __name__)

# Ruta para crear un nuevo cliente
@customer_app.route('/create', methods=['POST'])
def create_customer():
    data = request.json
    if 'nombre' not in data or 'apellido' not in data or 'direccion' not in data or 'telefono' not in data or 'tarjeta_credito' not in data or 'edad' not in data or 'genero' not in data or 'salario' not in data or 'id_pais' not in data:
        return jsonify({"error": "Todos los campos son requeridos"}), 400

    # Creamos una instancia del cliente
    new_customer = Customer(None, data['nombre'], data['apellido'], data['direccion'], data['telefono'], data['tarjeta_credito'], data['edad'], data['genero'], data['salario'], data['id_pais'])

    # Intentamos crear el cliente
    if customer_controller.create_customer(new_customer):
        return jsonify({"message": "Cliente creado exitosamente"}), 201
    else:
        return jsonify({"error": "Ocurrió un error al crear el cliente"}), 500

# Ruta para obtener un cliente por su ID
@customer_app.route('/get/<int:customer_id>', methods=['GET'])
def get_customer(customer_id):
    customer = customer_controller.get_customer(customer_id)
    if customer:
        return jsonify({"customer": customer.__dict__}), 200
    else:
        return jsonify({"error": "El cliente no existe"}), 404

# Ruta para actualizar un cliente por su ID
@customer_app.route('/update/<int:customer_id>', methods=['PUT'])
def update_customer(customer_id):
    data = request.json
    if 'nombre' not in data or 'apellido' not in data or 'direccion' not in data or 'telefono' not in data or 'tarjeta_credito' not in data or 'edad' not in data or 'genero' not in data or 'salario' not in data or 'id_pais' not in data:
        return jsonify({"error": "Todos los campos son requeridos"}), 400

    updated_customer = Customer(customer_id, data['nombre'], data['apellido'], data['direccion'], data['telefono'], data['tarjeta_credito'], data['edad'], data['genero'], data['salario'], data['id_pais'])

    if customer_controller.update_customer(customer_id, updated_customer):
        return jsonify({"message": "Cliente actualizado exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al actualizar el cliente"}), 500

# Ruta para eliminar un cliente por su ID
@customer_app.route('/delete/<int:customer_id>', methods=['DELETE'])
def delete_customer(customer_id):
    if customer_controller.delete_customer(customer_id):
        return jsonify({"message": "Cliente eliminado exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al eliminar el cliente"}), 500

# Ruta para cargar clientes desde un archivo CSV
@customer_app.route('/massiveLoad', methods=['POST'])
def massive_load():
    try:
        file = request.files['file']
        if not file:
            return jsonify({"error": "No se ha enviado el archivo"}), 400
        if customer_controller.bulk_load_customers():
            return jsonify({"message": "Clientes cargados exitosamente desde el archivo CSV"}), 200
        else:
            return jsonify({"error": "Ocurrió un error al cargar los clientes desde el archivo CSV"}), 500
    except Exception as e:
        return jsonify({"error": "Ocurrió un error al cargar los clientes"}), 500