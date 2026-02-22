import pytest
import json
from datetime import datetime


class TestGetDevicesEndpoint:
    """Test class for /api/devices GET endpoint"""
    
    def test_get_devices_status_code(self, client):
        """Test que el endpoint responde con status 200"""
        response = client.get('/api/devices')
        assert response.status_code == 200
    
    def test_get_devices_content_type(self, client):
        """Test que el endpoint responde con Content-Type JSON"""
        response = client.get('/api/devices')
        assert response.content_type == 'application/json'
    
    def test_get_devices_response_structure(self, client):
        """Test que la respuesta tiene la estructura esperada"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        # Verificar que las claves principales existen
        assert 'total_devices' in data
        assert 'timestamp' in data
        assert 'devices' in data
    
    def test_get_devices_data_types(self, client):
        """Test que los tipos de datos de la respuesta son correctos"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        # Verificar tipos de datos de la respuesta principal
        assert isinstance(data['total_devices'], int)
        assert isinstance(data['timestamp'], str)
        assert isinstance(data['devices'], list)
        
        # Verificar que total_devices coincide con la longitud de devices
        assert data['total_devices'] == len(data['devices'])
    
    def test_get_devices_timestamp_format(self, client):
        """Test que el timestamp tiene formato ISO válido"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        # Verificar que el timestamp se puede parsear como datetime ISO
        try:
            datetime.fromisoformat(data['timestamp'])
        except ValueError:
            pytest.fail("El timestamp no tiene formato ISO válido")
    
    def test_get_devices_list_not_empty(self, client):
        """Test que la lista de dispositivos no está vacía"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        assert len(data['devices']) > 0
    
    def test_get_devices_device_structure(self, client):
        """Test que cada dispositivo tiene la estructura correcta"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        expected_keys = {'id', 'name', 'temperature', 'unit', 'status', 'last_update'}
        
        for device in data['devices']:
            # Verificar que el dispositivo tiene todas las claves esperadas
            assert set(device.keys()) == expected_keys
    
    def test_get_devices_device_data_types(self, client):
        """Test que los tipos de datos de cada dispositivo son correctos"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        for device in data['devices']:
            assert isinstance(device['id'], str)
            assert isinstance(device['name'], str)
            assert isinstance(device['temperature'], (int, float))
            assert isinstance(device['unit'], str)
            assert isinstance(device['status'], str)
            assert isinstance(device['last_update'], str)
    
    def test_get_devices_temperature_range(self, client):
        """Test que las temperaturas están en rangos razonables"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        for device in data['devices']:
            # Verificar que la temperatura está en un rango razonable (-50 a 60°C)
            assert -50 <= device['temperature'] <= 60
    
    def test_get_devices_status_values(self, client):
        """Test que el status de los dispositivos tiene valores válidos"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        valid_statuses = {'online', 'offline'}
        
        for device in data['devices']:
            assert device['status'] in valid_statuses
    
    def test_get_devices_unit_celsius(self, client):
        """Test que la unidad de temperatura es Celsius"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        for device in data['devices']:
            assert device['unit'] == '°C'
    
    def test_get_devices_id_format(self, client):
        """Test que los IDs de dispositivos tienen formato esperado"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        for device in data['devices']:
            # Verificar que el ID no está vacío y empieza con 'TEMP_'
            assert device['id']
            assert device['id'].startswith('TEMP_')
    
    def test_get_devices_multiple_calls_consistency(self, client):
        """Test que múltiples llamadas al endpoint mantienen la estructura consistente"""
        # Hacer 3 llamadas al endpoint
        responses = [client.get('/api/devices') for _ in range(3)]
        
        for response in responses:
            assert response.status_code == 200
            data = response.get_json()
            
            # Verificar estructura consistente
            assert 'total_devices' in data
            assert 'timestamp' in data  
            assert 'devices' in data
            assert len(data['devices']) == data['total_devices']
    
    def test_get_devices_expected_count(self, client):
        """Test que se retornan exactamente 6 dispositivos como se espera"""
        response = client.get('/api/devices')
        data = response.get_json()
        
        # Según el código, se generan 6 dispositivos
        assert data['total_devices'] == 6
        assert len(data['devices']) == 6