from flask import Blueprint
from config import get_config
import os

home_bp = Blueprint('home', __name__)

@home_bp.route('/')
def home():
    """Endpoint principal que muestra el mensaje de configuración"""
    env = os.environ.get("APP_ENV", "local")
    ConfigClass = get_config(env)
    return str(ConfigClass.MENSAJE)