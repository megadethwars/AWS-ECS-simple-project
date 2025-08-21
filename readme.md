# Despliegue de imagen Docker en AWS ECR para ECS

## Comandos para subir imagen Docker a repositorio ECR de AWS

### 1. Construir la imagen

```bash
docker build -t flask-app1 .

2. Probar la imagen localmente

docker run -p 5000:5000 flask-app1

3. Autenticarse en ECR

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 282293003762.dkr.ecr.us-east-1.amazonaws.com

4. Etiquetar la imagen para ECR

docker tag flask-app1:latest 282293003762.dkr.ecr.us-east-1.amazonaws.com/flask_simple_app_repository:latest

5. Subir la imagen a ECR

docker push 282293003762.dkr.ecr.us-east-1.amazonaws.com/flask_simple_app_repository:latest