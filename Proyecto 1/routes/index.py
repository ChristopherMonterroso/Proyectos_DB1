from flask import Flask
from .productRouter import product_app 
from .categoryRouter import category_app
from .countryRouter import country_app
from .employeeRouter import employee_app
from .customerRouter import customer_app
from .saleOrderRouter import sale_order_app
from .queriesRouter import queries_app
app = Flask(__name__)

app.register_blueprint(category_app, url_prefix='/api/categories')
app.register_blueprint(product_app, url_prefix='/api/products')
app.register_blueprint(country_app, url_prefix='/api/countries')
app.register_blueprint(employee_app, url_prefix='/api/employees')
app.register_blueprint(customer_app, url_prefix='/api/customers')
app.register_blueprint(sale_order_app, url_prefix='/api/saleOrders')
app.register_blueprint(queries_app, url_prefix='/api/queries')

@app.route('/')
def index():
    return "running"

if __name__ == '__main__':
    app.run(debug=True)
