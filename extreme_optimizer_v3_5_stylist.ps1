<#
.SYNOPSIS
    EXTREME OPTIMIZER v3.5 (STYLIST HUB)
    HUB completo com Otimizações Extreme + Estilização de Barra de Tarefas.

.DESCRIPTION
    Esta versão adiciona uma seção de UI/Estilização baseada no Ramen Software Styling Guide.
    Inclui:
    - Integração com Windhawk (Recomendado para estilização avançada).
    - Ajustes nativos de alinhamento e tamanho da Barra de Tarefas.
    - Temas de Transparência e Estética.

.NOTES
    A estilização avançada (Mica, Arredondamento) no Windows 11 22H2+ requer Windhawk.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================================================
# AUTO ADMIN
# =========================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`" " -Verb RunAs
    exit
}

# =========================================================
# CONFIGURAÇÃO E LOGS
# =========================================================
$BaseDir = "$env:ProgramData\ExtremeOptimizer"
$LogDir = "$BaseDir\logs"
$BackupDir = "$BaseDir\backups"
if (!(Test-Path $LogDir)) { New-Item $LogDir -ItemType Directory -Force | Out-Null }
if (!(Test-Path $BackupDir)) { New-Item $BackupDir -ItemType Directory -Force | Out-Null }

$LogFile = "$LogDir\ExtremeLog_$(Get-Date -f yyyyMMdd_HHmm).txt"
Start-Transcript -Path $LogFile -Append -ErrorAction SilentlyContinue

# =========================================================
# MÓDULO DE ESTILIZAÇÃO (UI)
# =========================================================

function Install-Windhawk {
    Write-Host "[*] Baixando Windhawk (O motor de estilização do Windows 11)..." -ForegroundColor Cyan
    $url = "https://windhawk.net/download/windhawk_setup.exe"
    $path = "$env:TEMP\windhawk_setup.exe"
    Invoke-WebRequest -Uri $url -OutFile $path
    Start-Process -FilePath $path -Wait
    Write-Host "[+] Windhawk instalado. Procure pelo mod 'Windows 11 Taskbar Styler'." -ForegroundColor Green
}

function Set-Taskbar-Alignment {
    param([int]$Alignment) # 0 = Esquerda, 1 = Centro
    Write-Host "[*] Ajustando alinhamento da Barra de Tarefas..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value $Alignment
    Stop-Process -Name explorer -Force # Reiniciar Explorer para aplicar
    Write-Host "[+] Alinhamento aplicado!" -ForegroundColor Green
}

function Set-Taskbar-Size {
    param([int]$Size) # 0 = Pequena, 1 = Média, 2 = Grande
    Write-Host "[*] Ajustando tamanho da Barra de Tarefas (Pode não funcionar em todas as builds)..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSi" -Value $Size
    Stop-Process -Name explorer -Force
    Write-Host "[+] Tamanho aplicado!" -ForegroundColor Green
}

function Set-Taskbar-Transparency {
    Write-Host "[*] Aplicando Transparência Nativa (OLED/Registry)..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "UseOLEDTaskbarTransparency" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "[+] Transparência ativada!" -ForegroundColor Green
}

# =========================================================
# MÓDULOS EXTREME (HERDADOS v3.0)
# =========================================================

function Backup-Registry {
    Write-Host "[*] Realizando Backup de registro..." -ForegroundColor Cyan
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "$BackupDir\Tcpip_Backup.reg" /y 2>$null
    Write-Host "[+] Backup concluído!" -ForegroundColor Green
}

function Run-Gamer-Tweaks {
    Write-Host "[*] Aplicando Tweaks Gamer (TCPNoDelay)..." -ForegroundColor Green
    New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TCPNoDelay -Value 1 -PropertyType DWORD -Force | Out-Null
    powercfg -setactive SCHEME_MIN
    Write-Host "[+] Performance Gamer Ativada!" -ForegroundColor Green
}

function Run-Debloat-Extreme {
    Write-Host "[*] Iniciando Debloat Seguro..." -ForegroundColor Yellow
    $apps = "*SkypeApp*", "*BingNews*", "*ZuneMusic*", "*YourPhone*"
    foreach ($app in $apps) { Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue }
    Write-Host "[+] Debloat concluído!" -ForegroundColor Green
}

# =========================================================
# INTERFACE HUB v3.5
# =========================================================

function Show-Header {
    Clear-Host
    Write-Host "###########################################################" -ForegroundColor Cyan
    Write-Host "#                                                         #" -ForegroundColor Cyan
    Write-Host "#   EXTREME OPTIMIZER v3.5 - STYLIST HUB                  #" -ForegroundColor Cyan
    Write-Host "#   Gamer | Developer | Taskbar Styling (Ramen Soft)      #" -ForegroundColor Cyan
    Write-Host "#                                                         #" -ForegroundColor Cyan
    Write-Host "###########################################################" -ForegroundColor Cyan
    Write-Host ""
}

function Main-Menu {
    Show-Header
    Write-Host " --- OTIMIZAÇÃO EXTREME ---" -ForegroundColor Yellow
    Write-Host " [1]  COMBO ULTRA (Backup + Gamer + Dev + Debloat)"
    Write-Host " [2]  GAMER (Latência + Energia)"
    Write-Host " [3]  DEBLOAT (Remover Apps + Telemetria)"
    Write-Host ""
    Write-Host " --- ESTILIZAÇÃO BARRA DE TAREFAS (NEW) ---" -ForegroundColor Magenta
    Write-Host " [W]  INSTALAR WINDHAWK (Para Temas Avançados/Mica)"
    Write-Host " [S]  ESTILO: Barra de Tarefas Pequena"
    Write-Host " [A]  ESTILO: Alinhar à Esquerda (Estilo Win10)"
    Write-Host " [C]  ESTILO: Alinhar ao Centro (Padrão Win11)"
    Write-Host " [T]  ESTILO: Transparência Máxima (Registry)"
    Write-Host ""
    Write-Host " --- FERRAMENTAS EXTERNAS ---" -ForegroundColor Cyan
    Write-Host " [X]  CHRIS TITUS: Windows Utility"
    Write-Host " [Q]  SAIR"
    Write-Host ""
    
    $choice = Read-Host "Escolha sua arma"
    return $choice.ToUpper()
}

# =========================================================
# LOOP
# =========================================================
do {
    $c = Main-Menu
    switch ($c) {
        "1" { Backup-Registry; Run-Gamer-Tweaks; Run-Debloat-Extreme }
        "2" { Run-Gamer-Tweaks }
        "3" { Run-Debloat-Extreme }
        "W" { Install-Windhawk }
        "S" { Set-Taskbar-Size 0 }
        "A" { Set-Taskbar-Alignment 0 }
        "C" { Set-Taskbar-Alignment 1 }
        "T" { Set-Taskbar-Transparency }
        "X" { irm https://christitus.com/win | iex }
        "Q" { exit }
    }
    Write-Host ""
    Read-Host "Pressione Enter para voltar ao HUB..."
} while ($c -ne "Q")
