<#
.SYNOPSIS
    Install-Packages — Instala pacotes via winget (essential/full)
.DESCRIPTION
    Lê packages/essential.txt (sempre) e packages/full.txt (com -Full).
    Instala via winget, que já vem no Windows 11.
#>

function Install-Packages {
    param([switch]$Full)

    $scriptDir = Split-Path -Parent $PSCommandPath
    $projectDir = Resolve-Path "$scriptDir\.."
    $essentialFile = "$projectDir\packages\essential.txt"

    # Check winget
    $winget = Get-Command "winget" -ErrorAction SilentlyContinue
    if (-not $winget) {
        Write-Host "  [packages] winget não encontrado. Instale o App Installer da Microsoft Store." -ForegroundColor Red
        return
    }

    Write-Host "  [packages] Lendo lista essential..."
    $essentialPkgs = Get-Content $essentialFile | Where-Object {
        $_ -match "\S" -and $_ -notmatch "^#"
    }

    # Install essential one by one (winget doesn't batch well)
    $count = 0
    $total = $essentialPkgs.Count
    foreach ($pkg in $essentialPkgs) {
        $count++
        Write-Host "  [packages] [$count/$total] $pkg..." -ForegroundColor Gray
        & winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements 2>$null | Out-Null
    }

    Write-Host "  [packages] ✓ Essential: $total pacotes" -ForegroundColor Green

    # Full packages
    if ($Full) {
        $fullFile = "$projectDir\packages\full.txt"
        if (Test-Path $fullFile) {
            Write-Host "  [packages] Modo FULL — instalando pacotes adicionais..."
            $fullPkgs = Get-Content $fullFile | Where-Object {
                $_ -match "\S" -and $_ -notmatch "^#"
            }
            foreach ($pkg in $fullPkgs) {
                & winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements 2>$null | Out-Null
            }
            Write-Host "  [packages] ✓ Full: $($fullPkgs.Count) pacotes" -ForegroundColor Green
        } else {
            Write-Host "  [packages] packages/full.txt não encontrado. Pulando." -ForegroundColor Yellow
        }
    }

    # NextDNS (sempre)
    Write-Host "  [packages] Instalando NextDNS..."
    & winget install --id NextDNS.NextDNS --silent --accept-package-agreements --accept-source-agreements 2>$null | Out-Null

    # Claude Code
    Write-Host "  [packages] Instalando Claude Code..."
    & npm install -g @anthropic-ai/claude-code 2>$null | Out-Null
}
