# Deploy script for DEV environment
# PowerShell script for Windows

Write-Host "🔧 Desplegando Flask IoT App - Ambiente DEV" -ForegroundColor Green

# Crear namespace si no existe
Write-Host "Creando namespaces..." -ForegroundColor Yellow
kubectl apply -f k8s/namespaces.yaml

# Verificar que el namespace existe
$namespace = kubectl get namespace flask-app-dev --ignore-not-found
if (-not $namespace) {
    Write-Host "❌ Error: No se pudo crear el namespace flask-app-dev" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Namespace flask-app-dev listo" -ForegroundColor Green

# Aplicar configuración DEV
Write-Host "Aplicando configuración DEV..." -ForegroundColor Yellow
kubectl apply -f k8s/dev/

# Esperar a que el deployment esté listo
Write-Host "Esperando a que el deployment esté listo..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/flask-iot-app-dev -n flask-app-dev

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Deployment DEV exitoso!" -ForegroundColor Green
    
    # Mostrar información del despliegue
    Write-Host "`n📊 Estado del despliegue:" -ForegroundColor Cyan
    kubectl get all -n flask-app-dev
    
    Write-Host "`n🌐 Para acceder a la aplicación:" -ForegroundColor Cyan  
    Write-Host "URL: http://localhost:30500" -ForegroundColor White
    Write-Host "También: http://<node-ip>:30500" -ForegroundColor White
    
    Write-Host "`n📋 Comandos útiles:" -ForegroundColor Cyan
    Write-Host "Ver logs: kubectl logs -f deployment/flask-iot-app-dev -n flask-app-dev" -ForegroundColor White
    Write-Host "Ver pods: kubectl get pods -n flask-app-dev" -ForegroundColor White
    Write-Host "Eliminar: kubectl delete -f k8s/dev/" -ForegroundColor White
    
} else {
    Write-Host "❌ Error en el deployment DEV" -ForegroundColor Red
    Write-Host "Ver logs con: kubectl logs -l app=flask-iot-app -n flask-app-dev" -ForegroundColor Yellow
    exit 1
}