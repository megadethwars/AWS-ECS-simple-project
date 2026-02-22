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
                echo 'Lanzando la aplicación en http://localhost:5000'
                // Corre el contenedor en segundo plano (-d) mapeando el puerto 5000
                bat "docker run -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE_NAME}"
            }
        }
    }
}