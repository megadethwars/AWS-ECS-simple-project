from flask import Blueprint, jsonify
from datetime import datetime
import os

actuator_bp = Blueprint('actuator', __name__)

@actuator_bp.route('/actuator')
def actuator():
    """Endpoint de actuator para verificar el estado de la aplicación"""
    return "actuator 1.8"

@actuator_bp.route('/healthcheck')
def healthcheck():
    """Endpoint de healthcheck para verificar que la aplicación está funcionando"""
    health_data = {
        'status': 'UP',
        'timestamp': datetime.now().isoformat(),
        'environment': os.environ.get('APP_ENV', 'local'),
        'version': '1.7'
    }
    return jsonify(health_data)

@actuator_bp.route('/actuator/health')
def actuator_health():
    """Endpoint alternativo de health siguiendo convención de Spring Boot"""
    return jsonify({
        'status': 'UP',
        'components': {
            'app': {
                'status': 'UP',
                'details': {
                    'environment': os.environ.get('APP_ENV', 'local')
                }
            }
        }
    })