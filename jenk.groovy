pipeline {
    agent any
    
    /*tools {
        // Configurar Python como herramienta (requiere Python Plugin en Jenkins)
        python 'Python3'
    }*/

    environment {
        IMAGE_NAME = "flask-app-local"
        K8S_NAMESPACE = "flask-app-dev"
        K8S_DEPLOYMENT = "flask-iot-app-dev"
        K8S_SERVICE_URL = "http://localhost:30500"
    }

    stages {

        stage('Unit Tests & Coverage') {
            steps {
                echo 'Instalando dependencias de testing...'
                // Instalar dependencias de Python para las pruebas
                bat "pip install -r requirements.txt"
                
                echo 'Ejecutando pruebas unitarias con coverage...'
                // Ejecutar pruebas con coverage y generar reporte usando python -m pytest
                bat "python -m pytest --cov=app --cov-report=html --cov-report=term-missing --cov-fail-under=50"
                
                echo 'Verificando coverage mínimo del 50%...'
                // El flag --cov-fail-under=50 ya hace que falle si es menor a 50%
                // Pero agregamos verificación adicional para logs más claros
                bat "python -m pytest --cov=app --cov-report=html --cov-report=term-missing --cov-fail-under=50"
                
                
                echo 'Pruebas unitarias y coverage verificados exitosamente!'  
            }
        }
        stage('Limpieza Kubernetes DEV') {
            steps {
                echo 'Limpiando despliegue anterior de Kubernetes DEV...'
                // Eliminar despliegue anterior si existe para evitar conflictos
                bat "kubectl delete -f k8s/dev/ --ignore-not-found=true || exit 0"
                
                echo 'Esperando a que los recursos se liberen...'
                bat "powershell -Command \"Start-Sleep 10\""
                
                echo 'Creando namespaces si no existen...'
                bat "kubectl apply -f k8s/namespaces.yaml || exit 0"
            }
        }

        stage('Construcción de Imagen') {
            steps {
                echo 'Iniciando Docker Build para Kubernetes...'
                // Construye la imagen usando el Dockerfile de tu carpeta raíz
                bat "docker build -t ${IMAGE_NAME} ."
                
                echo 'Etiquetando imagen para ambiente DEV...'
                // Etiquetar específicamente para DEV
                bat "docker tag ${IMAGE_NAME} ${IMAGE_NAME}:dev"
                
                echo 'Verificando imagen creada...'
                // Verificar usando PowerShell (más compatible con Jenkins)
                bat "powershell -Command \"docker images | Select-String '${IMAGE_NAME}'\""
            }
        }

        stage('Despliegue Kubernetes DEV') {
            steps {
                echo 'Verificando archivos de configuración Kubernetes...'
                // Verifica que existen los archivos de Kubernetes
                bat "if not exist k8s\\dev\\deployment.yaml (echo Error: Archivos K8s DEV no encontrados && exit 1)"
                
                echo 'Desplegando aplicación en Kubernetes DEV...'
                // Aplicar toda la configuración de DEV
                bat "kubectl apply -f k8s/dev/"
                
                echo 'Esperando a que el deployment esté listo...'
                // Esperar a que el deployment esté disponible
                bat "kubectl wait --for=condition=available --timeout=300s deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}"
                
                echo 'Verificando estado del despliegue...'
                bat "kubectl get pods -n ${K8S_NAMESPACE}"
                bat "kubectl get services -n ${K8S_NAMESPACE}"
                
                echo 'Aplicación desplegada correctamente en Kubernetes DEV - NodePort 30500'
            }
        }

        stage('Testing de Endpoints Kubernetes') {
            steps {
                echo 'Esperando a que la aplicación esté completamente lista en Kubernetes...'
                // Espera más tiempo para Kubernetes
                bat "powershell -Command \"Start-Sleep 30\"" 
                
                echo 'Verificando que el pod está corriendo...'
                bat "kubectl get pods -n ${K8S_NAMESPACE} -l app=flask-iot-app"
                
                echo 'Probando endpoints de IoT via Kubernetes NodePort (30500)...'
                
                // Test del endpoint principal usando PowerShell - NodePort 30500
                bat "powershell -Command \"try { Invoke-WebRequest -Uri '${K8S_SERVICE_URL}/' -UseBasicParsing -TimeoutSec 30 | Out-Null; Write-Host 'Endpoint principal OK' } catch { Write-Host 'Error: Endpoint principal falló'; exit 1 }\""
                
                // Test del endpoint de actuator
                bat "powershell -Command \"try { Invoke-WebRequest -Uri '${K8S_SERVICE_URL}/actuator' -UseBasicParsing -TimeoutSec 30 | Out-Null; Write-Host 'Endpoint actuator OK' } catch { Write-Host 'Error: Endpoint actuator falló'; exit 1 }\""
                
                // Test del endpoint de healthcheck
                bat "powershell -Command \"try { Invoke-WebRequest -Uri '${K8S_SERVICE_URL}/healthcheck' -UseBasicParsing -TimeoutSec 30 | Out-Null; Write-Host 'Endpoint healthcheck OK' } catch { Write-Host 'Error: Endpoint healthcheck falló'; exit 1 }\""
                
                // Test del endpoint de dispositivos IoT
                bat "powershell -Command \"try { Invoke-WebRequest -Uri '${K8S_SERVICE_URL}/api/devices' -UseBasicParsing -TimeoutSec 30 | Out-Null; Write-Host 'Endpoint IoT devices OK' } catch { Write-Host 'Error: Endpoint IoT devices falló'; exit 1 }\""
                
                // Test del resumen de dispositivos IoT 
                bat "powershell -Command \"try { Invoke-WebRequest -Uri '${K8S_SERVICE_URL}/api/devices/summary' -UseBasicParsing -TimeoutSec 30 | Out-Null; Write-Host 'Endpoint IoT summary OK' } catch { Write-Host 'Error: Endpoint IoT summary falló'; exit 1 }\""
                
                // Test de un dispositivo específico
                bat "powershell -Command \"try { Invoke-WebRequest -Uri '${K8S_SERVICE_URL}/api/devices/TEMP_001' -UseBasicParsing -TimeoutSec 30 | Out-Null; Write-Host 'Endpoint IoT device específico OK' } catch { Write-Host 'Error: Endpoint IoT device específico falló'; exit 1 }\""
                
                echo 'Mostrando logs del pod para verificación...'
                bat "kubectl logs -n ${K8S_NAMESPACE} -l app=flask-iot-app --tail=20"
                
                echo 'Todos los tests de endpoints de Kubernetes pasaron exitosamente!'
            }
        }
    }
}