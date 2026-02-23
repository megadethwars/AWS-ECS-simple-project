# 🚀 Guía Rápida - Kubernetes Multi-Ambiente

## 📁 Estructura Creada

```
k8s/
├── 📄 namespaces.yaml          # Namespaces para separar ambientes
├── 📁 base/                    # Recursos base (templates)
├── 🔧 dev/                     # Desarrollo (1 replica, debug, NodePort)
├── 🧪 qa/                      # Testing (2 replicas, Ingress)
├── 🏭 prod/                    # Producción (3 replicas, SSL, seguridad)
├── ⚡ deploy-dev.ps1           # Script despliegue DEV
├── ⚡ deploy-qa.ps1            # Script despliegue QA
├── ⚡ deploy-prod.ps1          # Script despliegue PROD
├── 🧹 cleanup.ps1             # Script de limpieza
└── 📖 README.md              # Documentación completa
```

## 🚀 Despliegue Rápido

### 1. **DEV (Desarrollo)**
```powershell
# Ejecutar script automático
.\k8s\deploy-dev.ps1

# URL: http://localhost:30500
```

### 2. **QA (Testing)**  
```powershell
# Ejecutar script automático
.\k8s\deploy-qa.ps1

# Configurar DNS local (Windows):
# Agregar a C:\Windows\System32\drivers\etc\hosts:
# 127.0.0.1 flask-iot-qa.local

# URL: http://flask-iot-qa.local
```

### 3. **PROD (Producción)**
⚠️ **ANTES DE PRODUCTION**:
1. Editar `k8s/prod/secrets.yaml` con secretos reales
2. Configurar certificados SSL 
3. Configurar DNS real

```powershell
# Ejecutar script automático (con validaciones)
.\k8s\deploy-prod.ps1

# URL: https://flask-iot-prod.company.com
```

## 🔧 Variables de Entorno por Ambiente

### DEV 🔧
- `APP_ENV=dev` 
- `FLASK_DEBUG=True`
- `LOG_LEVEL=DEBUG`
- SQLite database
- 1 replica, más recursos para debugging
- NodePort 30500

### QA 🧪  
- `APP_ENV=qa`
- `FLASK_DEBUG=False`
- `LOG_LEVEL=INFO`
- PostgreSQL database
- 2 replicas, testing habilitado
- Ingress sin SSL

### PROD 🏭
- `APP_ENV=prod`
- `FLASK_DEBUG=False`  
- `LOG_LEVEL=WARNING`
- PostgreSQL database + seguridad
- 3 replicas, configuración optimizada
- Ingress con SSL

## 🧹 Limpieza

```powershell
# Eliminar ambiente específico
.\k8s\cleanup.ps1 -Environment dev
.\k8s\cleanup.ps1 -Environment qa
.\k8s\cleanup.ps1 -Environment prod

# Eliminar TODOS los ambientes
.\k8s\cleanup.ps1 -Environment all
```

## 📊 Comandos Útiles

### Ver Estado
```bash
kubectl get all -n flask-app-dev
kubectl get all -n flask-app-qa
kubectl get all -n flask-app-prod
```

### Logs
```bash
kubectl logs -f deployment/flask-iot-app-dev -n flask-app-dev
kubectl logs -f deployment/flask-iot-app-qa -n flask-app-qa  
kubectl logs -f deployment/flask-iot-app-prod -n flask-app-prod
```

### Escalar
```bash
kubectl scale deployment flask-iot-app-qa --replicas=3 -n flask-app-qa
kubectl scale deployment flask-iot-app-prod --replicas=5 -n flask-app-prod
```

## 🔐 Seguridad por Ambiente

| Característica | DEV | QA | PROD |
|---------------|-----|----|----- |
| SSL Required | ❌ | ❌ | ✅ |
| Debug Mode | ✅ | ❌ | ❌ |
| Rate Limiting | 1000 | 500 | 50 |
| Security Context | Básico | Medio | Estricto |
| Secret Rotation | Manual | Manual | Automático |

## 🎯 Próximos Pasos

1. **Configurar CI/CD** para automatizar despliegues
2. **Monitoreo** con Prometheus/Grafana  
3. **Logging centralizado** con ELK Stack
4. **Backup automatizado** de bases de datos
5. **Disaster recovery** para PROD

¡Tu aplicación Flask IoT ahora está lista para multi-ambiente en Kubernetes! 🎉