import csv
import io
from flask import Blueprint, request, jsonify
from controllers.employeeController import EmployeeController
from models.employee import Employee

# Creamos una instancia del controlador de empleados
employee_controller = EmployeeController()

# Creamos un Blueprint para las rutas relacionadas con los empleados
employee_app = Blueprint('employee_app', __name__)

# Ruta para crear un nuevo empleado
@employee_app.route('/create', methods=['POST'])
def create_employee():
    data = request.json
    if 'nombre' not in data or 'apellido' not in data or 'direccion' not in data or 'id_pais' not in data:
        return jsonify({"error": "Todos los campos son requeridos"}), 400

    # Creamos una instancia del empleado
    new_employee = Employee(None, data['nombre'], data['apellido'], data['direccion'], data['id_pais'])

    # Intentamos crear el empleado
    if employee_controller.create_employee(new_employee):
        return jsonify({"message": "Empleado creado exitosamente"}), 201
    else:
        return jsonify({"error": "Ocurrió un error al crear el empleado"}), 500

# Ruta para obtener un empleado por su ID
@employee_app.route('/get/<int:employee_id>', methods=['GET'])
def get_employee(employee_id):
    employee = employee_controller.get_employee(employee_id)
    if employee:
        return jsonify({"employee": employee.__dict__}), 200
    else:
        return jsonify({"error": "El empleado no existe"}), 404

# Ruta para actualizar un empleado por su ID
@employee_app.route('/update/<int:employee_id>', methods=['PUT'])
def update_employee(employee_id):
    data = request.json
    if 'nombre' not in data or 'apellido' not in data or 'direccion' not in data or 'id_pais' not in data:
        return jsonify({"error": "Todos los campos son requeridos"}), 400

    updated_employee = Employee(employee_id, data['nombre'], data['apellido'], data['direccion'], data['id_pais'])

    if employee_controller.update_employee(employee_id, updated_employee):
        return jsonify({"message": "Empleado actualizado exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al actualizar el empleado"}), 500

# Ruta para eliminar un empleado por su ID
@employee_app.route('/delete/<int:employee_id>', methods=['DELETE'])
def delete_employee(employee_id):
    if employee_controller.delete_employee(employee_id):
        return jsonify({"message": "Empleado eliminado exitosamente"}), 200
    else:
        return jsonify({"error": "Ocurrió un error al eliminar el empleado"}), 500
# Ruta para cargar empleados desde un archivo CSV
@employee_app.route('/massiveLoad', methods=['POST'])
def load_employees():
    try:
        if 'file' not in request.files:
            return jsonify({"error": "No se ha proporcionado un archivo CSV"}), 400
        
        if employee_controller.import_employees():
            return jsonify({"message": "Empleados cargados exitosamente desde el archivo CSV"}), 200
        else:
            return jsonify({"error": "Ocurrió un error al cargar los empleados desde el archivo CSV"}), 500
    except Exception as e:
        print("Error loading employees:", e)
        return jsonify({"error": "Ocurrió un error al cargar los empleados"}), 500
