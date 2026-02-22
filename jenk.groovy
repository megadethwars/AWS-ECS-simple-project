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
    }
}