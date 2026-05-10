<#
.SYNOPSIS
    Mount-PCloud — Monta pCloud via rclone no Windows
.DESCRIPTION
    Verifica rclone, monta pCloud: como drive mapeado.
    Usa rclone mount com VFS cache (similar ao Linux).
#>

function Mount-PCloud {
    $pcloudDrive = "P:"
    $pcloudMount = "$env:USERPROFILE\pcloud"

    # Check rclone
    $rclone = Get-Command "rclone" -ErrorAction SilentlyContinue
    if (-not $rclone) {
        Write-Host "  [pcloud] rclone não encontrado. Instale via winget: winget install rclone" -ForegroundColor Yellow
        return
    }

    # Verificar se já está montado
    if (Test-Path "$pcloudMount\machines") {
        Write-Host "  [pcloud] pCloud já montado em $pcloudMount" -ForegroundColor Green
        return
    }

    # Verificar se o remote existe
    $remotes = & rclone listremotes 2>$null
    if ($remotes -notmatch "pcloud:") {
        Write-Host "  [pcloud] Remote 'pcloud' não configurado." -ForegroundColor Yellow
        Write-Host "  Execute: rclone config" -ForegroundColor Yellow
        return
    }

    # Criar diretório de mount
    New-Item -ItemType Directory -Force -Path $pcloudMount | Out-Null

    Write-Host "  [pcloud] Montando pcloud: em $pcloudMount..." -ForegroundColor Gray
    $mountArgs = @(
        "mount", "pcloud:", $pcloudMount,
        "--vfs-cache-mode", "writes",
        "--dir-cache-time", "30m",
        "--poll-interval", "1m",
        "--daemon"
    )

    $result = Start-Process -FilePath "rclone" -ArgumentList $mountArgs -Wait -NoNewWindow -PassThru
    if ($result.ExitCode -eq 0) {
        Write-Host "  [pcloud] ✓ Montado em $pcloudMount" -ForegroundColor Green
    } else {
        Write-Host "  [pcloud] ✗ Falha ao montar (exit code: $($result.ExitCode))" -ForegroundColor Red
    }
}
