# Cleanup script - Eliminar todos los recursos de Kubernetes
# PowerShell script for Windows

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "qa", "prod", "all")]
    [string]$Environment = "all"
)

Write-Host "🧹 Script de Limpieza - Flask IoT App" -ForegroundColor Yellow

if ($Environment -eq "all") {
    Write-Host "⚠️  ATENCIÓN: Esto eliminará TODOS los recursos de TODOS los ambientes" -ForegroundColor Red
    $confirmation = Read-Host "¿Estás seguro? Escribir 'DELETE ALL' para continuar"
    if ($confirmation -ne "DELETE ALL") {
        Write-Host "❌ Operación cancelada" -ForegroundColor Red
        exit 1
    }
} elseif ($Environment -eq "prod") {
    Write-Host "🚨 ATENCIÓN: Vas a eliminar el ambiente de PRODUCCIÓN" -ForegroundColor Red
    $confirmation = Read-Host "¿Estás seguro? Escribir 'DELETE PROD' para continuar"
    if ($confirmation -ne "DELETE PROD") {
        Write-Host "❌ Operación cancelada" -ForegroundColor Red
        exit 1
    }
}

function Remove-Environment {
    param($env)
    
    Write-Host "`n🗑️  Eliminando recursos del ambiente: $env" -ForegroundColor Yellow
    
    # Eliminar recursos del ambiente específico
    kubectl delete -f "k8s/$env/" --ignore-not-found=true
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Recursos de $env eliminados" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Algunos recursos de $env podrían no haberse eliminado completamente" -ForegroundColor Yellow
    }
    
    # Verificar que no queden pods
    $remainingPods = kubectl get pods -n "flask-app-$env" --no-headers 2>$null | Measure-Object | Select-Object -ExpandProperty Count
    if ($remainingPods -gt 0) {
        Write-Host "⚠️  Quedan $remainingPods pods en flask-app-$env" -ForegroundColor Yellow
        Write-Host "Forzando eliminación de pods..." -ForegroundColor Yellow
        kubectl delete pods --all -n "flask-app-$env" --grace-period=0 --force 2>$null
    }
}

# Ejecutar limpieza según el ambiente especificado
switch ($Environment) {
    "dev" {
        Remove-Environment "dev"
    }
    "qa" {
        Remove-Environment "qa"
    }
    "prod" {
        Write-Host "🚨 Eliminando ambiente de PRODUCCIÓN..." -ForegroundColor Red
        Remove-Environment "prod"
    }
    "all" {
        Write-Host "🧹 Eliminando TODOS los ambientes..." -ForegroundColor Yellow
        Remove-Environment "dev"
        Remove-Environment "qa"  
        Remove-Environment "prod"
        
        # Eliminar namespaces
        Write-Host "`n🗑️  Eliminando namespaces..." -ForegroundColor Yellow
        kubectl delete namespace flask-app-dev --ignore-not-found=true
        kubectl delete namespace flask-app-qa --ignore-not-found=true  
        kubectl delete namespace flask-app-prod --ignore-not-found=true
        
        Write-Host "✅ Todos los namespaces eliminados" -ForegroundColor Green
    }
}

Write-Host "`n📊 Estado final de los recursos:" -ForegroundColor Cyan

if ($Environment -eq "all") {
    # Verificar que no queden recursos
    $namespaces = kubectl get namespaces | Select-String "flask-app-"
    if ($namespaces) {
        Write-Host "⚠️  Namespaces restantes:" -ForegroundColor Yellow
        kubectl get namespaces | Select-String "flask-app-"
    } else {
        Write-Host "✅ Todos los namespaces de flask-app eliminados" -ForegroundColor Green
    }
} else {
    # Mostrar estado del ambiente específico
    Write-Host "Estado de flask-app-$Environment:" -ForegroundColor Cyan
    kubectl get all -n "flask-app-$Environment" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✅ No hay recursos en flask-app-$Environment" -ForegroundColor Green
    }
}

Write-Host "`n📋 Para recrear los ambientes:" -ForegroundColor Cyan
Write-Host "DEV: .\k8s\deploy-dev.ps1" -ForegroundColor White  
Write-Host "QA:  .\k8s\deploy-qa.ps1" -ForegroundColor White
Write-Host "PROD: .\k8s\deploy-prod.ps1" -ForegroundColor White

Write-Host "`n🎉 Limpieza completada!" -ForegroundColor Green