import csv
import io
from flask import request, jsonify , Blueprint
from config import db
from models.saleOrder import SaleOrder
from controllers.saleOrderController import SaleOrderController

sale_order_controller = SaleOrderController()

sale_order_app = Blueprint('sale_order_app', __name__)

@sale_order_app.route('/create', methods=['POST'])
def create_sale_order():
    data = request.json
    if 'idCliente' not in data or 'idEmpleado' not in data or 'fecha' not in data or 'idProducto' not in data or 'cantidad' not in data:
        return jsonify({"error": "Todos los campos son requeridos"}), 400

    new_sale_order = SaleOrder(None,data['linea_orden'], data['idCliente'], data['idEmpleado'], data['fecha'], data['idProducto'], data['cantidad'])

    if sale_order_controller.create_sale_order(new_sale_order):
        return jsonify({"message": "Orden de venta creada exitosamente"}), 201
    else:
        return jsonify({"error": "Ocurrió un error al crear la orden de venta"}), 500
    
@sale_order_app.route('/get/<int:sale_order_id>', methods=['GET'])
def get_sale_order(sale_order_id):
    sale_order = sale_order_controller.get_sale_order(sale_order_id)
    if sale_order:
        return jsonify({"sale_order": sale_order.__dict__}), 200
    else:
        return jsonify({"error": "La orden de venta no existe"}), 404
    
@sale_order_app.route('/update/<int:sale_order_id>', methods=['PUT'])
def update_sale_order(sale_order_id):
    data = request.json
    if 'idCliente' not in data or 'idEmpleado' not in data or 'fecha' not in data or 'idProducto' not in data or 'cantidad' not in data:
        return jsonify({"error": "Todos los campos son requeridos"}), 400

    updated_sale_order = SaleOrder(sale_order_id, data['idCliente'], data['idEmpleado'], data['fecha'], data['idProducto'], data['cantidad'])

    if sale_order_controller.update_sale_order(sale_order_id, updated_sale_order):
        return jsonify({"message": "Orden de venta actualizada exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al actualizar la orden de venta"}), 500

@sale_order_app.route('/delete/<int:sale_order_id>', methods=['DELETE'])
def delete_sale_order(sale_order_id):
    if sale_order_controller.delete_sale_order(sale_order_id):
        return jsonify({"message": "Orden de venta eliminada exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al eliminar la orden de venta"}), 500

@sale_order_app.route('/massiveLoad', methods=['POST'])
def load_sale_orders_from_csv():
    try:
        file = request.files['file']
        if not file:
            return jsonify({"error": "No se ha enviado el archivo"}), 400
        if sale_order_controller.load_sale_orders_from_csv():
            return jsonify({"message": "Órdenes de venta cargadas exitosamente desde el archivo CSV"}), 200
        else:
            return jsonify({"error": "Ocurrió un error al cargar las órdenes de venta desde el archivo CSV"}), 500
    except Exception as e:
        print("Error loading sale orders from CSV:", e)
        return jsonify({"error": "Ocurrió un error al cargar las órdenes de venta"}), 500
