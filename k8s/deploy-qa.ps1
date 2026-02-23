# Deploy script for QA environment  
# PowerShell script for Windows

Write-Host "🧪 Desplegando Flask IoT App - Ambiente QA" -ForegroundColor Green

# Crear namespace si no existe
Write-Host "Creando namespaces..." -ForegroundColor Yellow
kubectl apply -f k8s/namespaces.yaml

# Verificar que el namespace existe
$namespace = kubectl get namespace flask-app-qa --ignore-not-found
if (-not $namespace) {
    Write-Host "❌ Error: No se pudo crear el namespace flask-app-qa" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Namespace flask-app-qa listo" -ForegroundColor Green

# Aplicar configuración QA
Write-Host "Aplicando configuración QA..." -ForegroundColor Yellow
kubectl apply -f k8s/qa/

# Esperar a que el deployment esté listo (2 replicas)
Write-Host "Esperando a que el deployment esté listo (2 réplicas)..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/flask-iot-app-qa -n flask-app-qa

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Deployment QA exitoso!" -ForegroundColor Green
    
    # Mostrar información del despliegue
    Write-Host "`n📊 Estado del despliegue:" -ForegroundColor Cyan
    kubectl get all -n flask-app-qa
    
    # Verificar Ingress
    Write-Host "`n🌐 Configuración de Ingress:" -ForegroundColor Cyan  
    kubectl get ingress -n flask-app-qa
    
    Write-Host "`n🌐 Para acceder a la aplicación:" -ForegroundColor Cyan
    Write-Host "URL: http://flask-iot-qa.local" -ForegroundColor White
    Write-Host "Nota: Agregar '127.0.0.1 flask-iot-qa.local' a /etc/hosts (Linux/Mac)" -ForegroundColor Yellow
    Write-Host "      o C:\Windows\System32\drivers\etc\hosts (Windows)" -ForegroundColor Yellow
    
    Write-Host "`n📋 Comandos útiles:" -ForegroundColor Cyan
    Write-Host "Ver logs: kubectl logs -f deployment/flask-iot-app-qa -n flask-app-qa" -ForegroundColor White
    Write-Host "Ver pods: kubectl get pods -n flask-app-qa" -ForegroundColor White
    Write-Host "Escalar: kubectl scale deployment flask-iot-app-qa --replicas=3 -n flask-app-qa" -ForegroundColor White
    Write-Host "Eliminar: kubectl delete -f k8s/qa/" -ForegroundColor White
    
    # Test de conectividad básico
    Write-Host "`n🔍 Verificando conectividad..." -ForegroundColor Yellow
    $service = kubectl get service flask-iot-service-qa -n flask-app-qa -o jsonpath='{.spec.clusterIP}'
    if ($service) {
        Write-Host "✅ Service IP: $service" -ForegroundColor Green
    }
    
} else {
    Write-Host "❌ Error en el deployment QA" -ForegroundColor Red
    Write-Host "Ver logs con: kubectl logs -l app=flask-iot-app -n flask-app-qa" -ForegroundColor Yellow
    Write-Host "Describir pods: kubectl describe pods -n flask-app-qa" -ForegroundColor Yellow
    exit 1
}