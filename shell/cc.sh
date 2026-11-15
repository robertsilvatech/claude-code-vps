# cc.sh — sessões do Claude Code no tmux, uma por nome. Funciona em bash e zsh.
# Carregado pelo ~/.bashrc / ~/.zshrc (o install.sh adiciona a linha `source`).
#
#   cc               lista as sessões abertas (cc ls também)
#   cc session-name  entra na sessão "session-name"; se não existir, cria já rodando `claude`
#                    (conversa nova) em $CC_DIR (padrão: $HOME)
#
# A sessão sobrevive à queda do SSH. Ctrl-b d desconecta sem matar nada.
# Dentro do tmux não dá pra aninhar: cria a sessão (se preciso) e troca pra ela.
#
# Obs.: `cc` também é o nome do compilador C. A função só existe no shell interativo;
# make/gcc chamam /usr/bin/cc direto e não são afetados. Pra usar o compilador no
# terminal: `command cc`.

cc() {
  case "${1:-}" in
    ""|ls) tmux ls 2>/dev/null || echo "nenhuma sessão aberta" ;;
    *)
      local s="$1" dir="${CC_DIR:-$HOME}"
      [ -d "$dir" ] || dir="$HOME"
      if [ -n "${TMUX:-}" ]; then
        tmux has-session -t "=$s" 2>/dev/null || tmux new-session -d -s "$s" -c "$dir" "claude"
        tmux switch-client -t "=$s"
      else
        tmux new-session -A -s "$s" -c "$dir" "claude"
      fi
      ;;
  esac
}
