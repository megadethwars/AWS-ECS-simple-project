from flask import Flask
import os
from config import get_config

# Importar blueprints desde views
from views.home import home_bp
from views.actuator import actuator_bp

# Puedes pasar el ambiente como argumento aquí:
env = os.environ.get("APP_ENV", "local")
ConfigClass = get_config(env)

print(ConfigClass.MENSAJE)

app = Flask(__name__)

# Registrar blueprints
app.register_blueprint(home_bp)
app.register_blueprint(actuator_bp)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
