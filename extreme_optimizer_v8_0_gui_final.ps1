$ErrorActionPreference = 'Stop'

# =========================================================
# SOLICITAÇÃO DE PRIVILÉGIOS DE ADMINISTRADOR
# =========================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Solicitando privilégios de Administrador..."
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# =========================================================
# FUNÇÕES DO EXTREME OPTIMIZER v8.0
# =========================================================

function Show-Status-GUI {
    param([string]$Module, [string]$Msg, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $output = "[$timestamp] [$($Module.ToUpper().PadRight(10))] $Msg`n"
    
    # Adicionando texto com cor no RichTextBox
    $script:OutputTextBox.SelectionStart = $script:OutputTextBox.TextLength
    $script:OutputTextBox.SelectionLength = 0
    
    # Conversão segura de cor (Se der erro, usa Branco)
    try { $script:OutputTextBox.SelectionColor = [System.Drawing.ColorFromName]($Color) } 
    catch { $script:OutputTextBox.SelectionColor = [System.Drawing.Color]::White }
    
    $script:OutputTextBox.AppendText($output)
    $script:OutputTextBox.SelectionColor = $script:OutputTextBox.ForeColor # Reseta a cor
    $script:OutputTextBox.ScrollToCaret()

    # Mantém a UI responsiva sem congelar
    [System.Windows.Forms.Application]::DoEvents()
}

function Create-RestorePoint-GUI {
    Show-Status-GUI "SEGURANÇA" "Criando Ponto de Restauração do Sistema..." "Yellow"
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "ExtremeOptimizer_v8" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Show-Status-GUI "SEGURANÇA" "Ponto de Restauração Criado!" "Green"
}

function Run-Security-GUI {
    Show-Status-GUI "SEGURANÇA" "Fazendo Backup do Registro..." "Yellow"
    $BackupDir = "$env:ProgramData\ExtremeOptimizer\backups"
    if (!(Test-Path $BackupDir)) { New-Item $BackupDir -ItemType Directory -Force | Out-Null }
    reg export "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" "$BackupDir\Tcpip.reg" /y 2>$null
    Show-Status-GUI "SEGURANÇA" "Backup do Registro salvo em: $BackupDir" "Green"
}

function Run-GamerMode-GUI {
    Show-Status-GUI "GAMER" "Aplicando Otimizações Gamer..." "Magenta"
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" NetworkThrottlingIndex 0xFFFFFFFF -ErrorAction SilentlyContinue
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0 -ErrorAction SilentlyContinue
    New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" TCPNoDelay -Value 1 -PropertyType DWORD -Force | Out-Null
    powercfg -setactive SCHEME_MIN
    reg add "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "24" /f >$null
    bcdedit /set useplatformtick No >$null
    bcdedit /set disabledynamictick Yes >$null
    bcdedit /set hypervisorlaunchtype off >$null
    bcdedit /set quietboot On >$null
    Show-Status-GUI "GAMER" "Hardware otimizado para latência!" "Green"
}

function Run-DeveloperMode-GUI {
    Show-Status-GUI "DEV" "Otimizando prioridade de processos (VS Code, Docker)..." "Cyan"
    reg add "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f >$null
    reg add "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "SecondLevelDataCache" /t REG_DWORD /d "0" /f >$null
    Get-Service -Name "RasMan" -ErrorAction SilentlyContinue | Stop-Service -Force
    Get-Service -Name "RasMan" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Get-Service -Name "RemoteAccess" -ErrorAction SilentlyContinue | Stop-Service -Force
    Get-Service -Name "RemoteAccess" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "SysMain" -ErrorAction SilentlyContinue
    Show-Status-GUI "DEV" "Ambiente de desenvolvimento otimizado!" "Green"
}

function Install-WingetPrograms-GUI {
    Show-Status-GUI "PROGRAMAS" "Instalando programas essenciais via Winget..." "Cyan"
    $programs = @("Google.Chrome", "Mozilla.Firefox", "Discord.Discord", "Telegram.TelegramDesktop", "WhatsApp.WhatsApp", "Microsoft.VisualStudioCode", "Git.Git", "7zip.7zip", "VideoLAN.VLC")
    foreach ($program in $programs) {
        Show-Status-GUI "PROGRAMAS" "  -> Instalando $program..." "Yellow"
        winget install --id $program --source winget --accept-package-agreements --accept-source-agreements -e -h --silent -ErrorAction SilentlyContinue
    }
    Show-Status-GUI "PROGRAMAS" "Instalação de programas concluída!" "Green"
}

function Set-DNS-Servers-GUI {
    param([string]$PrimaryDNS, [string]$SecondaryDNS)
    Show-Status-GUI "DNS" "Configurando servidores DNS ($PrimaryDNS / $SecondaryDNS)..." "Cyan"
    Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | ForEach-Object {
        Set-DnsClientServerAddress -InterfaceAlias $_.Name -ServerAddresses ($PrimaryDNS, $SecondaryDNS) -ErrorAction SilentlyContinue
    }
    Show-Status-GUI "DNS" "Configuração de DNS concluída!" "Green"
}

function Apply-Hardware-Tweaks-GUI {
    Show-Status-GUI "HARDWARE" "Aplicando tweaks de hardware (NVIDIA/AMD)..." "Cyan"
    Get-Service -Name "NvTelemetryContainer" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    $ULPSKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"
    if (Test-Path $ULPSKey) { Set-ItemProperty -Path $ULPSKey -Name "EnableUlps" -Value 0 -ErrorAction SilentlyContinue }
    Show-Status-GUI "HARDWARE" "Tweaks de hardware aplicados!" "Green"
}

function Apply-UI-Enhancements-GUI {
    Show-Status-GUI "UI" "Aplicando melhorias de UI..." "Cyan"
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarEndTask" -Value 1 -PropertyType DWORD -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "Link" -Value 0 -PropertyType Binary -Force | Out-Null
    Show-Status-GUI "UI" "Melhorias de UI aplicadas!" "Green"
}

function Restore-Tweaks-GUI {
    Show-Status-GUI "RESTORE" "Revertendo otimizações de rede e performance..." "Yellow"
    $BackupDir = "$env:ProgramData\ExtremeOptimizer\backups"
    if (Test-Path "$BackupDir\Tcpip.reg") { 
        reg import "$BackupDir\Tcpip.reg" 
        Show-Status-GUI "RESTORE" "  -> Registro de Rede Restaurado." "Green"
    }
    
    powercfg -setactive SCHEME_BALANCED
    Show-Status-GUI "RESTORE" "Restauração concluída! Reinicie para aplicar." "Green"
}

function Run-Debloat-GUI {
    Show-Status-GUI "LIMPEZA" "Removendo Apps Inúteis e Telemetria..." "Yellow"
    $apps = "*SkypeApp*", "*BingNews*", "*ZuneMusic*", "*YourPhone*", "*MicrosoftOfficeHub*", "*GetHelp*", "*Solitaire*", "*Microsoft.Windows.Photos*", "*Microsoft.ZuneVideo*"
    foreach ($app in $apps) { Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue }
    
    Stop-Service DiagTrack -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    
    reg add "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f >$null
    reg add "HKLM:\Software\Policies\Microsoft\Edge" /v "DiagnosticData" /t REG_DWORD /d "0" /f >$null
    reg add "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Windows\Win32kWPP\Parameters" /v "LogPages" /t REG_DWORD /d "0" /f >$null
    reg add "HKLM:\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" /v "LogPages" /t REG_DWORD /d "0" /f >$null
    
    Set-Service -Name "WaaSMedicSvc" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "WaaSMedicSvc" -ErrorAction SilentlyContinue
    
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Show-Status-GUI "LIMPEZA" "Sistema limpo e privado!" "Green"
}

function Run-Tools-GUI {
    param($tool)
    if ($tool -eq "WinUtil") {
        Show-Status-GUI "TOOLS" "Abrindo Chris Titus Utility em nova janela..." "Cyan"
        # Abre em um processo separado para evitar o congelamento da GUI principal (conflito de Thread WinForms vs WPF)
        Start-Process powershell -ArgumentList "-NoProfile -Command `"irm https://christitus.com/win | iex`""
        Show-Status-GUI "TOOLS" "Chris Titus Utility iniciado!" "Green"
    }
}

function Set-Taskbar-Alignment-GUI {
    param([int]$Alignment)
    Show-Status-GUI "UI" "Alterando alinhamento da barra de tarefas..." "Cyan"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value $Alignment -ErrorAction SilentlyContinue
    Stop-Process -Name explorer -Force
    Show-Status-GUI "UI" "Alinhamento da barra de tarefas alterado!" "Green"
}

function Run-SpeedBoot-GUI {
    Show-Status-GUI "BOOT" "Acelerando Inicialização e Desligamento..." "Cyan"
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
    if (!(Test-Path $path)) { New-Item $path -Force | Out-Null }
    Set-ItemProperty $path StartupDelayInMSec -Value 0 -PropertyType DWORD
    Set-ItemProperty "HKCU:\Control Panel\Desktop" AutoEndTasks -Value 1
    Set-ItemProperty "HKCU:\Control Panel\Desktop" WaitToKillAppTimeout -Value 2000
    Show-Status-GUI "BOOT" "Boot e Shutdown acelerados!" "Green"
}

function Install-Windhawk-With-Theme-GUI {
    param([string]$ThemeName)
    Show-Status-GUI "STYLIST" "Iniciando Auto-Stylist: Instalando Windhawk e Tema $ThemeName..." "Magenta"
    
    $url = "https://windhawk.net/download/windhawk_setup.exe"
    $path = "$env:TEMP\windhawk_setup.exe"
    if (!(Test-Path $path)) {
        Show-Status-GUI "STYLIST" "Baixando instalador do Windhawk..." "Yellow"
        Invoke-WebRequest -Uri $url -OutFile $path
    }
    Show-Status-GUI "STYLIST" "Instalando Windhawk Silenciosamente..." "Yellow"
    Start-Process -FilePath $path -ArgumentList "/S" -Wait
    
    Show-Status-GUI "STYLIST" "Aguardando inicialização do motor do Windhawk..." "Yellow"
    Start-Sleep -Seconds 5

    $Mods = @{
        "WIN10" = "taskbar-height-and-icon-size"
        "TRANSPARENT" = "windows-11-taskbar-styler"
        "ROUNDED" = "taskbar-styler"
    }

    $ModID = $Mods[$ThemeName]
    if (!$ModID) {
        Show-Status-GUI "STYLIST" "[!] Tema desconhecido. Windhawk instalado com sucesso." "Green"
        return
    }

    $RegistryPath = "HKLM:\SOFTWARE\Windhawk\Engine\Mods\$ModID"
    if (!(Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force -ErrorAction SilentlyContinue | Out-Null }

    Set-ItemProperty -Path $RegistryPath -Name "Enabled" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
    
    $SettingsPath = "$RegistryPath\Settings"
    if (!(Test-Path $SettingsPath)) { New-Item -Path $SettingsPath -Force -ErrorAction SilentlyContinue | Out-Null }

    switch ($ThemeName) {
        "WIN10" {
            Set-ItemProperty -Path $SettingsPath -Name "taskbarHeight" -Value 30 -PropertyType DWORD -Force
            Set-ItemProperty -Path $SettingsPath -Name "iconSize" -Value 24 -PropertyType DWORD -Force
        }
        "TRANSPARENT" {
            Set-ItemProperty -Path $SettingsPath -Name "background-color" -Value "#00000000" -PropertyType String -Force
        }
        "ROUNDED" {
            Set-ItemProperty -Path $SettingsPath -Name "border-radius" -Value 15 -PropertyType DWORD -Force
        }
    }

    Set-ItemProperty -Path $RegistryPath -Name "SettingsChangeTime" -Value (Get-Date).Ticks -PropertyType QWORD -Force -ErrorAction SilentlyContinue

    Show-Status-GUI "STYLIST" "[+] Windhawk configurado com o tema $ThemeName!" "Green"
    Show-Status-GUI "STYLIST" "[!] IMPORTANTE: O Windhawk baixará o código do mod ao ser aberto pela primeira vez." "Yellow"
}

# =========================================================
# CONFIGURAÇÃO DA GUI v8.0
# =========================================================
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Extreme Optimizer v8.0 - GUI Hybrid Edition"
$Form.Size = New-Object System.Drawing.Size(820, 640)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "FixedSingle"
$Form.MaximizeBox = $false
$Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#1F1F1F")

# Título
$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Text = "EXTREME OPTIMIZER v8.0"
$TitleLabel.Font = New-Object System.Drawing.Font("Segoe UI Light", 20)
$TitleLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#00BFFF") # DeepSkyBlue
$TitleLabel.AutoSize = $true
$TitleLabel.Location = New-Object System.Drawing.Point(10, 10)
$Form.Controls.Add($TitleLabel)

# Subtítulo
$SubtitleLabel = New-Object System.Windows.Forms.Label
$SubtitleLabel.Text = "GUI Hybrid Edition - Dev & Gaming"
$SubtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$SubtitleLabel.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#9E9E9E") # Gray
$SubtitleLabel.AutoSize = $true
$SubtitleLabel.Location = New-Object System.Drawing.Point(12, 50)
$Form.Controls.Add($SubtitleLabel)

# Caixa de Logs (Alterado de TextBox para RichTextBox para suportar cores)
$script:OutputTextBox = New-Object System.Windows.Forms.RichTextBox
$script:OutputTextBox.Location = New-Object System.Drawing.Point(250, 90)
$script:OutputTextBox.Size = New-Object System.Drawing.Size(540, 490)
$script:OutputTextBox.ReadOnly = $true
$script:OutputTextBox.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#2D2D30")
$script:OutputTextBox.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#E0E0E0")
$script:OutputTextBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$Form.Controls.Add($script:OutputTextBox)

# Painel de Botões
$ButtonPanel = New-Object System.Windows.Forms.Panel
$ButtonPanel.Location = New-Object System.Drawing.Point(10, 90)
$ButtonPanel.Size = New-Object System.Drawing.Size(230, 490)
$ButtonPanel.AutoScroll = $true # CORREÇÃO: Adicionado scroll para exibir todos os botões
$Form.Controls.Add($ButtonPanel)

# =========================================================
# CRIAÇÃO DOS BOTÕES (ESTILO MODERNO)
# =========================================================
$currentY = 0

function Create-Modern-Button {
    param([string]$Text, [scriptblock]$Action)
    $Button = New-Object System.Windows.Forms.Button
    $Button.Text = "  $Text"
    $Button.TextAlign = "MiddleLeft"
    $Button.Location = New-Object System.Drawing.Point(0, $script:currentY)
    $Button.Size = New-Object System.Drawing.Size(210, 40) # Leve recuo no Size para não cortar no scroll
    $Button.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#333333")
    $Button.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#FFFFFF")
    $Button.FlatStyle = "Flat"
    $Button.FlatAppearance.BorderSize = 0
    $Button.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 9)
    $Button.add_Click($Action)
    $ButtonPanel.Controls.Add($Button)
    $script:currentY += 45
}

# Botões
Create-Modern-Button "🚀 COMBO HÍBRIDO" { 
    Show-Status-GUI "GUI" "Iniciando COMBO HÍBRIDO..." "Yellow"
    Create-RestorePoint-GUI
    Run-Security-GUI
    Run-SpeedBoot-GUI
    Run-GamerMode-GUI
    Run-DeveloperMode-GUI
    Run-Debloat-GUI
    Show-Status-GUI "GUI" "COMBO HÍBRIDO CONCLUÍDO!" "Green"
}

Create-Modern-Button "🎮 GAMER MODE" { Run-GamerMode-GUI }
Create-Modern-Button "💻 DEVELOPER MODE" { Run-DeveloperMode-GUI }
Create-Modern-Button "🧹 LIMPEZA & DEBLOAT" { Run-Debloat-GUI }
Create-Modern-Button "⚡ BOOT & SHUTDOWN" { Run-SpeedBoot-GUI }

$script:currentY += 10 # Separador

Create-Modern-Button "🎨 TEMA: BARRA WIN10" { Install-Windhawk-With-Theme-GUI "WIN10" }
Create-Modern-Button "🎨 TEMA: TRANSPARENTE" { Install-Windhawk-With-Theme-GUI "TRANSPARENT" }
Create-Modern-Button "🎨 TEMA: ARREDONDADA" { Install-Windhawk-With-Theme-GUI "ROUNDED" }

$script:currentY += 10 # Separador

Create-Modern-Button "⚙️ ALINHAR BARRA: ESQUERDA" { Set-Taskbar-Alignment-GUI 0 }
Create-Modern-Button "⚙️ ALINHAR BARRA: CENTRO" { Set-Taskbar-Alignment-GUI 1 }

$script:currentY += 10 # Separador

Create-Modern-Button "PÓS-FORMATAÇÃO: PROGRAMAS" { Install-WingetPrograms-GUI }
Create-Modern-Button "PÓS-FORMATAÇÃO: DNS GOOGLE" { Set-DNS-Servers-GUI "8.8.8.8" "8.8.4.4" }
Create-Modern-Button "PÓS-FORMATAÇÃO: DNS CLOUDFLARE" { Set-DNS-Servers-GUI "1.1.1.1" "1.0.0.1" }
Create-Modern-Button "PÓS-FORMATAÇÃO: DNS QUAD9" { Set-DNS-Servers-GUI "9.9.9.9" "149.112.112.112" }
Create-Modern-Button "PÓS-FORMATAÇÃO: HARDWARE" { Apply-Hardware-Tweaks-GUI }
Create-Modern-Button "PÓS-FORMATAÇÃO: UI" { Apply-UI-Enhancements-GUI }

$script:currentY += 10 # Separador

Create-Modern-Button "🛠️ CHRIS TITUS WINUTIL" { Run-Tools-GUI "WinUtil" }

$script:currentY += 10 # Separador

Create-Modern-Button "🛡️ CRIAR PONTO RESTAURAÇÃO" { Create-RestorePoint-GUI }
Create-Modern-Button "🛡️ BACKUP REGISTRO" { Run-Security-GUI }
Create-Modern-Button "↩️ RESTAURAR TWEAKS" { Restore-Tweaks-GUI }

$script:currentY += 10 # Separador

Create-Modern-Button "❌ SAIR" { $Form.Close() }

# =========================================================
# EXIBIR A GUI
# =========================================================
Show-Status-GUI "GUI" "Extreme Optimizer v8.0 inicializado com sucesso!" "Green"
$Form.ShowDialog() | Out-Null