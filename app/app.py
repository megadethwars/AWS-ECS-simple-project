from flask import Flask
import os
from config import get_config

# Puedes pasar el ambiente como argumento aquí:
env = os.environ.get("APP_ENV", "local")
ConfigClass = get_config(env)

print(ConfigClass.MENSAJE)

app = Flask(__name__)

@app.route('/')
def home():
    return str(ConfigClass.MENSAJE)

@app.route('/actuator')
def actuator():
    return "actuator 1.7"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
