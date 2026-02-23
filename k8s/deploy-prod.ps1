# Deploy script for PROD environment
# PowerShell script for Windows 
# ⚠️  USAR CON PRECAUCIÓN EN PRODUCCIÓN

Write-Host "🏭 Desplegando Flask IoT App - Ambiente PROD" -ForegroundColor Red
Write-Host "⚠️  ATENCIÓN: Este es un despliegue de PRODUCCIÓN" -ForegroundColor Yellow

# Confirmación de seguridad
$confirmation = Read-Host "¿Estás seguro de desplegar a PRODUCCIÓN? (escribir 'PROD' para continuar)"
if ($confirmation -ne "PROD") {
    Write-Host "❌ Despliegue cancelado" -ForegroundColor Red
    exit 1
}

# Verificar que los secretos han sido actualizados
Write-Host "⚠️  VERIFICACIÓN DE SEGURIDAD" -ForegroundColor Yellow
Write-Host "¿Has actualizado TODOS los secretos en k8s/prod/secrets.yaml con valores de producción?" -ForegroundColor Yellow
$secretsUpdated = Read-Host "(s/N)"
if ($secretsUpdated -ne "s" -and $secretsUpdated -ne "S") {
    Write-Host "❌ Por favor actualiza los secretos antes de continuar" -ForegroundColor Red
    Write-Host "Editar: k8s/prod/secrets.yaml" -ForegroundColor Yellow
    exit 1
}

# Crear namespace si no existe
Write-Host "Creando namespaces..." -ForegroundColor Yellow
kubectl apply -f k8s/namespaces.yaml

# Verificar que el namespace existe
$namespace = kubectl get namespace flask-app-prod --ignore-not-found
if (-not $namespace) {
    Write-Host "❌ Error: No se pudo crear el namespace flask-app-prod" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Namespace flask-app-prod listo" -ForegroundColor Green

# Verificar conexión a cluster PROD
Write-Host "Verificando cluster de producción..." -ForegroundColor Yellow
$currentContext = kubectl config current-context
Write-Host "Contexto actual: $currentContext" -ForegroundColor Cyan

$prodConfirm = Read-Host "¿Es este el cluster de PRODUCCIÓN correcto? (s/N)"
if ($prodConfirm -ne "s" -and $prodConfirm -ne "S") {
    Write-Host "❌ Verifica el contexto de kubectl antes de continuar" -ForegroundColor Red
    Write-Host "Usar: kubectl config use-context <prod-context>" -ForegroundColor Yellow
    exit 1
}

# Aplicar configuración PROD
Write-Host "Aplicando configuración PROD..." -ForegroundColor Yellow
kubectl apply -f k8s/prod/

# Esperar a que el deployment esté listo (3 replicas)
Write-Host "Esperando a que el deployment esté listo (3 réplicas)..." -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos en producción..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=600s deployment/flask-iot-app-prod -n flask-app-prod

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Deployment PROD exitoso!" -ForegroundColor Green
    
    # Mostrar información del despliegue
    Write-Host "`n📊 Estado del despliegue:" -ForegroundColor Cyan
    kubectl get all -n flask-app-prod
    
    # Verificar Ingress y SSL
    Write-Host "`n🌐 Configuración de Ingress:" -ForegroundColor Cyan  
    kubectl get ingress -n flask-app-prod
    
    Write-Host "`n🔐 Verificando certificados SSL:" -ForegroundColor Cyan
    kubectl get secret -n flask-app-prod | Select-String "tls"
    
    Write-Host "`n🌐 URL de Producción:" -ForegroundColor Cyan
    Write-Host "https://flask-iot-prod.company.com" -ForegroundColor White
    Write-Host "⚠️  Asegúrate de que el DNS esté configurado correctamente" -ForegroundColor Yellow
    
    Write-Host "`n📋 Comandos de producción:" -ForegroundColor Cyan
    Write-Host "Ver logs: kubectl logs deployment/flask-iot-app-prod -n flask-app-prod --tail=50" -ForegroundColor White
    Write-Host "Ver pods: kubectl get pods -n flask-app-prod" -ForegroundColor White
    Write-Host "Monitorear: kubectl top pods -n flask-app-prod" -ForegroundColor White
    Write-Host "Escalar: kubectl scale deployment flask-iot-app-prod --replicas=5 -n flask-app-prod" -ForegroundColor White
    
    Write-Host "`n🚨 Comandos de emergencia:" -ForegroundColor Red
    Write-Host "Rollback: kubectl rollout undo deployment/flask-iot-app-prod -n flask-app-prod" -ForegroundColor White
    Write-Host "Historial: kubectl rollout history deployment/flask-iot-app-prod -n flask-app-prod" -ForegroundColor White
    
    # Test de salud básico
    Write-Host "`n🔍 Verificando salud de la aplicación..." -ForegroundColor Yellow
    $healthyPods = kubectl get pods -n flask-app-prod -l app=flask-iot-app --field-selector=status.phase=Running --no-headers | Measure-Object | Select-Object -ExpandProperty Count
    Write-Host "✅ Pods saludables: $healthyPods/3" -ForegroundColor Green
    
    if ($healthyPods -eq 3) {
        Write-Host "🎉 Despliegue de PRODUCCIÓN completado exitosamente!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Advertencia: No todos los pods están saludables" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "❌ Error en el deployment PROD" -ForegroundColor Red
    Write-Host "🚨 ACCIÓN REQUERIDA: Verificar estado de la aplicación" -ForegroundColor Red
    Write-Host "Ver logs: kubectl logs -l app=flask-iot-app -n flask-app-prod" -ForegroundColor Yellow
    Write-Host "Describir pods: kubectl describe pods -n flask-app-prod" -ForegroundColor Yellow
    Write-Host "Considerar rollback: kubectl rollout undo deployment/flask-iot-app-prod -n flask-app-prod" -ForegroundColor Yellow
    exit 1
}