# Kubernetes Deployment Scripts

## Estructura de Ambientes

```
k8s/
├── namespaces.yaml          # Namespaces para separar ambientes
├── base/                    # Recursos base (templates)
│   ├── deployment.yaml      # Deployment base
│   └── service.yaml        # Service base
├── dev/                     # Ambiente de desarrollo
│   ├── configmap.yaml      # Variables DEV
│   ├── secrets.yaml        # Secretos DEV
│   ├── deployment.yaml     # Deployment DEV (1 replica, debug)
│   └── service.yaml        # Service DEV (NodePort)
├── qa/                      # Ambiente de testing
│   ├── configmap.yaml      # Variables QA
│   ├── secrets.yaml        # Secretos QA
│   ├── deployment.yaml     # Deployment QA (2 replicas)
│   ├── service.yaml        # Service QA (ClusterIP)
│   └── ingress.yaml        # Ingress QA
└── prod/                    # Ambiente de producción  
    ├── configmap.yaml      # Variables PROD
    ├── secrets.yaml        # Secretos PROD
    ├── deployment.yaml     # Deployment PROD (3 replicas, seguridad)
    ├── service.yaml        # Service PROD (ClusterIP)
    └── ingress.yaml        # Ingress PROD (SSL)
```

## 🚀 Comandos de Despliegue

### Crear Namespaces (una sola vez)
```bash
kubectl apply -f k8s/namespaces.yaml
```

### 🔧 Ambiente DEV
```bash
# Aplicar todos los recursos de DEV
kubectl apply -f k8s/dev/

# Verificar despliegue
kubectl get all -n flask-app-dev

# Ver logs
kubectl logs -f deployment/flask-iot-app-dev -n flask-app-dev

# Acceder a la aplicación (NodePort)
# http://localhost:30500 o http://<node-ip>:30500
```

### 🧪 Ambiente QA  
```bash
# Aplicar todos los recursos de QA
kubectl apply -f k8s/qa/

# Verificar despliegue
kubectl get all -n flask-app-qa

# Ver logs
kubectl logs -f deployment/flask-iot-app-qa -n flask-app-qa

# Acceder via Ingress (configurar DNS)
# http://flask-iot-qa.local
```

### 🏭 Ambiente PROD
```bash
# ⚠️  IMPORTANTE: Cambiar secretos antes de aplicar!
# Editar k8s/prod/secrets.yaml con valores reales

# Aplicar todos los recursos de PROD
kubectl apply -f k8s/prod/

# Verificar despliegue
kubectl get all -n flask-app-prod

# Ver logs (cuidado en PROD)
kubectl logs deployment/flask-iot-app-prod -n flask-app-prod --tail=50

# Acceder via Ingress con SSL
# https://flask-iot-prod.company.com
```

## 🔧 Comandos Útiles

### Ver estado de pods por ambiente
```bash
kubectl get pods -n flask-app-dev
kubectl get pods -n flask-app-qa  
kubectl get pods -n flask-app-prod
```

### Escalar aplicación
```bash
# Escalar DEV
kubectl scale deployment flask-iot-app-dev --replicas=2 -n flask-app-dev

# Escalar QA
kubectl scale deployment flask-iot-app-qa --replicas=3 -n flask-app-qa

# Escalar PROD
kubectl scale deployment flask-iot-app-prod --replicas=5 -n flask-app-prod
```

### Ver configuración
```bash
# Ver ConfigMaps
kubectl get configmap flask-config -n flask-app-dev -o yaml

# Ver Secrets (sin decodificar)
kubectl get secret flask-secrets -n flask-app-prod

# Describir deployment  
kubectl describe deployment flask-iot-app-prod -n flask-app-prod
```

### Rolling Update
```bash
# Actualizar imagen en DEV
kubectl set image deployment/flask-iot-app-dev flask-app=flask-app-local:dev-v2 -n flask-app-dev

# Actualizar imagen en PROD (más cuidadoso)
kubectl set image deployment/flask-iot-app-prod flask-app=flask-app-local:prod-v2 -n flask-app-prod
kubectl rollout status deployment/flask-iot-app-prod -n flask-app-prod
```

### Rollback si hay problemas
```bash
# Ver historial
kubectl rollout history deployment/flask-iot-app-prod -n flask-app-prod

# Rollback a versión anterior
kubectl rollout undo deployment/flask-iot-app-prod -n flask-app-prod
```

## ⚠️  Configuraciones Importantes

### 🔐 Secretos de Producción
Antes de desplegar a PROD, **CAMBIAR TODOS los secretos**:

```bash
# Generar secret key seguro
openssl rand -base64 32

# Generar JWT secret
openssl rand -hex 32

# Codificar en base64 para Kubernetes
echo -n "tu-secret-real" | base64
```

### 🌐 DNS y Dominios
- **DEV**: `http://localhost:30500` (NodePort)
- **QA**: `http://flask-iot-qa.local` (configurar en /etc/hosts)
- **PROD**: `https://flask-iot-prod.company.com` (DNS real + SSL)

### 📊 Recursos por Ambiente
| Ambiente | Replicas | CPU Request | Memory Request | CPU Limit | Memory Limit |
|----------|----------|-------------|----------------|-----------|--------------|
| DEV      | 1        | 100m        | 128Mi          | 500m      | 512Mi        |
| QA       | 2        | 200m        | 256Mi          | 400m      | 512Mi        |
| PROD     | 3        | 250m        | 512Mi          | 500m      | 1Gi          |

## 🔍 Health Checks
Todos los ambientes incluyen:
- **Liveness Probe**: `/healthcheck` para detectar pods no saludables
- **Readiness Probe**: `/healthcheck` para controlar tráfico

## 📈 Monitoreo
Los logs están disponibles via:
```bash
# Ver logs de todos los pods de un ambiente
kubectl logs -l app=flask-iot-app,environment=prod -n flask-app-prod --tail=100

# Seguir logs en tiempo real
kubectl logs -f deployment/flask-iot-app-prod -n flask-app-prod
```