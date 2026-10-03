#!/bin/bash
# Diagnostico do MacBook antigo — SOMENTE LEITURA, nao altera nada.
# Compativel com bash 3.2 (padrao em macOS antigos).
# Uso:  bash diagnostico.sh
# O relatorio e salvo em ~/Desktop/diagnostico-mac.txt

OUT="$HOME/Desktop/diagnostico-mac.txt"

secao() { echo; echo "===== $1 ====="; }

{
echo "Relatorio gerado em: $(date)"

secao "SISTEMA"
sw_vers 2>/dev/null
uname -a

secao "MODELO / HARDWARE"
sysctl -n hw.model 2>/dev/null
system_profiler SPHardwareDataType 2>/dev/null | grep -v -i -E "serial|uuid|provisioning"

secao "MEMORIA RAM"
system_profiler SPMemoryDataType 2>/dev/null | grep -E "Size|Type|Speed|Upgradeable|Tamanho|Tipo|Velocidade" | head -20

secao "DISCO (tipo: SSD ou HD?)"
system_profiler SPSerialATADataType SPNVMeDataType 2>/dev/null | grep -E "Model|Medium Type|Solid State|Capacity|Modelo|Capacidade|S.M.A.R.T" | head -20
diskutil info / 2>/dev/null | grep -E "File System|Solid State|SMART|Disk Size|Volume Free|Container Free|Sistema de Arquivos"

secao "ESPACO EM DISCO"
df -h / 2>/dev/null

secao "MAIORES PASTAS NO SEU USUARIO (pode demorar)"
du -sh "$HOME"/* "$HOME"/Library/Caches "$HOME"/Library/Application\ Support 2>/dev/null | sort -rh 2>/dev/null | head -20 \
  || du -sk "$HOME"/* 2>/dev/null | sort -rn | head -20

secao "BATERIA"
system_profiler SPPowerDataType 2>/dev/null | grep -E "Cycle Count|Condition|Full Charge Capacity|Contagem de Ciclos|Condi"
pmset -g batt 2>/dev/null

secao "TEMPERATURA / ESTADO TERMICO"
pmset -g therm 2>/dev/null

secao "TEMPO LIGADO E CARGA"
uptime

secao "PROCESSOS QUE MAIS USAM CPU"
ps -Aceo pid,pcpu,pmem,comm -r 2>/dev/null | head -15

secao "PROCESSOS QUE MAIS USAM MEMORIA"
ps -Aceo pid,pcpu,pmem,comm -m 2>/dev/null | head -15

secao "ITENS QUE ABREM NO LOGIN / EM SEGUNDO PLANO"
ls /Library/LaunchAgents /Library/LaunchDaemons "$HOME/Library/LaunchAgents" 2>/dev/null
osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null

secao "APLICATIVOS INSTALADOS"
ls /Applications 2>/dev/null

secao "FERRAMENTAS DE DESENVOLVIMENTO"
xcode-select -p 2>/dev/null || echo "Command Line Tools: nao instalado"
for c in git curl python3 node brew ssh; do
  printf "%-8s " "$c"; command -v "$c" >/dev/null 2>&1 && ("$c" --version 2>&1 | head -1) || echo "nao encontrado"
done
curl -sI https://github.com >/dev/null 2>&1 && echo "HTTPS para github.com: OK" || echo "HTTPS para github.com: FALHOU (certificados/TLS antigos?)"

secao "ATUALIZACOES DISPONIVEIS"
softwareupdate --list 2>&1 | head -20

secao "MODO DE COMPARTILHAMENTO REMOTO"
systemsetup -getremotelogin 2>/dev/null || echo "(precisa de sudo para ver Remote Login)"
} > "$OUT" 2>&1

echo "Pronto! Relatorio salvo em: $OUT"
echo "Abra esse arquivo, copie tudo e cole no chat com o Claude."
