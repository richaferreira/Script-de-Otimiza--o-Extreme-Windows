# 🏆 Extreme Optimizer v4.1 (FINAL POLISHED)

Esta é a versão definitiva e polida do script de otimização para o **Windows 11 (22H2, 23H2 e 24H2)**. Corrigimos todos os detalhes para garantir uma experiência livre de erros, mesmo em sistemas recém-instalados.

## ✨ O que há de novo na v4.1?

| Recurso | Status | Descrição |
| :--- | :--- | :--- |
| **🛡️ Telemetry Fix** | **Corrigido** | O script agora cria a chave `DataCollection` no registro caso ela não exista, evitando erros de "caminho não encontrado" em sistemas novos. |
| **📏 Windhawk Engine** | **Estável** | Instalação silenciosa (`/S`) para personalização moderna da barra de tarefas. |
| **🔄 Restore Total** | **Funcional** | Reversão completa de ajustes de rede, energia e serviços com a opção **[R]**. |
| **📝 Logs Seguros** | **Aprimorado** | Sistema de logs com fechamento garantido para evitar perda de dados. |
| **🎮 Gaming Core** | **Extreme** | Ajustes de `TCPNoDelay` e prioridade de CPU para performance máxima. |

---

## 🛠️ Instruções de Uso

1.  **Execução**:
    *   Execute o arquivo `extreme_optimizer_v4_1_final.ps1` com o PowerShell (Administrador).
    *   O script solicitará privilégios de administrador automaticamente se necessário.

2.  **Opção Recomendada**:
    *   Use a **Opção [1] (COMBO PRO)** para uma otimização completa, segura e com backup automático.

3.  **Personalização**:
    *   Para mudar o tamanho da barra de tarefas ou aplicar temas, use a **Opção [W]** para instalar o Windhawk e siga as instruções no guia.

---

## 📂 Localização dos Arquivos

*   **Backups**: `%ProgramData%\ExtremeOptimizer\backups`
*   **Logs**: `%ProgramData%\ExtremeOptimizer\logs`

---

## 🔗 Créditos e Referências
*   **Chris Titus Tech**: [Windows Utility](https://christitus.com/win)
*   **Windhawk**: [The Windows customization engine](https://windhawk.net/)
*   **Microsoft Docs**: [TCP Settings for Low Latency](https://learn.microsoft.com/en-us/windows-server/networking/technologies/network-subsystem/net-sub-performance-tuning-network-adapter-latency)
