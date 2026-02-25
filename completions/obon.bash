# Bash completion for obon
# Source this file or place it in /etc/bash_completion.d/

_obon() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  case "$prev" in
    obon)
      COMPREPLY=($(compgen -W "join break --help --version -h -v" -- "$cur"))
      ;;
    join)
      COMPREPLY=($(compgen -W "--all --yes -y" -- "$cur"))
      ;;
    break)
      COMPREPLY=($(compgen -W "--all" -- "$cur"))
      ;;
  esac
}

complete -F _obon obon
