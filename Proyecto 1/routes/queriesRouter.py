from config import db

from controllers.queriesController import QueriesController
from flask import Blueprint, request, jsonify
queries_controller = QueriesController()

queries_app = Blueprint('queries_app', __name__)


from flask import jsonify

@queries_app.route('/<string:name>', methods=['GET'])
def query(name):
    try:
        if name not in queries_controller.queries:
            return jsonify({"error": "La consulta no existe"}), 404
        if name != "deleteTables" and name != "createTables" and name != "deleteData":
            
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute(queries_controller.queries[name]())
            query_result = cursor.fetchall()
            
            if query_result:
                result_json = []
                column_names = [column[0] for column in cursor.description]
                for row in query_result:
                    result_json.append(dict(zip(column_names, row))) 
                cursor.close()
                db.disconnectDB(conn)
                return jsonify({f"{name} result": result_json}), 200
            else:
                cursor.close()
                db.disconnectDB(conn)
                return jsonify({f"{name} result": "No hay resultados"}), 200
        else:
            conn = db.connectDB()
            cursor = conn.cursor()
            cursor.execute(queries_controller.queries[name]())
            conn.commit()
            cursor.close()
            db.disconnectDB(conn)
            return jsonify({f"{name} result": "Operación exitosa"}), 200
    except Exception as e:
        print(f"Error executing {name}:", e)
        return jsonify({"error": "Ocurrió un error al ejecutar la consulta"}), 500


    
   

