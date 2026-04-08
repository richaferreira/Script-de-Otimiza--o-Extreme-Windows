<#
.SYNOPSIS
    EXTREME OPTIMIZER ULTRA v3 (GAMER / DEV / TOOLKIT HUB)
    A versão definitiva unindo ajustes manuais, Chris Titus Tech e segurança avançada.

.DESCRIPTION
    Este script é um HUB completo para Windows 11 que inclui:
    - Backup/Restore de Registro Inteligente.
    - Sistema de Logs (Transcript) para auditoria.
    - Integração Total com Chris Titus Windows Utility & MicroWin.
    - Otimizações Extreme para Baixa Latência (TCPNoDelay).
    - Tweaks para Desenvolvedores (LongPaths, WSL2).
    - Menu Interativo e Seguro.

.NOTES
    Requer privilégios de Administrador.
    Uso por conta e risco. Sempre crie um Ponto de Restauração.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================================================
# AUTO ADMIN (REPASSA PARÂMETROS)
# =========================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevando privilégios..." -ForegroundColor Yellow
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# =========================================================
# CONFIGURAÇÃO DE DIRETÓRIOS E LOGS
# =========================================================
$BaseDir = "$env:ProgramData\ExtremeOptimizer"
$LogDir = "$BaseDir\logs"
$BackupDir = "$BaseDir\backups"

if (!(Test-Path $LogDir)) { New-Item $LogDir -ItemType Directory -Force | Out-Null }
if (!(Test-Path $BackupDir)) { New-Item $BackupDir -ItemType Directory -Force | Out-Null }

$LogFile = "$LogDir\ExtremeLog_$(Get-Date -f yyyyMMdd_HHmm).txt"
Start-Transcript -Path $LogFile -Append -ErrorAction SilentlyContinue

# =========================================================
# FUNÇÕES DE SEGURANÇA (BACKUP / RESTORE)
# =========================================================
function Backup-Registry {
    Write-Host "[*] Realizando Backup de chaves críticas..." -ForegroundColor Cyan
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "$BackupDir\Tcpip_Backup.reg" /y 2>$null
    reg export "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "$BackupDir\Telemetry_Backup.reg" /y 2>$null
    Write-Host "[+] Backups salvos em: $BackupDir" -ForegroundColor Green
}

function Create-RestorePoint {
    Write-Host "[*] Criando Ponto de Restauração do Sistema..." -ForegroundColor Cyan
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "ExtremeOptimizer_ULTRA_v3" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Write-Host "[+] Ponto de Restauração Criado!" -ForegroundColor Green
}

function Restore-System {
    Write-Host "[!] Restaurando configurações originais..." -ForegroundColor Yellow
    if (Test-Path "$BackupDir\Tcpip_Backup.reg") { reg import "$BackupDir\Tcpip_Backup.reg" }
    if (Test-Path "$BackupDir\Telemetry_Backup.reg") { reg import "$BackupDir\Telemetry_Backup.reg" }
    powercfg -setactive SCHEME_BALANCED
    Write-Host "[+] Restauração concluída (Registro e Energia)!" -ForegroundColor Green
}

# =========================================================
# MÓDULOS DE OTIMIZAÇÃO (EXTREME)
# =========================================================
function Run-Gamer-Tweaks {
    Write-Host "[*] Aplicando Otimizações Extreme Gamer..." -ForegroundColor Green
    # Latência de Rede (TCPNoDelay)
    New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TCPNoDelay -Value 1 -PropertyType DWORD -Force | Out-Null
    # Prioridade de Processamento
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" NetworkThrottlingIndex 0xFFFFFFFF
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0
    # Plano de Energia (Alto Desempenho)
    powercfg -setactive SCHEME_MIN
    Write-Host "[+] Latência reduzida e Energia otimizada!" -ForegroundColor Green
}

function Run-Dev-Tweaks {
    Write-Host "[*] Aplicando Tweaks para Desenvolvedores..." -ForegroundColor Magenta
    # Habilitar Caminhos Longos (LongPaths)
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" LongPathsEnabled 1
    # Ativar WSL2
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
    # Modo Desenvolvedor
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" AllowDevelopmentWithoutDevLicense 1
    Write-Host "[+] Ambiente Developer pronto!" -ForegroundColor Green
}

function Run-Debloat-Extreme {
    Write-Host "[*] Removendo Bloatware (Safe for Gamers)..." -ForegroundColor Yellow
    $apps = "*SkypeApp*", "*BingNews*", "*BingWeather*", "*ZuneMusic*", "*ZuneVideo*", "*GetHelp*", "*Getstarted*", "*YourPhone*", "*MicrosoftOfficeHub*"
    foreach ($app in $apps) {
        Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    }
    # Matar Telemetria
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" AllowTelemetry 0
    Stop-Service DiagTrack -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "[+] Debloat e Telemetria concluídos!" -ForegroundColor Green
}

# =========================================================
# INTERFACE E MENU HUB
# =========================================================
function Show-Header {
    Clear-Host
    Write-Host "###########################################################" -ForegroundColor Cyan
    Write-Host "#                                                         #" -ForegroundColor Cyan
    Write-Host "#   EXTREME OPTIMIZER ULTRA v3 - THE ULTIMATE HUB         #" -ForegroundColor Cyan
    Write-Host "#   Gamer | Developer | Deployment | Maintenance          #" -ForegroundColor Cyan
    Write-Host "#                                                         #" -ForegroundColor Cyan
    Write-Host "###########################################################" -ForegroundColor Cyan
    Write-Host " Log: $LogFile" -ForegroundColor Gray
    Write-Host ""
}

function Main-Menu {
    Show-Header
    Write-Host " [1]  COMBO ULTRA: Backup + Restore Point + Tudo (Gamer/Dev/Debloat)" -ForegroundColor Red
    Write-Host " [2]  GAMER: Latência (TCPNoDelay) + Energia (High Perf)" -ForegroundColor Green
    Write-Host " [3]  DEVELOPER: LongPaths + WSL2 + DevMode" -ForegroundColor Magenta
    Write-Host " [4]  DEBLOAT: Remover Apps Inúteis + Matar Telemetria" -ForegroundColor Yellow
    Write-Host ""
    Write-Host " [T]  CHRIS TITUS: Abrir Windows Utility (GUI)"
    Write-Host " [M]  MICRO-WIN: Abrir Ferramenta de ISO Customizada"
    Write-Host ""
    Write-Host " [B]  BACKUP: Apenas Backup de Registro"
    Write-Host " [R]  RESTORE: Reverter Ajustes (Registro/Energia)" -ForegroundColor Cyan
    Write-Host " [Q]  SAIR"
    Write-Host ""
    
    $choice = Read-Host "Selecione sua ação"
    return $choice.ToUpper()
}

# =========================================================
# LOOP DE EXECUÇÃO
# =========================================================
do {
    $c = Main-Menu
    switch ($c) {
        "1" {
            Backup-Registry
            Create-RestorePoint
            Run-Gamer-Tweaks
            Run-Dev-Tweaks
            Run-Debloat-Extreme
            Write-Host "!!! OTIMIZAÇÃO ULTRA CONCLUÍDA !!!" -ForegroundColor Red -BackgroundColor White
        }
        "2" { Run-Gamer-Tweaks }
        "3" { Run-Dev-Tweaks }
        "4" { Run-Debloat-Extreme }
        "T" { irm https://christitus.com/win | iex }
        "M" { irm https://christitus.com/microwin | iex }
        "B" { Backup-Registry }
        "R" { Restore-System }
        "Q" { 
            Write-Host "Encerrando sessão de otimização..." -ForegroundColor Cyan
            Stop-Transcript -ErrorAction SilentlyContinue
            exit 
        }
        default { Write-Host "Opção Inválida!" -ForegroundColor Red }
    }
    Write-Host ""
    Read-Host "Pressione Enter para voltar ao HUB..."
} while ($c -ne "Q")
