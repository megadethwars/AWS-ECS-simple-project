# Script de PowerShell para construir y subir imagen Docker a AWS ECR para Fargate

# Configuración de variables
$AWS_REGION = "us-east-1"  # Cambia por tu región preferida
$ECR_REPO_NAME = "aws-ecs-simple-app"  # Cambia por el nombre que prefieras
$AWS_ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
$ECR_URI = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME"
$IMAGE_TAG = "latest"

Write-Host "=== Construyendo y desplegando imagen Docker para Fargate ===" -ForegroundColor Green
Write-Host "Repositorio ECR: $ECR_URI" -ForegroundColor Cyan
Write-Host "Tag: $IMAGE_TAG" -ForegroundColor Cyan
Write-Host ""

# 1. Crear repositorio ECR si no existe  
Write-Host "1. Creando repositorio ECR si no existe..." -ForegroundColor Yellow
try {
    aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION | Out-Null
    Write-Host "   ✓ Repositorio ya existe" -ForegroundColor Green
} catch {
    Write-Host "   → Creando repositorio..." -ForegroundColor Blue
    aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION --image-scanning-configuration scanOnPush=true
}

# 2. Obtener token de login para ECR
Write-Host "2. Obteniendo token de autenticación de ECR..." -ForegroundColor Yellow
$loginCommand = aws ecr get-login-password --region $AWS_REGION
$loginCommand | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# 3. Construir la imagen Docker
Write-Host "3. Construyendo imagen Docker..." -ForegroundColor Yellow
docker build -t "${ECR_REPO_NAME}:${IMAGE_TAG}" .

# 4. Tagear la imagen para ECR
Write-Host "4. Tageando imagen para ECR..." -ForegroundColor Yellow
docker tag "${ECR_REPO_NAME}:${IMAGE_TAG}" "${ECR_URI}:${IMAGE_TAG}"

# 5. Subir la imagen a ECR
Write-Host "5. Subiendo imagen a ECR..." -ForegroundColor Yellow
docker push "${ECR_URI}:${IMAGE_TAG}"

Write-Host ""
Write-Host "=== ¡Imagen subida exitosamente! ===" -ForegroundColor Green
Write-Host "URI de la imagen: ${ECR_URI}:${IMAGE_TAG}" -ForegroundColor Cyan
Write-Host ""
Write-Host "Puedes usar esta URI en tu definición de tarea de ECS/Fargate:"
Write-Host "  Image: ${ECR_URI}:${IMAGE_TAG}" -ForegroundColor White
Write-Host ""
Write-Host "Comandos siguientes para ECS:" -ForegroundColor Yellow
Write-Host "1. Crear definición de tarea ECS"
Write-Host "2. Crear servicio ECS en Fargate" 
Write-Host "3. Configurar balanceador de carga (opcional)"