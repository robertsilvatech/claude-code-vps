#!/usr/bin/env bash
# install.sh — prepara uma VPS (Debian/Ubuntu) pra usar o Claude Code via SSH.
#
#   1. apt: tmux, git, curl
#   2. Claude Code (instalador oficial → ~/.local/bin/claude)
#   3. tmux.conf → ~/.config/tmux/tmux.conf (faz backup se já existir outro)
#   4. função `cc` → ~/.config/claude-code-vps/cc.sh, carregada no ~/.bashrc e ~/.zshrc
#
# Idempotente: pode rodar de novo pra atualizar.
# Uso: git clone https://github.com/<você>/claude-code-vps && cd claude-code-vps && ./install.sh
set -euo pipefail
cd "$(dirname "$0")"

SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
CONF_DIR="$HOME/.config/claude-code-vps"
TMUX_CONF="$HOME/.config/tmux/tmux.conf"
MARK="# claude-code-vps"

# 1. pacotes
if command -v apt-get >/dev/null 2>&1; then
  echo "→ apt: tmux git curl..."
  $SUDO apt-get update -qq
  DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y -qq tmux git curl ca-certificates >/dev/null
else
  for b in tmux git curl; do
    command -v "$b" >/dev/null 2>&1 || { echo "❌ sem apt-get e sem $b — instale pelo gerenciador da sua distro"; exit 1; }
  done
fi

# 2. Claude Code
if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
  echo "→ claude já instalado ($("${HOME}/.local/bin/claude" --version 2>/dev/null || claude --version))"
else
  echo "→ Claude Code (instalador oficial)..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# 3. tmux.conf
mkdir -p "$(dirname "$TMUX_CONF")"
if [ -f "$TMUX_CONF" ] && ! cmp -s tmux/tmux.conf "$TMUX_CONF"; then
  bak="$TMUX_CONF.bak.$(date +%Y%m%d%H%M%S)"
  echo "→ tmux.conf existente → backup em $bak"
  cp "$TMUX_CONF" "$bak"
fi
cp tmux/tmux.conf "$TMUX_CONF"
# tmux < 3.1 só lê ~/.tmux.conf
[ -e "$HOME/.tmux.conf" ] || echo "source-file $TMUX_CONF" > "$HOME/.tmux.conf"
tmux source-file "$TMUX_CONF" 2>/dev/null || true   # recarrega se já tiver servidor rodando

# 4. função cc + PATH
mkdir -p "$CONF_DIR"
cp shell/cc.sh "$CONF_DIR/cc.sh"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] || [ "$rc" = "$HOME/.bashrc" ] || continue   # .zshrc só se já existir
  touch "$rc"
  if ! grep -qF "$MARK" "$rc"; then
    echo "→ $rc: carregando cc.sh"
    {
      echo ""
      echo "$MARK"
      echo 'case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac'
      echo "[ -f \"$CONF_DIR/cc.sh\" ] && . \"$CONF_DIR/cc.sh\""
    } >> "$rc"
  fi
done

echo ""
echo "✅ pronto. Próximos passos:"
echo "   exec \$SHELL          # recarrega o shell"
echo "   cc meu-projeto       # abre o claude numa sessão tmux (faz login na 1ª vez)"
echo "   Ctrl-b d             # sai sem fechar; 'cc meu-projeto' volta pra ela"
