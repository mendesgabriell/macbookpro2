#!/bin/bash
# Prepara o MacBook antigo para ser controlado pelo Mac novo.
#  1. Roda o diagnostico (somente leitura) -> ~/Desktop/diagnostico-mac.txt
#  2. Liga o "Login Remoto" (SSH) para o Mac novo conseguir se conectar
#  3. Ajusta energia: nao dormir quando estiver na tomada
#  4. Mostra um resumo na tela (tire uma foto e mande no chat)
# Compativel com bash 3.2 (macOS Catalina).

BASE="https://raw.githubusercontent.com/mendesgabriell/macbookpro2/HEAD"

echo
echo "=================================================="
echo "  PREPARANDO O MAC ANTIGO (leva uns 2 a 5 minutos)"
echo "=================================================="

echo
echo ">> 1/3  Rodando o diagnostico..."
curl -fsSL "$BASE/diagnostico.sh" -o /tmp/diagnostico.sh && bash /tmp/diagnostico.sh

echo
echo ">> 2/3  Agora o Mac vai pedir a SENHA DO SEU USUARIO (a mesma de entrar no Mac)."
echo "        Enquanto voce digita NAO APARECE NADA na tela. E normal."
echo "        Digite a senha e aperte Enter."
sudo -v || { echo "Senha nao aceita. Rode 'bash p.sh' de novo."; exit 1; }

echo
echo ">> Ligando o Login Remoto (SSH)..."
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist >/dev/null 2>&1
sleep 2
if ! nc -z 127.0.0.1 22 >/dev/null 2>&1; then
  sudo systemsetup -setremotelogin on >/dev/null 2>&1
  sleep 2
fi
if nc -z 127.0.0.1 22 >/dev/null 2>&1; then
  SSH_OK="LIGADO"
else
  SSH_OK="DESLIGADO (precisa ligar na mao - veja o GUIA)"
fi

echo
echo ">> 3/3  Ajustando energia (nao dormir na tomada, tela apaga em 10 min)..."
sudo pmset -c sleep 0 disksleep 0 displaysleep 10 womp 1 >/dev/null 2>&1
sudo pmset -c autorestart 1 >/dev/null 2>&1

NOME="$(scutil --get LocalHostName 2>/dev/null)"
IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)"

clear
echo "=================================================="
echo "   RESUMO  -  TIRE UMA FOTO DESTA TELA"
echo "=================================================="
echo "Modelo:        $(sysctl -n hw.model)"
echo "macOS:         $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
df -h / | awk 'NR==2 {print "Disco:         " $2 " total, " $4 " livre"}'
echo "Bateria:       $(system_profiler SPPowerDataType 2>/dev/null | grep -E 'Cycle Count|Condition' | sed 's/^ *//' | tr '\n' ' ')"
echo "Usuario:       $USER"
echo "Nome na rede:  $NOME.local"
echo "IP:            $IP"
echo "Login Remoto:  $SSH_OK"
echo
echo "Comando para o Mac novo se conectar:"
echo "   ssh $USER@$NOME.local"
echo
echo "Relatorio completo: Mesa (Desktop) > diagnostico-mac.txt"
echo "=================================================="
echo "IMPORTANTE: deixe o Mac na tomada e com a TAMPA ABERTA."
echo "=================================================="
