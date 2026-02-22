# Guía de Despliegue en AWS Fargate

Esta guía te ayudará a desplegar tu aplicación Flask en AWS Fargate paso a paso.

## Requisitos Previos

IAM de cloudformation:

AdministratorAccess
Administrada por AWS: función de trabajo

AWSCloudFormationFullAccess
Administrada por AWS

AWSCloudFormationReadOnlyAccess
Administrada por AWS

AWSCodeDeployRoleForCloudFormation
Administrada por AWS


1. **AWS CLI configurado** con credenciales apropiadas
   ```bash
   aws configure
   ```

2. **Docker Desktop** instalado y corriendo

3. **Permisos de IAM** necesarios:
   - ECR (Elastic Container Registry) - para subir imágenes
   - ECS (Elastic Container Service) - para crear tareas y servicios  
   - IAM - para crear roles de ejecución

## Pasos para Desplegar

### 1. Construir y Subir la Imagen Docker

**Opción A: Usando PowerShell (Windows)**
```powershell
.\build-and-push.ps1
```

**Opción B: Manualmente**
```powershell
# Configurar variables
$AWS_REGION = "us-east-1"
$ECR_REPO_NAME = "aws-ecs-simple-app" 
$AWS_ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)

# Crear repositorio ECR
aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION

# Autenticarse con ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Construir y subir imagen
docker build -t "${ECR_REPO_NAME}:latest" .
docker tag "${ECR_REPO_NAME}:latest" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest"
docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:latest"
```

# para probar
docker run -p 5000:5000 "${ECR_REPO_NAME}" -- 

### 2. Crear Roles de IAM Necesarios

**Rol de Ejecución de Tareas (ecsTaskExecutionRole)**
```bash
# Si no existe, crear el rol
aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}'

# Adjuntar política
aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

### 3. Crear CloudWatch Log Group

```bash
aws logs create-log-group --log-group-name /ecs/aws-ecs-simple-app --region us-east-1
```

### 4. Crear Cluster ECS

```bash
aws ecs create-cluster --cluster-name aws-ecs-simple-cluster --capacity-providers FARGATE --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1
```

### 5. Registrar Definición de Tarea

1. Editar `ecs-task-definition.json`:
   - Reemplaza `YOUR_ACCOUNT_ID` con tu ID de cuenta AWS
   - Reemplaza `YOUR_REGION` con tu región (ej: us-east-1)

2. Registrar la tarea:
   ```bash
   aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json
   ```

### 6. Crear Servicio ECS

**Opción A: Sin Load Balancer (red pública)**
```bash
aws ecs create-service \
  --cluster aws-ecs-simple-cluster \
  --service-name aws-ecs-simple-service \
  --task-definition aws-ecs-simple-app-task:1 \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxxxxx],securityGroups=[sg-xxxxxxxx],assignPublicIp=ENABLED}"
```

**Opción B: Con Application Load Balancer**
```bash
# Primero crear ALB y Target Group, luego:
aws ecs create-service \
  --cluster aws-ecs-simple-cluster \
  --service-name aws-ecs-simple-service \
  --task-definition aws-ecs-simple-app-task:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxxxxx,subnet-yyyyyyyy],securityGroups=[sg-xxxxxxxx],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:region:account:targetgroup/name,containerName=aws-ecs-simple-app,containerPort=5000"
```

### 7. Configurar Security Group

Permitir tráfico HTTP en puerto 5000:
```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxx \
  --protocol tcp \
  --port 5000 \
  --cidr 0.0.0.0/0
```

## Verificación

1. **Verificar tareas corriendo:**
   ```bash
   aws ecs list-tasks --cluster aws-ecs-simple-cluster --service-name aws-ecs-simple-service
   ```

2. **Ver logs:**
   ```bash
   aws logs get-log-events --log-group-name /ecs/aws-ecs-simple-app --log-stream-name ecs/aws-ecs-simple-app/TASK_ID
   ```

3. **Obtener IP pública (si no usas ALB):**
   ```bash
   aws ecs describe-tasks --cluster aws-ecs-simple-cluster --tasks TASK_ARN
   ```

## Variables de Ambiente

La aplicación responde al ambiente configurado vía `APP_ENV`:
- `local` → "¡Hola desde LOCAL!"
- `dev` → "¡Hola desde DEV!" 
- `qa` → "¡Hola desde QA!"
- `prod` → "¡Hola desde PROD!"

## Mejores Prácticas

1. **Usa Application Load Balancer** para producción
2. **Configura Auto Scaling** para manejar carga variable
3. **Implementa CI/CD** usando AWS CodePipeline
4. **Monitorea** con CloudWatch y AWS X-Ray
5. **Usa secrets** en AWS Systems Manager para credenciales

## Troubleshooting

**Tarea no inicia:**
- Verificar roles de IAM
- Revisar logs de CloudWatch
- Comprobar configuración de red

**Aplicación no responde:**
- Verificar security groups
- Comprobar health checks
- Revisar configuración de puerto

**Error de imagen:**
- Verificar que la imagen existe en ECR
- Confirmar la URI de la imagen en la definición de tarea