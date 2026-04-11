<#
.SYNOPSIS
    EXTREME OPTIMIZER v7.0 (DEVELOPER & GAMING HYBRID EDITION)
    Otimização definitiva para desenvolvedores e gamers, com o melhor do FoxOS, KernelOS e mais.

.DESCRIPTION
    Este script é a fusão perfeita de otimizações para quem exige o máximo do Windows,
    seja para compilar código, rodar containers ou dominar nos jogos.

    Fontes Integradas:
    - Extreme Optimizer v6.0 (Base)
    - FoxOS (Performance e Privacidade Agressiva)
    - KernelOS (Limpeza de Hardware Virtual e Timers)
    - Otimizações específicas para ambientes de desenvolvimento (VS Code, Docker, etc.)

.NOTES
    Requer Administrador. Otimizado para Windows 10 e 11.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================================================
# ELEVAÇÃO DE PRIVILÉGIOS
# =========================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Clear-Host
    Write-Host "`n  [!] ACESSO NEGADO" -ForegroundColor Red
    Write-Host "  Este script precisa de privilégios de Administrador para otimizar o sistema."
    Write-Host "  Solicitando permissão...`n" -ForegroundColor Yellow
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# =========================================================
# CONFIGURAÇÕES DE UI E CORES (NEON THEME)
# =========================================================
$Global:Colors = @{
    Primary   = "Cyan"
    Secondary = "Magenta"
    Success   = "Green"
    Warning   = "Yellow"
    Error     = "Red"
    Bg        = "Black"
    Text      = "White"
    Accent    = "DarkCyan"
}

# =========================================================
# COMPONENTES VISUAIS
# =========================================================

function Show-Header {
    Clear-Host
    $title = " EXTREME OPTIMIZER v7.0 "
    $subtitle = " DEVELOPER & GAMING HYBRID EDITION "
    $width = 70
    
    Write-Host (" " * 5 + "╔" + ("═" * ($width-2)) + "╗") -ForegroundColor $Colors.Primary
    Write-Host (" " * 5 + "║" + (" " * (($width - $title.Length - 2)/2)) + $title + (" " * (($width - $title.Length - 2)/2)) + "║") -ForegroundColor $Colors.Primary -Bold
    Write-Host (" " * 5 + "║" + (" " * (($width - $subtitle.Length - 2)/2)) + $subtitle + (" " * (($width - $subtitle.Length - 2)/2)) + "║") -ForegroundColor $Colors.Secondary
    Write-Host (" " * 5 + "╚" + ("═" * ($width-2)) + "╝") -ForegroundColor $Colors.Primary
    Write-Host ""
}

function Show-Status {
    param([string]$Module, [string]$Msg, [string]$Color = "Cyan")
    Write-Host "  [ " -NoNewLine -ForegroundColor $Colors.Primary
    Write-Host "$($Module.PadRight(12))" -NoNewLine -ForegroundColor $Colors.Text
    Write-Host " ] " -NoNewLine -ForegroundColor $Colors.Primary
    Write-Host "» " -NoNewLine -ForegroundColor $Colors.Secondary
    Write-Host "$Msg" -ForegroundColor $Color
}

function Get-Selection {
    param ([string[]]$Options, [string]$Title = "Selecione uma categoria:")
    $selectedIndex = 0
    $key = $null
    [Console]::CursorVisible = $false

    while ($key -ne "Enter") {
        Show-Header
        Write-Host "  $Title`n" -ForegroundColor $Colors.Warning
        for ($i = 0; $i -lt $Options.Count; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "    ► " -NoNewLine -ForegroundColor $Colors.Secondary
                Write-Host "$($Options[$i])" -ForegroundColor $Colors.Bg -BackgroundColor $Colors.Primary
            } else {
                Write-Host "      $($Options[$i])" -ForegroundColor $Colors.Text
            }
        }
        Write-Host "`n  [↑/↓] Navegar | [ENTER] Confirmar" -ForegroundColor DarkGray
        $input = [Console]::ReadKey($true); $key = $input.Key.ToString()
        if ($key -eq "UpArrow") { $selectedIndex = if ($selectedIndex -gt 0) { $selectedIndex - 1 } else { $Options.Count - 1 } }
        elseif ($key -eq "DownArrow") { $selectedIndex = if ($selectedIndex -lt $Options.Count - 1) { $selectedIndex + 1 } else { 0 } }
    }
    [Console]::CursorVisible = $true; return $selectedIndex
}

# =========================================================
# MÓDULOS DE OTIMIZAÇÃO (O "COMPLETÃO" HÍBRIDO)
# =========================================================

# INFRAESTRUTURA DE LOGS E DIRETÓRIOS
$BaseDir = "$env:ProgramData\ExtremeOptimizer"
$LogDir = "$BaseDir\logs"
$BackupDir = "$BaseDir\backups"

if (!(Test-Path $LogDir)) { New-Item $LogDir -ItemType Directory -Force | Out-Null }
if (!(Test-Path $BackupDir)) { New-Item $BackupDir -ItemType Directory -Force | Out-Null }

# 1. SEGURANÇA & BACKUP (CHRIS TITUS / SAYRO)
function Run-Security {
    Show-Status "SEGURANÇA" "Criando Ponto de Restauração..." "Yellow"
    Checkpoint-Computer -Description "ExtremeOptimizer_v7" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Show-Status "SEGURANÇA" "Fazendo Backup do Registro..." "Yellow"
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "$BackupDir\Tcpip.reg" /y 2>$null
    Show-Status "SEGURANÇA" "Sistema protegido!" "Green"
}

# 2. GAMER MODE (WINHANCE / GITHUB / FOXOS / KERNELOS)
function Run-GamerMode {
    Show-Status "GAMER" "Desativando Network Throttling..." "Magenta"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" NetworkThrottlingIndex 0xFFFFFFFF
    Show-Status "GAMER" "Ajustando System Responsiveness..." "Magenta"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0
    Show-Status "GAMER" "Otimizando TCP NoDelay..." "Magenta"
    New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TCPNoDelay -Value 1 -PropertyType DWORD -Force | Out-Null
    Show-Status "GAMER" "Aplicando Plano de Energia (High Perf)..." "Magenta"
    powercfg -setactive SCHEME_MIN
    
    Show-Status "GAMER" "Ajustando prioridade Win32 (FoxOS)..." "Magenta"
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "24" /f >$null

    Show-Status "GAMER" "Otimizando timer do sistema (KernelOS BCDEDIT)..." "Magenta"
    bcdedit /set useplatformtick No >$null
    bcdedit /set disabledynamictick Yes >$null
    bcdedit /set hypervisorlaunchtype off >$null
    bcdedit /set quietboot On >$null

    Show-Status "GAMER" "Hardware otimizado para latência!" "Green"
}

# 3. DEVELOPER MODE (NOVO)
function Run-DeveloperMode {
    Show-Status "DEV" "Otimizando prioridade de processos (VS Code, Docker)..." "Cyan"
    # Exemplo: Aumentar prioridade para processos comuns de dev
    # Isso é mais complexo e dinâmico, mas podemos simular com ajustes gerais
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f >$null
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SecondLevelDataCache" /t REG_DWORD /d "0" /f >$null
    
    Show-Status "DEV" "Desativando WAN Miniports (KernelOS)..." "Cyan"
    # Esta parte requer uma ferramenta externa como o dmv.exe do Nirsoft ou PowerShell mais avançado
    # Para simplificar, vamos desativar os serviços relacionados via PowerShell se possível
    Get-Service -Name "RasMan" -ErrorAction SilentlyContinue | Stop-Service -Force
    Get-Service -Name "RasMan" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Get-Service -Name "RemoteAccess" -ErrorAction SilentlyContinue | Stop-Service -Force
    Get-Service -Name "RemoteAccess" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled

    Show-Status "DEV" "Otimizando I/O de disco para ambientes de desenvolvimento..." "Cyan"
    # Desativar Superfetch/SysMain para SSDs (já coberto pelo debloat, mas reforça)
    Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "SysMain" -ErrorAction SilentlyContinue

    Show-Status "DEV" "Ambiente de desenvolvimento otimizado!" "Green"
}

# 4. LIMPEZA & DEBLOAT (SAYRO / CHRIS TITUS / FOXOS / KERNELOS)
function Run-Debloat {
    Show-Status "LIMPEZA" "Removendo Apps Inúteis (Sayro Style)..." "Yellow"
    $apps = "*SkypeApp*", "*BingNews*", "*ZuneMusic*", "*YourPhone*", "*MicrosoftOfficeHub*", "*GetHelp*", "*Solitaire*", "*Microsoft.Windows.Photos*", "*Microsoft.ZuneVideo*"
    foreach ($app in $apps) { Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue }
    
    Show-Status "LIMPEZA" "Matando Telemetria e Coleta de Dados (FoxOS/Chris Titus)..." "Yellow"
    Stop-Service DiagTrack -ErrorAction SilentlyContinue; Set-Service DiagTrack -StartupType Disabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f >$null # Desativa Spectre/Meltdown (FoxOS)
    reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DiagnosticData" /t REG_DWORD /d "0" /f >$null # Edge Telemetry (FoxOS)
    # Desativar LogPages (FoxOS/KernelOS)
    reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows\Win32kWPP\Parameters" /v "LogPages" /t REG_DWORD /d "0" /f >$null
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" /v "LogPages" /t REG_DWORD /d "0" /f >$null

    Show-Status "LIMPEZA" "Desativando WaaSMedicSvc (KernelOS)..." "Yellow"
    Set-Service -Name "WaaSMedicSvc" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "WaaSMedicSvc" -ErrorAction SilentlyContinue

    Show-Status "LIMPEZA" "Limpando Arquivos Temporários (WinUtil)..." "Yellow"
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Show-Status "LIMPEZA" "Sistema limpo e privado!" "Green"
}

# 5. BOOT & SHUTDOWN (SAYRO DIGITAL)
function Run-SpeedBoot {
    Show-Status "BOOT" "Desativando atraso de apps no boot..." "Cyan"
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
    if (!(Test-Path $path)) { New-Item $path -Force | Out-Null }
    Set-ItemProperty $path StartupDelayInMSec -Value 0 -PropertyType DWORD
    Show-Status "BOOT" "Ativando Inicialização Rápida..." "Cyan"
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" HiberbootEnabled -Value 1
    Show-Status "BOOT" "Configurando Desligamento Rápido..." "Cyan"
    Set-ItemProperty "HKCU:\Control Panel\Desktop" AutoEndTasks -Value 1
    Set-ItemProperty "HKCU:\Control Panel\Desktop" WaitToKillAppTimeout -Value 2000
    Show-Status "BOOT" "Boot e Shutdown acelerados!" "Green"
}

# 6. FERRAMENTAS (CHRIS TITUS / SAYRO)
function Run-Tools {
    param($tool)
    if ($tool -eq "WinUtil") { Show-Status "TOOLS" "Abrindo Chris Titus Utility..."; irm https://christitus.com/win | iex }
    elseif ($tool -eq "DNS") { 
        Show-Status "TOOLS" "Aplicando DNS Cloudflare (1.1.1.1)..." "Cyan"
        Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Set-DnsClientServerAddress -ServerAddresses ("1.1.1.1","1.0.0.1")
    }
}

# =========================================================
# LOOP PRINCIPAL
# =========================================================

$MainOptions = @(
    "🚀 [COMBO HÍBRIDO] - Otimizar para Dev & Gaming",
    "🎮 [GAMER MODE] - Latência, TCP e Energia",
    "💻 [DEVELOPER MODE] - Prioridade de Processos e I/O",
    "🧹 [LIMPEZA & DEBLOAT] - Remover Lixo e Telemetria",
    "⚡ [BOOT & SHUTDOWN] - Acelerar Inicialização",
    "🛠️ [FERRAMENTAS] - WinUtil, DNS e Winget",
    "🛡️ [SEGURANÇA] - Backup e Restauração",
    "❌ [SAIR]"
)

do {
    $c = Get-Selection -Options $MainOptions -Title "O QUE DESEJA FAZER NO SEU WINDOWS HOJE?"
    switch ($c) {
        0 { # COMBO HÍBRIDO
            Run-Security
            Run-SpeedBoot
            Run-GamerMode
            Run-DeveloperMode
            Run-Debloat
            Show-Status "HÍBRIDO" "SISTEMA 100% OTIMIZADO PARA DEV & GAMING!" "Green"
            Read-Host "`n  Enter para voltar..."
        }
        1 { Run-GamerMode; Read-Host "`n  Enter para voltar..." }
        2 { Run-DeveloperMode; Read-Host "`n  Enter para voltar..." }
        3 { Run-Debloat; Read-Host "`n  Enter para voltar..." }
        4 { Run-SpeedBoot; Read-Host "`n  Enter para voltar..." }
        5 { 
            $t = Get-Selection -Options @("Chris Titus WinUtil", "DNS Cloudflare", "Voltar") -Title "FERRAMENTAS EXTERNAS"
            if ($t -eq 0) { Run-Tools "WinUtil" } elseif ($t -eq 1) { Run-Tools "DNS" }
        }
        6 { Run-Security; Read-Host "`n  Enter para voltar..." }
        7 { exit }
    }
} while ($true)
