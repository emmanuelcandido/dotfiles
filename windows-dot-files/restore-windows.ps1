<#
.SYNOPSIS
    restore-windows.ps1 — Restaura/configura Windows do zero
.DESCRIPTION
    Modular restore script: pCloud mount, dotfiles restore, winget packages,
    Komorebi startup, NextDNS, QoL scripts.
.PARAMETER Full
    Instala pacotes completos (Full) ao invés de só Essential
.PARAMETER NoPcloud
    Pula montagem e restore do pCloud
.EXAMPLE
    .\restore-windows.ps1
    .\restore-windows.ps1 -Full
    .\restore-windows.ps1 -NoPcloud
#>

param(
    [switch]$Full,
    [switch]$NoPcloud
)

$ErrorActionPreference = "Stop"
$ScriptPath = Split-Path -Parent $PSCommandPath

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  restore-windows.ps1 — Windows Setup" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Source modules
. "$ScriptPath\modules\mount-pcloud.ps1"
. "$ScriptPath\modules\restore-dotfiles.ps1"
. "$ScriptPath\modules\install-packages.ps1"
. "$ScriptPath\modules\setup-komorebi.ps1"

# === Module 1: Packages ===
Write-Host "[1/4] Instalando pacotes..." -ForegroundColor Yellow
Install-Packages -Full:$Full

# === Module 2: pCloud (optional) ===
if (-not $NoPcloud) {
    Write-Host ""
    Write-Host "[2/4] Montando pCloud..." -ForegroundColor Yellow
    Mount-PCloud
    Write-Host ""
    Write-Host "[2/4] Restaurando dotfiles do pCloud..." -ForegroundColor Yellow
    Restore-Dotfiles
} else {
    Write-Host ""
    Write-Host "[2/4] pCloud pulado (-NoPcloud)" -ForegroundColor Yellow
}

# === Module 3: Komorebi startup ===
Write-Host ""
Write-Host "[3/4] Configurando Komorebi startup..." -ForegroundColor Yellow
Setup-KomorebiStartup

# === Module 4: QoL scripts ===
Write-Host ""
Write-Host "[4/4] Executando scripts de qualidade de vida..." -ForegroundColor Yellow
& "$ScriptPath\Windows\Ativos\RemoverOneDrive.ps1" -ErrorAction SilentlyContinue
& "$ScriptPath\Windows\Ativos\ReduzirBarraTitulo.ps1" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "  Restore concluído!" -ForegroundColor Green
Write-Host "  Essential: ✓" -ForegroundColor Green
if ($Full) { Write-Host "  Full:      ✓" -ForegroundColor Green }
Write-Host "  Komorebi:  startup configurado" -ForegroundColor Green
Write-Host "  Próximo:   reiniciar para NextDNS" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
