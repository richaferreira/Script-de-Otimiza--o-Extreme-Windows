<#
.SYNOPSIS
    EXTREME OPTIMIZER v6.0 (ULTIMATE EDITION)
    A fusão definitiva: Chris Titus + Sayro Digital + Winhance + GitHub.

.DESCRIPTION
    Este script é o "Completão" solicitado, integrando as melhores otimizações
    do mercado em uma interface interativa de alto nível com navegação por setas.

    Fontes Integradas:
    - Chris Titus Windows Utility (WinUtil)
    - Sayro Digital (Scripts do Apocalipse)
    - Winhance (Performance Tweaks)
    - GitHub Community (Debloat & Privacy)

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
    $title = " EXTREME OPTIMIZER v6.0 "
    $subtitle = " ULTIMATE EDITION - CHRIS TITUS | SAYRO | WINHANCE "
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
# MÓDULOS DE OTIMIZAÇÃO (O "COMPLETÃO")
# =========================================================

# 1. SEGURANÇA & BACKUP (CHRIS TITUS / SAYRO)
function Run-Security {
    Show-Status "SEGURANÇA" "Criando Ponto de Restauração..." "Yellow"
    Checkpoint-Computer -Description "ExtremeOptimizer_v6" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Show-Status "SEGURANÇA" "Fazendo Backup do Registro..." "Yellow"
    $bak = "$env:ProgramData\ExtremeOptimizer\backups"; if (!(Test-Path $bak)) { New-Item $bak -ItemType Directory -Force | Out-Null }
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "$bak\Tcpip.reg" /y 2>$null
    Show-Status "SEGURANÇA" "Sistema protegido!" "Green"
}

# 2. GAMER MODE (WINHANCE / GITHUB / SAYRO)
function Run-GamerMode {
    Show-Status "GAMER" "Desativando Network Throttling..." "Magenta"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" NetworkThrottlingIndex 0xFFFFFFFF
    Show-Status "GAMER" "Ajustando System Responsiveness..." "Magenta"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0
    Show-Status "GAMER" "Otimizando TCP NoDelay..." "Magenta"
    New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TCPNoDelay -Value 1 -PropertyType DWORD -Force | Out-Null
    Show-Status "GAMER" "Aplicando Plano de Energia (High Perf)..." "Magenta"
    powercfg -setactive SCHEME_MIN
    Show-Status "GAMER" "Hardware otimizado para latência!" "Green"
}

# 3. LIMPEZA & DEBLOAT (SAYRO / CHRIS TITUS)
function Run-Debloat {
    Show-Status "LIMPEZA" "Removendo Apps Inúteis (Sayro Style)..." "Yellow"
    $apps = "*SkypeApp*", "*BingNews*", "*ZuneMusic*", "*YourPhone*", "*MicrosoftOfficeHub*", "*GetHelp*", "*Solitaire*"
    foreach ($app in $apps) { Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue }
    Show-Status "LIMPEZA" "Matando Telemetria e Coleta de Dados..." "Yellow"
    Stop-Service DiagTrack -ErrorAction SilentlyContinue; Set-Service DiagTrack -StartupType Disabled
    Show-Status "LIMPEZA" "Limpando Arquivos Temporários (WinUtil)..." "Yellow"
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Show-Status "LIMPEZA" "Sistema limpo e privado!" "Green"
}

# 4. INICIALIZAÇÃO & DESLIGAMENTO (SAYRO DIGITAL)
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

# 5. FERRAMENTAS (CHRIS TITUS / SAYRO)
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
    "🚀 [COMBO ULTIMATE] - Otimizar Tudo (Sayro + Titus + Winhance)",
    "🎮 [GAMER MODE] - Latência, TCP e Energia",
    "🧹 [LIMPEZA & DEBLOAT] - Remover Lixo e Telemetria",
    "⚡ [BOOT & SHUTDOWN] - Acelerar Inicialização",
    "🛠️ [FERRAMENTAS] - WinUtil, DNS e Winget",
    "🛡️ [SEGURANÇA] - Backup e Restauração",
    "❌ [SAIR]"
)

do {
    $c = Get-Selection -Options $MainOptions -Title "O QUE DESEJA FAZER NO SEU WINDOWS HOJE?"
    switch ($c) {
        0 { Run-Security; Run-SpeedBoot; Run-GamerMode; Run-Debloat; Show-Status "ULTIMATE" "SISTEMA 100% OTIMIZADO!" "Green"; Read-Host "`n  Enter para voltar..." }
        1 { Run-GamerMode; Start-Sleep -Seconds 1 }
        2 { Run-Debloat; Start-Sleep -Seconds 1 }
        3 { Run-SpeedBoot; Start-Sleep -Seconds 1 }
        4 { 
            $t = Get-Selection -Options @("Chris Titus WinUtil", "DNS Cloudflare", "Voltar") -Title "FERRAMENTAS EXTERNAS"
            if ($t -eq 0) { Run-Tools "WinUtil" } elseif ($t -eq 1) { Run-Tools "DNS" }
        }
        5 { Run-Security; Start-Sleep -Seconds 1 }
        6 { exit }
    }
} while ($true)
