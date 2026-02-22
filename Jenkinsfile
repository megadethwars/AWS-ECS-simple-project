pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-app-local"
        CONTAINER_NAME = "contenedor-flask-jenkins"
    }

    stages {
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
                bat "timeout /t 10 /nobreak"
                
                echo 'Probando endpoints de IoT...'
                
                // Test del endpoint principal
                bat "curl -f http://localhost:5000/ || (echo Error: Endpoint principal falló && exit 1)"
                
                // Test del endpoint de actuator
                bat "curl -f http://localhost:5000/actuator || (echo Error: Endpoint actuator falló && exit 1)"
                
                // Test del endpoint de healthcheck
                bat "curl -f http://localhost:5000/healthcheck || (echo Error: Endpoint healthcheck falló && exit 1)"
                
                // Test del endpoint de dispositivos IoT
                bat "curl -f http://localhost:5000/api/devices || (echo Error: Endpoint IoT devices falló && exit 1)"
                
                // Test del resumen de dispositivos IoT 
                bat "curl -f http://localhost:5000/api/devices/summary || (echo Error: Endpoint IoT summary falló && exit 1)"
                
                // Test de un dispositivo específico
                bat "curl -f http://localhost:5000/api/devices/TEMP_001 || (echo Error: Endpoint IoT device específico falló && exit 1)"
                
                echo 'Todos los tests de endpoints pasaron exitosamente!'
            }
        }
    }
}