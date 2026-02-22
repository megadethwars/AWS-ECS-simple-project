from flask import Blueprint, jsonify
import random
from datetime import datetime

iot_devices_bp = Blueprint('iot_devices', __name__)

# Lista de dispositivos IoT ficticios
def generate_devices():
    """Genera una lista de 6 dispositivos IoT con temperaturas aleatorias"""
    devices = [
        {
            "id": "TEMP_001",
            "name": "Sensor Sala Principal",
            "temperature": round(random.uniform(18.0, 28.0), 2),
            "unit": "°C",
            "status": "online",
            "last_update": datetime.now().isoformat()
        },
        {
            "id": "TEMP_002", 
            "name": "Sensor Cocina",
            "temperature": round(random.uniform(20.0, 35.0), 2),
            "unit": "°C",
            "status": "online",
            "last_update": datetime.now().isoformat()
        },
        {
            "id": "TEMP_003",
            "name": "Sensor Dormitorio",
            "temperature": round(random.uniform(16.0, 24.0), 2),
            "unit": "°C", 
            "status": "online",
            "last_update": datetime.now().isoformat()
        },
        {
            "id": "TEMP_004",
            "name": "Sensor Baño",
            "temperature": round(random.uniform(22.0, 30.0), 2),
            "unit": "°C",
            "status": "online",
            "last_update": datetime.now().isoformat()
        },
        {
            "id": "TEMP_005",
            "name": "Sensor Exterior",
            "temperature": round(random.uniform(5.0, 40.0), 2),
            "unit": "°C",
            "status": "online",
            "last_update": datetime.now().isoformat()
        },
        {
            "id": "TEMP_006",
            "name": "Sensor Garaje",
            "temperature": round(random.uniform(10.0, 25.0), 2),
            "unit": "°C",
            "status": "offline" if random.random() < 0.1 else "online",
            "last_update": datetime.now().isoformat()
        }
    ]
    return devices

@iot_devices_bp.route('/api/devices')
def get_devices():
    """Endpoint GET que obtiene la lista de dispositivos IoT"""
    devices = generate_devices()
    
    response_data = {
        "total_devices": len(devices),
        "timestamp": datetime.now().isoformat(),
        "devices": devices
    }
    
    return jsonify(response_data)

@iot_devices_bp.route('/api/devices/<device_id>')
def get_device_by_id(device_id):
    """Endpoint GET que obtiene un dispositivo específico por ID"""
    devices = generate_devices()
    device = next((d for d in devices if d["id"] == device_id), None)
    
    if device:
        return jsonify(device)
    else:
        return jsonify({"error": "Device not found", "device_id": device_id}), 404

@iot_devices_bp.route('/api/devices/summary')
def get_devices_summary():
    """Endpoint GET que obtiene un resumen de los dispositivos"""
    devices = generate_devices()
    online_devices = [d for d in devices if d["status"] == "online"]
    offline_devices = [d for d in devices if d["status"] == "offline"]
    
    temperatures = [d["temperature"] for d in online_devices]
    avg_temp = round(sum(temperatures) / len(temperatures), 2) if temperatures else 0
    
    summary = {
        "total_devices": len(devices),
        "online_devices": len(online_devices),
        "offline_devices": len(offline_devices),
        "average_temperature": avg_temp,
        "min_temperature": min(temperatures) if temperatures else None,
        "max_temperature": max(temperatures) if temperatures else None,
        "timestamp": datetime.now().isoformat()
    }
    
    return jsonify(summary)