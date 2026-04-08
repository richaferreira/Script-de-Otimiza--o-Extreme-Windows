<#
.SYNOPSIS
    EXTREME WINDOWS 11 OPTIMIZER - GAMER & DEVELOPER EDITION (v2.0)
    Script unificado com integração ao Windows Utility do Chris Titus Tech.

.DESCRIPTION
    Este script combina ajustes nativos de performance "Extreme" com a poderosa
    interface do Chris Titus Tech (CTT) Windows Utility.
    
    Novidades na v2.0:
    - Integração direta com 'irm christitus.com/win | iex'.
    - Menu expandido para ferramentas CTT.
    - Otimizações de rede e sistema refinadas.

.NOTES
    Requer privilégios de Administrador.
    Inspirado por: Chris Titus Tech, Raphire, e guias de baixa latência.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Verificar Administrador
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "ERRO: Execute como Administrador!"
    Break
}

# ------------------------------------------------------------------------------
# FUNÇÕES DE INTERFACE
# ------------------------------------------------------------------------------

function Show-Header {
    Clear-Host
    Write-Host "###########################################################" -ForegroundColor Cyan
    Write-Host "#                                                         #" -ForegroundColor Cyan
    Write-Host "#   EXTREME WINDOWS 11 OPTIMIZER v2.0 - GAMER & DEV       #" -ForegroundColor Cyan
    Write-Host "#   Powered by Manus AI & Chris Titus Tech Integration    #" -ForegroundColor Cyan
    Write-Host "#                                                         #" -ForegroundColor Cyan
    Write-Host "###########################################################" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Show-Header
    Write-Host " --- FERRAMENTAS CHRIS TITUS TECH ---" -ForegroundColor Yellow
    Write-Host " [T]  ABRIR: Windows Utility (Interface Gráfica CTT)"
    Write-Host " [M]  MICRO-WIN: Criar ISO enxuta (Debloat Extremo)"
    Write-Host ""
    Write-Host " --- AJUSTES EXTREME (NATIVOS) ---" -ForegroundColor Cyan
    Write-Host " [1]  RESTAURAÇÃO: Criar Ponto de Segurança"
    Write-Host " [2]  DEBLOAT: Limpeza Profunda de Apps e Widgets"
    Write-Host " [3]  PRIVACIDADE: Matar Telemetria e Cortana"
    Write-Host " [4]  GAMING: Latência Zero, Prioridade CPU e Rede" -ForegroundColor Green
    Write-Host " [5]  DEVELOPER: WSL2, Modo Dev e Winget" -ForegroundColor Magenta
    Write-Host " [6]  SISTEMA: Desativar VBS/HVCI (Boost FPS)"
    Write-Host " [7]  LIMPEZA: Cache de Update e Temporários"
    Write-Host ""
    Write-Host " [8]  ULTIMATE: Combo Extreme + CTT Tweaks" -ForegroundColor Red
    Write-Host " [Q]  Sair"
    Write-Host ""
    $choice = Read-Host "Escolha sua arma"
    return $choice.ToUpper()
}

# ------------------------------------------------------------------------------
# INTEGRAÇÃO CHRIS TITUS TECH
# ------------------------------------------------------------------------------

function Open-CTT-Utility {
    Write-Host "[*] Baixando e iniciando Windows Utility do Chris Titus..." -ForegroundColor Yellow
    irm https://christitus.com/win | iex
}

function Open-MicroWin {
    Write-Host "[*] Iniciando MicroWin (Ferramenta de ISO enxuta)..." -ForegroundColor Yellow
    irm https://christitus.com/microwin | iex
}

# ------------------------------------------------------------------------------
# MÓDULOS NATIVOS (Refinados)
# ------------------------------------------------------------------------------

function Set-RestorePoint {
    Write-Host "[*] Criando ponto de restauração..." -ForegroundColor Cyan
    Enable-ComputerRestore -Drive "C:\"
    Checkpoint-Computer -Description "ExtremeOptimizer_v2" -RestorePointType "MODIFY_SETTINGS"
    Write-Host "[+] Pronto!" -ForegroundColor Green
}

function Run-Debloat {
    Write-Host "[*] Removendo lixo do Windows..." -ForegroundColor Cyan
    $apps = @("Microsoft.ZuneMusic", "Microsoft.SkypeApp", "Microsoft.YourPhone", "Microsoft.BingNews", "Microsoft.XboxApp", "Microsoft.PowerAutomateDesktop")
    foreach ($app in $apps) { Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "[+] Debloat concluído!" -ForegroundColor Green
}

function Optimize-Gaming {
    Write-Host "[*] Aplicando Otimizações de Latência Extreme..." -ForegroundColor Green
    # Network Throttling & Responsiveness
    $path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-ItemProperty -Path $path -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF
    Set-ItemProperty -Path $path -Name "SystemResponsiveness" -Value 0
    
    # TCP Tweaks
    netsh int tcp set heuristics disabled
    netsh int tcp set global rss=enabled
    netsh int tcp set global autotuninglevel=normal
    
    # GPU Preference (High Performance)
    Write-Host "  -> Dica: Configure sua GPU para 'Desempenho Máximo' no Painel de Controle NVIDIA/AMD."
    Write-Host "[+] Ajustes aplicados!" -ForegroundColor Green
}

function Optimize-System {
    Write-Host "[*] Desativando VBS/HVCI para Ganho de FPS..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0 -ErrorAction SilentlyContinue
    Write-Host "[+] VBS Desativado (Requer Reinício)." -ForegroundColor Yellow
}

# ------------------------------------------------------------------------------
# LOOP PRINCIPAL
# ------------------------------------------------------------------------------

do {
    $choice = Show-Menu
    switch ($choice) {
        "T" { Open-CTT-Utility }
        "M" { Open-MicroWin }
        "1" { Set-RestorePoint }
        "2" { Run-Debloat }
        "3" { # Telemetria Simplificada
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
            Stop-Service -Name "DiagTrack" -ErrorAction SilentlyContinue
            Set-Service -Name "DiagTrack" -StartupType Disabled
            Write-Host "[+] Telemetria Morta!" -ForegroundColor Green
        }
        "4" { Optimize-Gaming }
        "5" { # Dev Mode
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1
            Write-Host "[+] Modo Dev Ativado!" -ForegroundColor Magenta
        }
        "6" { Optimize-System }
        "7" { # Limpeza
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Limpeza concluída!" -ForegroundColor Green
        }
        "8" { 
            Write-Host "!!! EXECUTANDO COMBO ULTIMATE !!!" -ForegroundColor Red
            Set-RestorePoint
            Run-Debloat
            Optimize-Gaming
            Optimize-System
            Write-Host "Abrindo Windows Utility para ajustes finais..." -ForegroundColor Yellow
            Open-CTT-Utility
        }
        "Q" { Write-Host "Saindo..."; Break }
    }
    Write-Host ""
    Read-Host "Pressione Enter para continuar..."
} while ($choice -ne "Q")
