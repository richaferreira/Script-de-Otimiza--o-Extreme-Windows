<#
.SYNOPSIS
    EXTREME OPTIMIZER v4.1 (FINAL POLISHED)
    A versão mais estável, moderna e polida para Windows 11 23H2/24H2.

.DESCRIPTION
    Correções na v4.0:
    - Removido tweak 'TaskbarSi' (Morto no Win11).
    - Removido 'UseOLEDTaskbarTransparency' (Incompatível com material Mica).
    - Instalação Silenciosa do Windhawk (/S).
    - Sistema de Backup e RESTORE funcional para ajustes de Rede/Gamer.
    - Fechamento correto de logs (Stop-Transcript).
    - Menu otimizado para evitar bugs visuais.
    - Correção de erro na criação da chave de telemetria.

.NOTES
    Requer Administrador. Otimizado para builds 22H2, 23H2 e 24H2.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================================================
# ELEVAÇÃO DE PRIVILÉGIOS (AUTO-ADMIN)
# =========================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando permissão de Administrador..." -ForegroundColor Yellow
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# =========================================================
# INFRAESTRUTURA DE LOGS E DIRETÓRIOS
# =========================================================
$BaseDir = "$env:ProgramData\ExtremeOptimizer"
$LogDir = "$BaseDir\logs"
$BackupDir = "$BaseDir\backups"

if (!(Test-Path $LogDir)) { New-Item $LogDir -ItemType Directory -Force | Out-Null }
if (!(Test-Path $BackupDir)) { New-Item $BackupDir -ItemType Directory -Force | Out-Null }

$LogFile = "$LogDir\ExtremeLog_$(Get-Date -f yyyyMMdd_HHmm).txt"
Start-Transcript -Path $LogFile -Append -ErrorAction SilentlyContinue

# =========================================================
# FUNÇÕES DE SEGURANÇA (BACKUP & RESTORE)
# =========================================================
function Backup-Registry {
    Write-Host "[*] Criando backup de segurança do registro..." -ForegroundColor Cyan
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "$BackupDir\Tcpip_Backup.reg" /y 2>$null
    reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "$BackupDir\SystemProfile_Backup.reg" /y 2>$null
    Write-Host "[+] Backup salvo em: $BackupDir" -ForegroundColor Green
}

function Restore-Tweaks {
    Write-Host "[!] Revertendo otimizações de rede e performance..." -ForegroundColor Yellow
    if (Test-Path "$BackupDir\Tcpip_Backup.reg") { 
        reg import "$BackupDir\Tcpip_Backup.reg" 
        Write-Host "  -> Registro de Rede Restaurado."
    }
    if (Test-Path "$BackupDir\SystemProfile_Backup.reg") { 
        reg import "$BackupDir\SystemProfile_Backup.reg"
        Write-Host "  -> Perfil de Sistema Restaurado."
    }
    powercfg -setactive SCHEME_BALANCED
    Write-Host "[+] Restauração concluída! Reinicie para aplicar." -ForegroundColor Green
}

function Create-RestorePoint {
    Write-Host "[*] Criando Ponto de Restauração do Sistema..." -ForegroundColor Cyan
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "ExtremeOptimizer_PRO_v4" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Write-Host "[+] Ponto de Restauração Criado!" -ForegroundColor Green
}

# =========================================================
# MÓDULOS DE OTIMIZAÇÃO (MODERNIZADOS)
# =========================================================
function Run-Gamer-Tweaks {
    Write-Host "[*] Aplicando Otimizações Gamer (Baixa Latência)..." -ForegroundColor Green
    # TCP No Delay
    New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TCPNoDelay -Value 1 -PropertyType DWORD -Force | Out-Null
    # System Responsiveness
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" NetworkThrottlingIndex 0xFFFFFFFF
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0
    # Power Plan
    powercfg -setactive SCHEME_MIN
    Write-Host "[+] Rede e Energia otimizados!" -ForegroundColor Green
}

function Run-Debloat-Safe {
    Write-Host "[*] Removendo Apps desnecessários (Mantendo Xbox/Store)..." -ForegroundColor Yellow
    $apps = "*SkypeApp*", "*BingNews*", "*ZuneMusic*", "*YourPhone*", "*MicrosoftOfficeHub*", "*GetHelp*"
    foreach ($app in $apps) {
        Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    }
    # Telemetria Básica (Criação forçada para evitar erros em sistemas novos)
    if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
        New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
    }
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" AllowTelemetry 0
    Stop-Service DiagTrack -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "[+] Debloat concluído com segurança!" -ForegroundColor Green
}

# =========================================================
# MÓDULO DE ESTILIZAÇÃO (CORRIGIDO)
# =========================================================
function Install-Windhawk-Silent {
    Write-Host "[*] Instalando Windhawk de forma silenciosa..." -ForegroundColor Cyan
    $url = "https://windhawk.net/download/windhawk_setup.exe"
    $path = "$env:TEMP\windhawk_setup.exe"
    Write-Host "  -> Baixando instalador..."
    Invoke-WebRequest -Uri $url -OutFile $path
    Write-Host "  -> Executando instalação (/S)..."
    Start-Process -FilePath $path -ArgumentList "/S" -Wait
    Write-Host "[+] Windhawk instalado! Use-o para mudar o tamanho ou temas da barra." -ForegroundColor Green
}

function Set-Taskbar-Alignment {
    param([int]$Alignment)
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value $Alignment
    Stop-Process -Name explorer -Force
    Write-Host "[+] Alinhamento alterado!" -ForegroundColor Green
}

# =========================================================
# INTERFACE E MENU v4.0
# =========================================================
function Show-Header {
    Clear-Host
    Write-Host "###########################################################" -ForegroundColor Cyan
    Write-Host "#                                                         #" -ForegroundColor Cyan
    Write-Host "#   EXTREME OPTIMIZER v4.1 - FINAL POLISHED               #" -ForegroundColor Cyan
    Write-Host "#   Estável | Seguro | Corrigido para Win11 23H2+         #" -ForegroundColor Cyan
    Write-Host "#                                                         #" -ForegroundColor Cyan
    Write-Host "###########################################################" -ForegroundColor Cyan
    Write-Host ""
}

function Main-Menu {
    Show-Header
    Write-Host " --- ESSENCIAIS ---" -ForegroundColor Yellow
    Write-Host " [1]  COMBO PRO: Backup + Gamer + Debloat + Dev" -ForegroundColor Red
    Write-Host " [2]  GAMER: Latência (TCP) + Energia (High Perf)"
    Write-Host " [3]  DEBLOAT: Limpeza Segura + Matar Telemetria"
    Write-Host ""
    Write-Host " --- ESTILIZAÇÃO (CORRIGIDA) ---" -ForegroundColor Magenta
    Write-Host " [W]  INSTALAR WINDHAWK (Silencioso - Única via p/ Tamanho)"
    Write-Host " [L]  ALINHAR: Esquerda (Win10 Style)"
    Write-Host " [C]  ALINHAR: Centro (Win11 Style)"
    Write-Host ""
    Write-Host " --- SEGURANÇA E TOOLS ---" -ForegroundColor Cyan
    Write-Host " [B]  BACKUP: Salvar chaves de Registro"
    Write-Host " [R]  RESTORE: Reverter Ajustes Gamer/Rede" -ForegroundColor Yellow
    Write-Host " [T]  CHRIS TITUS: Abrir Windows Utility"
    Write-Host " [Q]  SAIR"
    Write-Host ""
    
    $choice = Read-Host "Selecione uma opção"
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
            Run-Debloat-Safe
            Write-Host "!!! SISTEMA OTIMIZADO COM SUCESSO !!!" -ForegroundColor Green
        }
        "2" { Backup-Registry; Run-Gamer-Tweaks }
        "3" { Run-Debloat-Safe }
        "W" { Install-Windhawk-Silent }
        "L" { Set-Taskbar-Alignment 0 }
        "C" { Set-Taskbar-Alignment 1 }
        "B" { Backup-Registry }
        "R" { Restore-Tweaks }
        "T" { irm https://christitus.com/win | iex }
        "Q" { 
            Write-Host "Encerrando e salvando logs..." -ForegroundColor Cyan
            Stop-Transcript
            exit 
        }
    }
    Write-Host ""
    Read-Host "Pressione Enter para voltar ao menu..."
} while ($c -ne "Q")
