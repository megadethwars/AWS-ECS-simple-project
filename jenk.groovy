pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-app-local"
        CONTAINER_NAME = "contenedor-flask-jenkins"
    }

    stages {
        stage('Unit Tests & Coverage') {
            steps {
                echo 'Instalando dependencias de testing...'
                // Instalar dependencias de Python para las pruebas
                bat "python -m pip install -r requirements.txt"
                
                echo 'Ejecutando pruebas unitarias con coverage...'
                // Ejecutar pruebas con coverage y generar reporte usando python -m pytest
                bat "python -m pytest --cov=app --cov-report=html --cov-report=term-missing --cov-fail-under=50"
                
                echo 'Verificando coverage mínimo del 50%...'
                // El flag --cov-fail-under=50 ya hace que falle si es menor a 50%
                // Pero agregamos verificación adicional para logs más claros
                bat """
                    powershell -Command "
                    \$coverage = (python -m pytest --cov=app --cov-report=term | Select-String 'TOTAL.*([0-9]+)%' | ForEach-Object { \$_.Matches.Groups[1].Value });
                    if ([int]\$coverage -lt 50) { 
                        Write-Host 'ERROR: Coverage (\$coverage%) es menor al 50% requerido'; 
                        exit 1 
                    } else { 
                        Write-Host 'SUCCESS: Coverage (\$coverage%) cumple el requisito mínimo del 50%' 
                    }
                    "
                """
                
                echo 'Pruebas unitarias y coverage verificados exitosamente!'  
            }
        }

        stage('Limpieza de Contenedores') {
            steps {
                echo 'Buscando y deteniendo versiones anteriores...'
                // Detiene y elimina el contenedor si ya existe para evitar errores de nombre duplicado
                bat "docker stop ${CONTAINER_NAME} 2>nul || exit 0"
                bat "docker rm ${CONTAINER_NAME} 2>nul || exit 0"
            }
        }

        stage('Construcción de Imagen') {
            steps {
                echo 'Iniciando Docker Build...'
                // Construye la imagen usando el Dockerfile de tu carpeta raíz
                bat "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Despliegue Local') {
            steps {
                echo 'Verificando archivo de configuración...'
                // Verifica que existe el archivo .env.docker
                bat "if not exist .env.docker (echo Error: .env.docker no encontrado && exit 1)"
                
                echo 'Lanzando la aplicación en http://localhost:5000 con ambiente DEV'
                // Corre el contenedor usando el archivo .env.docker para variables de entorno
                bat "docker run -d --name ${CONTAINER_NAME} -p 5000:5000 --env-file .env.docker ${IMAGE_NAME}"
                
                echo 'Aplicación desplegada correctamente con configuración DEV'
            }
        }

        stage('Testing de Endpoints') {
            steps {
                echo 'Esperando a que la aplicación esté lista...'
                // Espera 10 segundos para que el contenedor esté completamente iniciado
                bat "powershell -Command \"Start-Sleep 10\"" 
                
                echo 'Probando endpoints de IoT...'
                
                // Test del endpoint principal usando PowerShell
                bat "powershell -Command \"try { Invoke-WebRequest -Uri 'http://localhost:5000/' -UseBasicParsing | Out-Null; Write-Host 'Endpoint principal OK' } catch { Write-Host 'Error: Endpoint principal falló'; exit 1 }\""
                
                // Test del endpoint de actuator
                bat "powershell -Command \"try { Invoke-WebRequest -Uri 'http://localhost:5000/actuator' -UseBasicParsing | Out-Null; Write-Host 'Endpoint actuator OK' } catch { Write-Host 'Error: Endpoint actuator falló'; exit 1 }\""
                
                // Test del endpoint de healthcheck
                bat "powershell -Command \"try { Invoke-WebRequest -Uri 'http://localhost:5000/healthcheck' -UseBasicParsing | Out-Null; Write-Host 'Endpoint healthcheck OK' } catch { Write-Host 'Error: Endpoint healthcheck falló'; exit 1 }\""
                
                // Test del endpoint de dispositivos IoT
                bat "powershell -Command \"try { Invoke-WebRequest -Uri 'http://localhost:5000/api/devices' -UseBasicParsing | Out-Null; Write-Host 'Endpoint IoT devices OK' } catch { Write-Host 'Error: Endpoint IoT devices falló'; exit 1 }\""
                
                // Test del resumen de dispositivos IoT 
                bat "powershell -Command \"try { Invoke-WebRequest -Uri 'http://localhost:5000/api/devices/summary' -UseBasicParsing | Out-Null; Write-Host 'Endpoint IoT summary OK' } catch { Write-Host 'Error: Endpoint IoT summary falló'; exit 1 }\""
                
                // Test de un dispositivo específico
                bat "powershell -Command \"try { Invoke-WebRequest -Uri 'http://localhost:5000/api/devices/TEMP_001' -UseBasicParsing | Out-Null; Write-Host 'Endpoint IoT device específico OK' } catch { Write-Host 'Error: Endpoint IoT device específico falló'; exit 1 }\""
                
                echo 'Todos los tests de endpoints pasaron exitosamente!'
            }
        }
    }
}