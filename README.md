# claude-code-vps

Claude Code rodando numa VPS, dentro do tmux. Você entra por SSH (do computador ou
do celular), abre o `claude`, fecha o terminal, e a sessão continua lá trabalhando.
Depois volta exatamente de onde parou.

```
cc session-name   # cria (ou volta pra) a sessão "session-name", já com o claude aberto
Ctrl-b d          # sai sem fechar nada
cc                # lista as sessões abertas
```

## O que vem

| Arquivo | O que faz |
|---|---|
| `install.sh` | instala tmux, git, curl e o Claude Code; copia as configs abaixo |
| `tmux/tmux.conf` | tmux ajustado pro Claude Code: Esc instantâneo, mouse, 50 mil linhas de histórico, tamanho que segue o último aparelho conectado |
| `shell/cc.sh` | função `cc` (bash e zsh): uma sessão tmux por nome, cada uma com seu `claude` |

## Requisitos

- VPS com Debian ou Ubuntu (testado no Ubuntu 22.04). 1 GB de RAM já roda; 2 GB é mais folgado.
- Conta Claude Pro/Max, ou chave de API da Anthropic.
- Um cliente SSH. No celular: Termius, Blink (iOS) ou JuiceSSH (Android).

## Instalação

Na VPS:

```sh
git clone https://github.com/robertsilvatech/claude-code-vps
cd claude-code-vps
./install.sh
exec $SHELL
```

Primeira sessão:

```sh
cc session-name
```

Na primeira vez o `claude` pede login. Como a VPS não tem navegador, ele mostra um
link: abra no seu computador ou celular, autorize e cole o código de volta no terminal.

Por padrão as sessões abrem no `$HOME`. Pra abrir em outra pasta:

```sh
export CC_DIR=~/projetos     # coloque no ~/.bashrc pra ficar fixo
```

## Uso no dia a dia

| Comando | Efeito |
|---|---|
| `cc` | lista as sessões |
| `cc session-name` | entra na sessão; se não existe, cria com o `claude` aberto |
| `Ctrl-b d` | desconecta (a sessão continua rodando) |
| `Ctrl-b \|` / `Ctrl-b -` | divide a tela na vertical / horizontal |
| `Ctrl-b r` | recarrega o `tmux.conf` |
| `tmux kill-session -t <nome>` | fecha uma sessão de vez |

Dentro do tmux, `cc outra-session-name` troca de sessão em vez de abrir uma dentro da outra.

Quando o `claude` termina (você digita `/exit`), a sessão do tmux fecha junto.

Rolar a tela: roda do mouse ou, no celular, `Ctrl-b [` e setas (`q` sai).

## Segurança da VPS

Ponto de partida mínimo, antes de deixar o Claude trabalhando sozinho na máquina:

- **Entre por chave SSH, não por senha.** Em `/etc/ssh/sshd_config`:
  `PasswordAuthentication no`, depois `systemctl restart ssh`.
  Teste o login por chave numa segunda janela antes de fechar a primeira.
- **Firewall:** `ufw allow OpenSSH && ufw enable`. Abra outras portas só quando precisar.
- **Usuário comum em vez de root**, se puder. O script funciona nos dois.
- O Claude Code executa comandos na máquina. Não deixe na VPS segredos que ele não
  deveria ler, e revise o que ele pede pra rodar até confiar no fluxo.

## Atualizar

```sh
cd claude-code-vps && git pull && ./install.sh
```

O Claude Code se atualiza sozinho. O `install.sh` faz backup do `tmux.conf` antigo
se ele for diferente, e não duplica as linhas no `.bashrc`/`.zshrc`.

## Desinstalar

```sh
rm -rf ~/.config/claude-code-vps ~/.config/tmux/tmux.conf
# apague o bloco "# claude-code-vps" do ~/.bashrc e do ~/.zshrc
```

## Licença

MIT
