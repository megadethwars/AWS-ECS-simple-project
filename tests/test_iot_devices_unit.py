import pytest
from unittest.mock import patch, MagicMock
from datetime import datetime
import sys
import os

# Agregar el directorio app al path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
app_dir = os.path.join(project_root, 'app')
sys.path.insert(0, app_dir)

from views.iot_devices import generate_devices


class TestGenerateDevicesUnit:
    """Pruebas unitarias para la función generate_devices()"""
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_returns_six_devices(self, mock_datetime, mock_random):
        """Test unitario: generate_devices() debe retornar exactamente 6 dispositivos"""
        # Arrange - Mock determinista
        mock_random.return_value = 25.5
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        
        # Act
        devices = generate_devices()
        
        # Assert
        assert len(devices) == 6
        assert isinstance(devices, list)
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_device_structure(self, mock_datetime, mock_random):
        """Test unitario: cada dispositivo debe tener la estructura correcta"""
        # Arrange
        mock_random.return_value = 23.7
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        
        # Act
        devices = generate_devices()
        
        # Assert
        expected_keys = {'id', 'name', 'temperature', 'unit', 'status', 'last_update'}
        for device in devices:
            assert set(device.keys()) == expected_keys
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_deterministic_temperature(self, mock_datetime, mock_random):
        """Test unitario: temperatura debe usar el valor mockeado"""
        # Arrange
        expected_temp = 27.3
        mock_random.return_value = expected_temp
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        
        # Act
        devices = generate_devices()
        
        # Assert
        for device in devices:
            # Verificar que la temperatura fue redondeada a 2 decimales
            assert device['temperature'] == round(expected_temp, 2)
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_timestamp_usage(self, mock_datetime, mock_random):
        """Test unitario: debe usar el timestamp mockeado"""
        # Arrange
        expected_timestamp = "2026-02-22T15:30:45"
        mock_random.return_value = 20.0
        mock_datetime_instance = MagicMock()
        mock_datetime_instance.isoformat.return_value = expected_timestamp
        mock_datetime.now.return_value = mock_datetime_instance
        
        # Act
        devices = generate_devices()
        
        # Assert
        for device in devices:
            assert device['last_update'] == expected_timestamp
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_fixed_device_ids(self, mock_datetime, mock_random):
        """Test unitario: IDs de dispositivos deben ser fijos y predecibles"""
        # Arrange
        mock_random.return_value = 22.0
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        
        # Act
        devices = generate_devices()
        
        # Assert
        expected_ids = ["TEMP_001", "TEMP_002", "TEMP_003", "TEMP_004", "TEMP_005", "TEMP_006"]
        actual_ids = [device['id'] for device in devices]
        assert actual_ids == expected_ids
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_fixed_device_names(self, mock_datetime, mock_random):
        """Test unitario: nombres de dispositivos deben ser fijos y predecibles"""
        # Arrange
        mock_random.return_value = 22.0
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        
        # Act
        devices = generate_devices()
        
        # Assert
        expected_names = [
            "Sensor Sala Principal",
            "Sensor Cocina", 
            "Sensor Dormitorio",
            "Sensor Baño",
            "Sensor Exterior",
            "Sensor Garaje"
        ]
        actual_names = [device['name'] for device in devices]
        assert actual_names == expected_names
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_temperature_rounding(self, mock_datetime, mock_random):
        """Test unitario: temperatura debe redondearse a 2 decimales"""
        # Arrange
        mock_random.return_value = 25.12345  # Muchos decimales
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        
        # Act
        devices = generate_devices()
        
        # Assert
        for device in devices:
            temp = device['temperature']
            # Verificar que tiene máximo 2 decimales
            assert len(str(temp).split('.')[-1]) <= 2
            assert temp == 25.12  # Valor redondeado esperado
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_celsius_unit(self, mock_datetime, mock_random):
        """Test unitario: unidad debe ser siempre °C"""
        # Arrange
        mock_random.return_value = 20.0
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        
        # Act
        devices = generate_devices()
        
        # Assert
        for device in devices:
            assert device['unit'] == '°C'
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime') 
    @patch('views.iot_devices.random.random')
    def test_generate_devices_status_online_when_random_high(self, mock_random_status, mock_datetime, mock_temp):
        """Test unitario: status debe ser 'online' cuando random() >= 0.1"""
        # Arrange
        mock_temp.return_value = 20.0
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        mock_random_status.return_value = 0.5  # >= 0.1, debería ser online
        
        # Act
        devices = generate_devices()
        
        # Assert
        # Los primeros 5 dispositivos siempre online
        for i in range(5):
            assert devices[i]['status'] == 'online'
        
        # El último dispositivo debería ser online porque random() = 0.5 >= 0.1
        assert devices[5]['status'] == 'online'
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    @patch('views.iot_devices.random.random')
    def test_generate_devices_status_offline_when_random_low(self, mock_random_status, mock_datetime, mock_temp):
        """Test unitario: status debe ser 'offline' cuando random() < 0.1"""
        # Arrange
        mock_temp.return_value = 20.0
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        mock_random_status.return_value = 0.05  # < 0.1, debería ser offline
        
        # Act
        devices = generate_devices()
        
        # Assert
        # Los primeros 5 dispositivos siempre online
        for i in range(5):
            assert devices[i]['status'] == 'online'
        
        # El último dispositivo debería ser offline porque random() = 0.05 < 0.1
        assert devices[5]['status'] == 'offline'
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_data_types(self, mock_datetime, mock_random):
        """Test unitario: tipos de datos correctos para cada campo"""
        # Arrange
        mock_random.return_value = 25.5
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T10:00:00"
        
        # Act
        devices = generate_devices()
        
        # Assert
        for device in devices:
            assert isinstance(device['id'], str)
            assert isinstance(device['name'], str)
            assert isinstance(device['temperature'], (int, float))
            assert isinstance(device['unit'], str)
            assert isinstance(device['status'], str)
            assert isinstance(device['last_update'], str)
    
    def test_generate_devices_no_external_dependencies(self):
        """Test unitario: función debe ser importable sin dependencias externas"""
        # Act & Assert - simplemente importar la función sin errores
        from views.iot_devices import generate_devices
        assert callable(generate_devices)
    
    @patch('views.iot_devices.random.uniform')
    @patch('views.iot_devices.datetime')
    def test_generate_devices_multiple_calls_use_mocks(self, mock_datetime, mock_random):
        """Test unitario: múltiples llamadas deben usar consistentemente los mocks"""
        # Arrange
        mock_random.return_value = 30.0
        mock_datetime.now.return_value.isoformat.return_value = "2026-02-22T12:00:00"
        
        # Act - llamar múltiples veces
        devices1 = generate_devices()
        devices2 = generate_devices()
        
        # Assert - resultados deben ser idénticos debido a mocking
        assert len(devices1) == len(devices2) == 6
        for i in range(6):
            assert devices1[i]['temperature'] == devices2[i]['temperature'] == 30.0
            assert devices1[i]['last_update'] == devices2[i]['last_update'] == "2026-02-22T12:00:00"