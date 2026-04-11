
# Extreme Optimizer v8.0 - GUI Hybrid Edition

Esta é a versão com Interface Gráfica (GUI) do Extreme Optimizer, combinando as otimizações das versões v7.0 (Developer & Gaming Hybrid) e v4.6 (Auto-Stylist) em uma experiência visual intuitiva.

---

## 🚀 Visão Geral

A v8.0 é a culminação de uma análise aprofundada de diversas metodologias de otimização, resultando em um ambiente Windows que se destaca tanto na execução de softwares de desenvolvimento de alta demanda (como Visual Studio Code, Docker, MongoDB, Python, Java e Node.js) quanto na entrega de uma experiência de jogo fluida, com baixa latência e alta taxa de quadros.



---

## 📊 Estratégias de Otimização de RAM e CPU

O script emprega uma combinação de técnicas para garantir que o sistema operacional utilize seus recursos de forma mais eficiente:

| Área de Otimização | Ação do Script | Impacto na RAM/CPU | Módulo Principal |
| :----------------- | :------------- | :----------------- | :--------------- |
| **Serviços de Telemetria** | Desativação do serviço `DiagTrack` (Experiências do Usuário Conectado e Telemetria). | Reduz o consumo constante de CPU e RAM associado à coleta e envio de dados para a Microsoft. | `Run-Debloat` |
| **Aplicativos Pré-instalados (Bloatware)** | Remoção de aplicativos UWP desnecessários (SkypeApp, BingNews, YourPhone, Solitaire, etc.). | Libera RAM que seria ocupada por esses aplicativos rodando em segundo plano e reduz o uso de CPU por processos em segundo plano. | `Run-Debloat` |
| **Gerenciamento de Cache de Disco** | Desativação do serviço `SysMain` (Superfetch/Prefetch). | Em sistemas com SSD, evita o pré-carregamento desnecessário de dados na RAM, liberando memória e reduzindo I/O de disco, o que impacta diretamente a CPU. | `Run-DeveloperMode` |
| **Serviços de Acesso Remoto** | Desativação dos serviços `RasMan` (Gerenciador de Conexão de Acesso Remoto) e `RemoteAccess`. | Libera RAM e CPU que seriam consumidas por esses serviços, especialmente se o usuário não utiliza VPNs ou acesso remoto. | `Run-DeveloperMode` |
| **Prioridade de Processos** | Ajuste de `Win32PrioritySeparation` para priorizar aplicativos em primeiro plano. | Garante que aplicações ativas (jogos, IDEs, Docker) recebam mais ciclos de CPU, melhorando a responsividade e desempenho. | `Run-GamerMode` |
| **Otimização de Rede** | Desativação de `NetworkThrottlingIndex` e WAN Miniports (indiretamente via desativação de `RasMan`/`RemoteAccess`). | Reduz o processamento de rede desnecessário, liberando CPU e melhorando a latência. | `Run-GamerMode`, `Run-DeveloperMode` |
| **Virtualização (Hyper-V)** | Desativação de `hypervisorlaunchtype off` via BCDEDIT. | Libera recursos de CPU e RAM que seriam reservados para o Hyper-V, mesmo que não esteja em uso ativo. | `Run-GamerMode` |
| **Logs de Kernel** | Desativação de `LogPages` para dispositivos de entrada (teclado, mouse) e outros componentes do kernel. | Reduz o overhead de CPU e I/O de disco gerado pelo registro constante de eventos de baixo nível. | `Run-Debloat` |
| **Mitigações de Segurança** | Desativação de `FeatureSettings` (relacionado a Spectre/Meltdown). | Pode recuperar uma pequena porcentagem de desempenho da CPU que é perdida devido a essas mitigações. | `Run-Debloat` |

---

## 🔍 Análise Detalhada das Funções do Script

### `Run-Debloat`

Esta função é a principal responsável pela limpeza de recursos:

-   **Remoção de Apps Inúteis:**
    ```powershell
    $apps = "*SkypeApp*", "*BingNews*", "*ZuneMusic*", "*YourPhone*", "*MicrosoftOfficeHub*", "*GetHelp*", "*Solitaire*", "*Microsoft.Windows.Photos*", "*Microsoft.ZuneVideo*"
    foreach ($app in $apps) { Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue }
    ```
    Remove aplicativos UWP que consomem RAM e CPU em segundo plano, mesmo sem uso direto.

-   **Desativação de Telemetria (`DiagTrack`):**
    ```powershell
    Stop-Service DiagTrack -ErrorAction SilentlyContinue; Set-Service DiagTrack -StartupType Disabled
    ```
    Interrompe e desabilita o serviço de telemetria do Windows, que constantemente coleta dados, utilizando CPU e RAM.

-   **Desativação de `LogPages`:**
    ```powershell
    reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows\Win32kWPP\Parameters" /v "LogPages" /t REG_DWORD /d "0" /f >$null
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" /v "LogPages" /t REG_DWORD /d "0" /f >$null
    ```
    Minimiza o registro de eventos de baixo nível, reduzindo o trabalho da CPU e o I/O de disco.

-   **Desativação de `WaaSMedicSvc`:**
    ```powershell
    Set-Service -Name "WaaSMedicSvc" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "WaaSMedicSvc" -ErrorAction SilentlyContinue
    ```
    Desabilita o serviço de reparo do Windows Update, que pode reativar outros serviços desativados pelo usuário, garantindo que as otimizações persistam.

### `Run-DeveloperMode`

Esta função foca em otimizações específicas para o ambiente de desenvolvimento:

-   **Desativação de `SysMain` (Superfetch):**
    ```powershell
    Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name "SysMain" -ErrorAction SilentlyContinue
    ```
    Libera RAM e reduz o I/O de disco em SSDs, beneficiando a performance de aplicações de desenvolvimento que já gerenciam seu próprio cache.

-   **Desativação de Serviços de Acesso Remoto:**
    ```powershell
    Get-Service -Name "RasMan" -ErrorAction SilentlyContinue | Stop-Service -Force
    Get-Service -Name "RasMan" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    Get-Service -Name "RemoteAccess" -ErrorAction SilentlyContinue | Stop-Service -Force
    Get-Service -Name "RemoteAccess" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled
    ```
    Interrompe e desabilita serviços de rede que não são essenciais para a maioria dos desenvolvedores, liberando recursos.

### `Run-GamerMode`

Embora focado em jogos, muitos desses ajustes beneficiam a CPU e RAM de forma geral:

-   **`SystemResponsiveness`:**
    ```powershell
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" SystemResponsiveness 0
    ```
    Reduz a prioridade de tarefas em segundo plano, dedicando mais ciclos de CPU a aplicações em primeiro plano.

-   **`Win32PrioritySeparation`:**
    ```powershell
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "24" /f >$null
    ```
    Ajusta o escalonador de CPU para favorecer a responsividade de programas ativos, o que é crucial para IDEs e jogos.

-   **Desativação de Hyper-V:**
    ```powershell
    bcdedit /set hypervisorlaunchtype off >$null
    ```
    Libera recursos de CPU e RAM que seriam alocados para o Hyper-V, mesmo que inativo.

---


### Fontes e Estratégias Integradas:

| Fonte de Otimização | Foco Principal | Contribuições Chave na v7.0 |
| :------------------ | :------------- | :-------------------------- |
| **Extreme Optimizer v6.0 (Base)** | Estabilidade e Usabilidade | Interface interativa (TUI), sistema de segurança (backup/restore), otimizações de boot/shutdown, e debloat geral de aplicativos. |
| **FoxOS** | Performance Extrema e Privacidade | Implementação de `Win32PrioritySeparation` para priorização de CPU, desativação de `LogPages` para redução de overhead de kernel, e ajustes agressivos de telemetria e auditoria. |
| **KernelOS** | Limpeza de Hardware Virtual e Timers | Otimizações de `BCDEDIT` para um timer de sistema mais preciso, desativação de WAN Miniports para redução de latência de rede, e desativação de serviços de diagnóstico e virtualização. |
| **Otimizações para Desenvolvedores** | Produtividade e Eficiência | Ajustes de I/O de disco para compilação e manipulação de dados, otimização de RAM para máquinas virtuais e containers, e priorização de processos de desenvolvimento. |

---

## ✨ Interface de Usuário (TUI) e Experiência Aprimorada

A interface do Extreme Optimizer v8.0 mantém o padrão inovador estabelecido nas versões anteriores, garantindo uma interação intuitiva e um feedback visual claro:

-   **Navegação Interativa por Setas:** A interação com o script é totalmente baseada nas teclas de seta (↑/↓) para navegação e `Enter` para confirmação. Isso elimina a necessidade de digitação manual, reduzindo erros e agilizando o processo de seleção.
-   **Design "Neon & Glass":** Uma estética moderna e vibrante, utilizando cores de alto contraste (Ciano e Magenta) e bordas em ASCII estendidas. Este design transforma o terminal em uma ferramenta visualmente atraente e profissional, alinhada com as tendências de UI modernas.
-   **Status Cards Dinâmicos:** Cada operação executada pelo script é apresentada em um "card" visual distinto. Estes cards fornecem feedback em tempo real sobre o módulo em execução, o status da tarefa e mensagens importantes, mantendo o usuário informado de forma clara e organizada.

---

## 🎯 Funcionalidades Essenciais e Modos de Otimização

Esta é a opção mais abrangente, executando uma sequência otimizada de todas as funcionalidades para configurar o sistema para ambos os perfis de uso com um único clique. Inclui:

-   **Segurança:** Criação automática de ponto de restauração e backup do registro do sistema.
-   **Modos Dedicados**: Otimizações específicas para `Gamer Mode` e `Developer Mode`.
-   **Limpeza e Debloat**: Remove aplicativos indesejados e desativa telemetria.
-   **Boot e Shutdown**: Acelera a inicialização e o desligamento do sistema.
-   **Auto-Stylist (Windhawk)**: Instala o Windhawk e aplica temas de barra de tarefas (Win10, Transparente, Arredondada) automaticamente.
-   **Alinhamento da Barra de Tarefas**: Altera o alinhamento da barra de tarefas (Esquerda/Centro).
-   **Pós-Formatação**: Instala programas essenciais via Winget, configura DNS, aplica tweaks de hardware e melhorias de UI.
-   **Ferramentas**: Acesso rápido ao Chris Titus Windows Utility.
-   **Aceleração de Boot:** Desativação de atrasos de inicialização e ativação de boot rápido.
-   **Performance Gamer:** Otimização de latência TCP, rede e timer do sistema.
-   **Developer Tweaks:** Priorização de processos de desenvolvimento e otimização de I/O.
-   **Limpeza Profunda:** Debloat de aplicativos modernos e remoção de telemetria invasiva.

### 2. Gamer Mode

Configurações dedicadas para entusiastas de jogos, focando em reduzir o *input lag* e maximizar a performance:
-   **Redução de Latência:** Implementação de `Win32PrioritySeparation` (FoxOS) e ajustes de `BCDEDIT` (KernelOS) para um timer de sistema mais responsivo e preciso.
-   **Otimização de Rede:** `TCP NoDelay` e desativação de WAN Miniports para minimizar o *ping* e a latência em jogos online, garantindo uma conexão mais estável.
-   **Plano de Energia:** Ativação do plano de "Desempenho Máximo" para garantir que a CPU e a GPU operem em sua capacidade total durante as sessões de jogo.

### 3. Developer Mode

Otimizações específicas para ambientes de desenvolvimento, visando a máxima produtividade e eficiência:
-   **Prioridade de Processos:** Ajustes para favorecer softwares como Visual Studio Code, Docker, PgAdmin, MongoDB, Python e Java, garantindo que eles recebam os recursos necessários para operar sem gargalos.
-   **Otimização de I/O de Disco:** Redução de gargalos em operações de leitura/escrita, crucial para compilação de código, manipulação de grandes volumes de dados e operações de banco de dados.
-   **Gerenciamento de Recursos:** Desativação de serviços desnecessários que consomem RAM e CPU, liberando recursos valiosos para máquinas virtuais, containers e ambientes de teste.

### 4. Limpeza & Debloat

Remove softwares indesejados, telemetria invasiva e arquivos desnecessários, liberando recursos e melhorando a privacidade. Inclui ajustes do FoxOS e KernelOS para uma limpeza mais profunda e eficaz.

### 5. Boot & Shutdown

Acelera drasticamente os processos de inicialização e desligamento do Windows, proporcionando uma experiência mais ágil e eficiente no dia a dia.

### 6. Segurança

Criação automática de pontos de restauração e backup do registro para garantir a segurança do sistema antes de qualquer alteração crítica, permitindo reverter as mudanças se necessário.

### 7. Ferramentas

Acesso rápido a utilitários externos, como o Chris Titus WinUtil (para ajustes adicionais) e a configuração de servidores DNS de alta velocidade (Cloudflare, Google, Quad9) para uma navegação mais rápida e segura.

---

## 🛡️ Como Utilizar o Extreme Optimizer v7.0

1.  **Baixe o script**: Faça o download do arquivo `extreme_optimizer_v8_0_gui_final.ps1`.
2.  **Execute como Administrador**: Clique com o botão direito no arquivo `.ps1` e selecione "Executar com PowerShell". O script solicitará elevação de privilégios se necessário.
3.  **Navegue pela GUI**: Utilize os botões na interface para aplicar as otimizações desejadas.
4.  **Monitore o Log**: A caixa de texto à direita exibirá o progresso e o status de cada operação.
--- 

## ⚠️ Aviso de Segurança e Recomendações

É sempre recomendado criar um ponto de restauração do sistema antes de aplicar otimizações profundas. Embora o Extreme Optimizer v7.0 faça isso automaticamente, a criação de um ponto de restauração manual oferece uma camada adicional de segurança. Certifique-se de entender as funcionalidades antes de aplicá-las, especialmente as que envolvem desativação de telemetria e serviços.

---

## 🤝 Contribuição e Suporte

Sua contribuição é valiosa! Sinta-se à vontade para abrir *issues* para relatar problemas ou sugerir melhorias, e enviar *pull requests* com novas funcionalidades ou correções. Juntos, podemos tornar o Extreme Optimizer ainda mais robusto.

---

**Desenvolvido para máxima performance e controle total do seu Windows, seja para codificar, criar ou dominar nos jogos.**
