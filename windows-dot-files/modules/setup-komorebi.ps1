<#
.SYNOPSIS
    Setup-KomorebiStartup — Cria atalho do Komorebi na inicialização
.DESCRIPTION
    Cria atalho no shell:startup para komorebi.ahk.
    Usa o C:\Windows\System32\cmd.exe /c start "" para minimizar.
#>

function Setup-KomorebiStartup {
    $projectDir = Resolve-Path "$PSScriptRoot\.."
    $ahkSource = "$projectDir\Windows\Komorebi\komorebi.ahk"
    $startupDir = [Environment]::GetFolderPath("Startup")
    $shortcutPath = "$startupDir\Komorebi.lnk"

    if (-not (Test-Path $ahkSource)) {
        Write-Host "  [komorebi] komorebi.ahk não encontrado em $ahkSource" -ForegroundColor Yellow
        return
    }

    # Criar atalho via WScript.Shell
    $wshell = New-Object -ComObject WScript.Shell
    $shortcut = $wshell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "C:\Windows\System32\cmd.exe"
    $shortcut.Arguments = "/c start `"`" `"$ahkSource`""
    $shortcut.WorkingDirectory = Split-Path $ahkSource -Parent
    $shortcut.Description = "Komorebi TWM — Auto-start"
    $shortcut.Save()

    Write-Host "  [komorebi] ✓ Atalho criado em: $shortcutPath" -ForegroundColor Green
    Write-Host "  [komorebi]   → Target: $ahkSource" -ForegroundColor Gray

    # Verificar se AutoHotkey está instalado
    $ahkExe = Get-Command "AutoHotkey64.exe" -ErrorAction SilentlyContinue
    if (-not $ahkExe) {
        Write-Host "  [komorebi] ⚠ AutoHotkey não encontrado. Instale via winget:" -ForegroundColor Yellow
        Write-Host "  winget install AutoHotkey.AutoHotkey" -ForegroundColor Yellow
    }

    # Configurar komorebi para iniciar com o AHK
    Write-Host "  [komorebi] ✓ Setup concluído. Komorebi iniciará no próximo login." -ForegroundColor Green
}
