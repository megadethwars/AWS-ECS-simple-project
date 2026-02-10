#!/bin/bash

# Script para construir y subir imagen Docker a AWS ECR para Fargate
# Configuración de variables
AWS_REGION="us-east-1"  # Cambia por tu región preferida
ECR_REPO_NAME="aws-ecs-simple-app"  # Cambia por el nombre que prefieras
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME"
IMAGE_TAG="latest"

echo "=== Construyendo y desplegando imagen Docker para Fargate ==="
echo "Repositorio ECR: $ECR_URI"
echo "Tag: $IMAGE_TAG"
echo ""

# 1. Crear repositorio ECR si no existe
echo "1. Creando repositorio ECR si no existe..."
aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION 2>/dev/null || \
aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION --image-scanning-configuration scanOnPush=true

# 2. Obtener token de login para ECR
echo "2. Obteniendo token de autenticación de ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# 3. Construir la imagen Docker
echo "3. Construyendo imagen Docker..."
docker build -t $ECR_REPO_NAME:$IMAGE_TAG .

# 4. Tagear la imagen para ECR
echo "4. Tageando imagen para ECR..."
docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

# 5. Subir la imagen a ECR
echo "5. Subiendo imagen a ECR..."
docker push $ECR_URI:$IMAGE_TAG

echo ""
echo "=== ¡Imagen subida exitosamente! ==="
echo "URI de la imagen: $ECR_URI:$IMAGE_TAG"
echo ""
echo "Puedes usar esta URI en tu definición de tarea de ECS/Fargate:"
echo "  Image: $ECR_URI:$IMAGE_TAG"
echo ""
echo "Comandos siguientes para ECS:"
echo "1. Crear definición de tarea ECS"
echo "2. Crear servicio ECS en Fargate"
echo "3. Configurar balanceador de carga (opcional)"