#!/bin/bash
# Diagnostica e corrige o Login Remoto (SSH) no Mac antigo.
# Rode NO MAC ANTIGO:  bash c.sh
# Compativel com bash 3.2 (macOS Catalina).

clear
echo "Digite a SUA senha do Mac se pedir (nao aparece nada) e Enter."
sudo -v || exit 1
clear

echo "== 1. Configuracao do SSH =="
sudo /usr/sbin/sshd -t 2>&1 | tail -3 && echo "(sem erro acima = OK)"

echo "== 2. Chaves do servidor =="
if ls /etc/ssh/ssh_host_*_key >/dev/null 2>&1; then
  echo "OK: $(ls /etc/ssh/ssh_host_*_key | wc -l | tr -d ' ') chaves"
else
  echo "FALTAVAM - gerando..."; sudo ssh-keygen -A
fi

echo "== 3. Quem pode entrar por SSH =="
if dscl . -read /Groups/com.apple.access_ssh >/dev/null 2>&1; then
  sudo dseditgroup -o edit -a "$USER" -t user com.apple.access_ssh >/dev/null 2>&1
  echo "Lista restrita - $USER adicionado"
else
  echo "Todos os usuarios (OK)"
fi

echo "== 4. Reiniciando o SSH =="
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist >/dev/null 2>&1
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
sleep 3

echo "== 5. Teste local =="
R=$(ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null "$USER@localhost" true 2>&1 | tail -1)
case "$R" in
  *"Permission denied"*) echo "SSH FUNCIONANDO (pode tentar do Mac novo)";;
  *) echo "AINDA COM PROBLEMA: $R";;
esac

echo "== 6. Ultimas mensagens do SSH =="
log show --last 15m --style compact --predicate 'process == "sshd"' 2>/dev/null \
  | grep -v -i "debug" | tail -6 | cut -c 1-160
echo "=============== TIRE UMA FOTO DESTA TELA ==============="
