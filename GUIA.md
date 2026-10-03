# Guia: transformar o MacBook Pro 2014 em servidor

**Máquina:** MacBook Pro Retina 15" Mid 2014 (MacBookPro11,2), i7 2.2 GHz, 16 GB, Iris Pro, macOS Catalina.

**Situação:** o último macOS oficial para esse modelo é o **Big Sur (11)**. O Claude Code exige **macOS 13 ou mais novo**.
Por isso vamos usar o **OpenCore Legacy Patcher (OCLP)** para instalar o **macOS Sequoia (15)**.

---

## FASE 1: no Mac antigo, só com o teclado (10 minutos)

> Tem um mouse USB com fio? Pode ligar. Esse Mac tem 2 portas USB normais e tudo fica mais fácil.
> Mas a Fase 1 funciona só com o teclado.

### 1. Abrir o Terminal
1. Aperte **⌘ Command + Barra de espaço** ao mesmo tempo. Abre uma barrinha de busca no meio da tela.
2. Digite: `terminal`
3. Aperte **Enter**. Abre uma janela com texto (fundo branco ou preto). Esse é o Terminal.

### 2. Baixar o script
Digite **exatamente** a linha abaixo, com todos os espaços e tudo em minúsculas, e aperte **Enter**:

```
curl -fsSL -o p.sh https://raw.githubusercontent.com/mendesgabriell/macbookpro2/HEAD/preparar.sh
```

Se não aparecer nada, deu certo. Se aparecer um erro, tire uma foto e mande no chat.

### 3. Rodar o script
Digite e aperte **Enter**:

```
bash p.sh
```

- Ele vai pedir a **senha do Mac**. Enquanto você digita **não aparece nada**, é normal. Digite e aperte Enter.
- No fim aparece um **RESUMO**. **Tire uma foto com o celular e mande no chat.**

### Se o "Login Remoto" aparecer DESLIGADO
1. **⌘ + Espaço**, digite `compartilhamento`, aperte Enter.
2. Use **Tab** para andar entre as opções e **Barra de espaço** para marcar **"Login Remoto"**.

---

## FASE 2: no Mac novo, o Claude trabalha e você aprova pelo celular

O Claude Code online (claude.ai/code) roda na nuvem e **não enxerga a sua rede de casa**.
Para controlar o Mac antigo, o Claude precisa rodar **no Mac novo**.

1. No Mac novo, abra o Terminal (**⌘ + Espaço**, `terminal`, Enter).
2. Instale o Claude Code (só na primeira vez):
   ```
   curl -fsSL https://claude.ai/install.sh | bash
   ```
3. Crie uma pasta de trabalho e entre nela:
   ```
   mkdir -p ~/mac-servidor && cd ~/mac-servidor
   ```
4. Comece a sessão com `claude remote-control`. Ela aparece no app do Claude no celular,
   e quando o Claude pedir permissão para um comando, você aprova de onde estiver.
5. Cole o texto abaixo (troque `USUARIO` e `NOME` pelo que apareceu na foto do resumo):

```
Você vai administrar meu MacBook Pro 2014 antigo (macOS Catalina) pela rede via SSH:
ssh USUARIO@NOME.local

Contexto e plano completo: https://github.com/mendesgabriell/macbookpro2/blob/HEAD/GUIA.md

1) Configure acesso por chave SSH (ssh-keygen se precisar e ssh-copy-id; eu digito a senha uma vez).
2) Leia ~/Desktop/diagnostico-mac.txt no Mac antigo e me mostre um resumo.
3) Limpeza segura no Mac antigo: caches de usuário e de sistema, logs antigos, lixeira,
   downloads de instaladores velhos, itens de login/LaunchAgents desnecessários e apps pesados
   que eu não uso. NÃO apague documentos, fotos ou arquivos pessoais: liste os maiores
   em um relatório para eu decidir.
4) Verifique a saúde do disco (diskutil verifyVolume /) e do sistema.
   Se algum comando precisar de senha de administrador (sudo), deixe para quando eu estiver na frente do Mac.
5) Prepare a atualização: baixe a versão mais recente do OpenCore Legacy Patcher
   (github.com/dortania/OpenCore-Legacy-Patcher/releases) e confira na documentação oficial se
   o MacBookPro11,2 está suportado no macOS Sequoia. NÃO instale o OpenCore, NÃO instale
   macOS e NÃO reinicie o Mac sem mim. Isso faremos juntos.
6) No fim, escreva um relatório em ~/mac-servidor/relatorio.md com tudo o que fez,
   quanto espaço liberou e os próximos passos.
```

---

## FASE 3: atualizar para macOS Sequoia (com você presente, cerca de 1h30)

Precisa de **mouse USB** (o instalador e a configuração inicial são cheios de cliques) e, de preferência, um **pendrive de 16 GB ou mais**.

1. Abrir o **OpenCore Legacy Patcher**, escolher **Build and Install OpenCore** e instalar no disco interno.
2. Reiniciar segurando **⌥ Option** e escolher **EFI Boot**.
3. Pelo OCLP, baixar e rodar o instalador do **macOS Sequoia** (direto ou pelo pendrive).
4. Depois de instalado, o OCLP pede para aplicar os **Post-Install Root Patches** (vídeo, Wi‑Fi). Aceitar e reiniciar.
5. Instalar o **Claude Code** e o **Homebrew** no Mac antigo. A partir daí ele vira servidor de verdade.

---

## Linux junto com o macOS (dual boot)?
Dá para fazer: diminuir a partição do macOS e instalar o Ubuntu ao lado. Na hora de ligar, você escolhe qual sistema usar.
Com o macOS Sequoia rodando o Claude Code, provavelmente não vai ser necessário. Decidimos depois de ver o tamanho do SSD.
