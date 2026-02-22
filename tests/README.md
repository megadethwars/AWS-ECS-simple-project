# Pruebas Unitarias e Integración - IoT Devices API

Este directorio contiene las pruebas unitarias y de integración para la API de dispositivos IoT.

## Resultados Actuales

- **✅ 27/27 pruebas pasando** 
  - **🎯 13 pruebas unitarias**
  - **🔗 14 pruebas de integración**
- **Cobertura total: 76%**
- **Cobertura `iot_devices.py`: 57%** (`generate_devices` y `get_devices` completamente cubiertos)

## Estructura de Pruebas

```
tests/
├── __init__.py               # Paquete de pruebas
├── conftest.py              # Configuración de pytest y fixtures
├── test_iot_devices.py      # 🔗 Pruebas de INTEGRACIÓN - endpoints HTTP
├── test_iot_devices_unit.py # 🎯 Pruebas UNITARIAS - funciones aisladas
└── README.md               # Este archivo
```

## Tipos de Pruebas

### 🎯 Pruebas Unitarias (`test_iot_devices_unit.py`)
- **Qué prueban**: Funciones individuales aisladas (`generate_devices()`)
- **Características**: Rápidas, deterministas, mockean dependencias externas
- **Sin dependencias**: No usan HTTP, Flask o recursos externos
- **Enfoque**: Lógica de negocio pura

### 🔗 Pruebas de Integración (`test_iot_devices.py`) 
- **Qué prueban**: Endpoints HTTP completos (`/api/devices`)
- **Características**: Usan Flask test client, ejecutan stack completo
- **Con dependencias**: HTTP requests, aplicación Flask real
- **Enfoque**: Comportamiento end-to-end

## Configuración

### Instalar dependencias de pruebas
```bash
pip install -r requirements.txt
```

### Ejecutar las pruebas

#### Ejecutar todas las pruebas
```bash
pytest
```

#### Ejecutar solo pruebas de integración (endpoints)
```bash
pytest tests/test_iot_devices.py
```

#### Ejecutar solo pruebas unitarias (funciones)
```bash
pytest tests/test_iot_devices_unit.py
```

#### Ejecutar con reporte de cobertura
```bash
pytest --cov=app --cov-report=html
```

#### Ejecutar en modo verbose
```bash
pytest -v
```

#### Ejecutar pruebas específicas
```bash
# Ejecutar una clase de pruebas específica
pytest tests/test_iot_devices.py::TestGetDevicesEndpoint

# Ejecutar una prueba específica de integración
pytest tests/test_iot_devices.py::TestGetDevicesEndpoint::test_get_devices_status_code

# Ejecutar una prueba específica unitaria
pytest tests/test_iot_devices_unit.py::TestGenerateDevicesUnit::test_generate_devices_returns_six_devices
```

#### Ejecutar por tipo de prueba
```bash
# Solo pruebas rápidas (unitarias)
pytest tests/test_iot_devices_unit.py

# Solo pruebas de integración 
pytest tests/test_iot_devices.py

# Ejecutar con marcadores (si se configuran)
pytest -m unit    # Solo unitarias
pytest -m integration  # Solo integración
```

## Pruebas Implementadas

### 🎯 Pruebas Unitarias - TestGenerateDevicesUnit (13 pruebas)

Pruebas para la función `generate_devices()` de forma aislada:

1. **test_generate_devices_returns_six_devices**: Retorna exactamente 6 dispositivos
2. **test_generate_devices_device_structure**: Estructura correcta por dispositivo
3. **test_generate_devices_deterministic_temperature**: Usa temperatura mockeada
4. **test_generate_devices_timestamp_usage**: Usa timestamp mockeado
5. **test_generate_devices_fixed_device_ids**: IDs predecibles (TEMP_001-006)
6. **test_generate_devices_fixed_device_names**: Nombres fijos y correctos
7. **test_generate_devices_temperature_rounding**: Redondeo a 2 decimales
8. **test_generate_devices_celsius_unit**: Unidad siempre °C
9. **test_generate_devices_status_online_when_random_high**: Status online cuando random >= 0.1
10. **test_generate_devices_status_offline_when_random_low**: Status offline cuando random < 0.1
11. **test_generate_devices_data_types**: Tipos de datos correctos
12. **test_generate_devices_no_external_dependencies**: Importación sin errores
13. **test_generate_devices_multiple_calls_use_mocks**: Consistencia con mocks

### 🔗 Pruebas de Integración - TestGetDevicesEndpoint (14 pruebas)

Pruebas para el endpoint completo `GET /api/devices`:

1. **test_get_devices_status_code**: Verifica que responde con status 200
2. **test_get_devices_content_type**: Verifica el Content-Type JSON
3. **test_get_devices_response_structure**: Verifica la estructura de la respuesta
4. **test_get_devices_data_types**: Verifica tipos de datos correctos
5. **test_get_devices_timestamp_format**: Verifica formato ISO del timestamp
6. **test_get_devices_list_not_empty**: Verifica que hay dispositivos
7. **test_get_devices_device_structure**: Verifica estructura de cada dispositivo
8. **test_get_devices_device_data_types**: Verifica tipos de datos de dispositivos
9. **test_get_devices_temperature_range**: Verifica rangos de temperatura razonables
10. **test_get_devices_status_values**: Verifica valores válidos de status
11. **test_get_devices_unit_celsius**: Verifica unidad de temperatura
12. **test_get_devices_id_format**: Verifica formato de IDs
13. **test_get_devices_multiple_calls_consistency**: Verifica consistencia entre llamadas
14. **test_get_devices_expected_count**: Verifica cantidad esperada de dispositivos

## Fixtures Disponibles

- `app`: Instancia de la aplicación Flask configurada para testing
- `client`: Cliente de pruebas para hacer requests HTTP
- `runner`: Runner para comandos CLI de Flask

## Próximos pasos

Para extender la suite de pruebas, considera agregar:

1. **Pruebas unitarias para otras funciones** del módulo iot_devices
2. **Pruebas para otros endpoints** (`/api/devices/<device_id>`, `/api/devices/summary`)
3. **Pruebas de manejo de errores** (404, 500, validación, etc.)
4. **Pruebas de rendimiento** y carga
5. **Pruebas de seguridad** y validación de entrada
6. **Mocking de servicios externos** si se agregan
7. **Pruebas de configuración** para diferentes entornos

## Estructura de datos esperada

### Respuesta de /api/devices
```json
{
  "total_devices": 6,
  "timestamp": "2026-02-22T...",
  "devices": [
    {
      "id": "TEMP_001",
      "name": "Sensor Sala Principal", 
      "temperature": 23.45,
      "unit": "°C",
      "status": "online",
      "last_update": "2026-02-22T..."
    }
  ]
}
```