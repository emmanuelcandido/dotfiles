<#
.SYNOPSIS
    Restore-Dotfiles — Restaura dotfiles do pCloud (não-versionáveis)
.DESCRIPTION
    Git tem prioridade. pCloud só restaura o que não está versionado.
    Usa Copy-Object com -ErrorAction SilentlyContinue para não sobrescrever.
#>

function Restore-Dotfiles {
    $pcloudMachine = "$env:USERPROFILE\pcloud\machines\windows"

    if (-not (Test-Path "$env:USERPROFILE\pcloud\machines")) {
        Write-Host "  [restore] pCloud não montado. Pulando restore." -ForegroundColor Yellow
        return
    }

    if (-not (Test-Path $pcloudMachine)) {
        Write-Host "  [restore] Nenhum backup encontrado em $pcloudMachine" -ForegroundColor Yellow
        return
    }

    Write-Host "  [restore] Restaurando do pCloud (apenas não-versionáveis)..."

    # Browser profiles
    $browserDirs = @{
        "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data" = "browser\chrome"
        "C:\Users\$env:USERNAME\AppData\Local\BraveSoftware\Brave-Browser\User Data" = "browser\brave"
    }

    $pcloudBrowser = "$pcloudMachine\browser"
    if (Test-Path $pcloudBrowser) {
        Write-Host "  [restore] Restaurando perfis de navegador..."
        Copy-Item -Path "$pcloudBrowser\*" -Destination "$env:LOCALAPPDATA\" -Recurse -ErrorAction SilentlyContinue
    }

    # SSH keys
    $pcloudSsh = "$pcloudMachine\ssh"
    if (Test-Path $pcloudSsh) {
        Write-Host "  [restore] Restaurando chaves SSH..."
        New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.ssh" | Out-Null
        Copy-Item -Path "$pcloudSsh\*" -Destination "$env:USERPROFILE\.ssh\" -Recurse -ErrorAction SilentlyContinue
    }

    # Wallpapers
    $pcloudWallpapers = "$pcloudMachine\wallpapers"
    if (Test-Path $pcloudWallpapers) {
        Write-Host "  [restore] Restaurando wallpapers..."
        New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\wallpapers" | Out-Null
        Copy-Item -Path "$pcloudWallpapers\*" -Destination "$env:USERPROFILE\wallpapers\" -Recurse -ErrorAction SilentlyContinue
    }

    Write-Host "  [restore] ✓ Restore concluído (nada sobrescrito)" -ForegroundColor Green
}
