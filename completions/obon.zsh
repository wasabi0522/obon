#compdef obon

# Zsh completion function for obon
# Place this file in a directory listed in your $fpath, then run: compinit

_obon_join() {
  _arguments \
    '--all[Aggregate panes from all tmux sessions]' \
    '(-y --yes)'{-y,--yes}'[Skip confirmation prompt]'
}

_obon_break() {
  _arguments \
    '--all[Restore panes across all tmux sessions]'
}

_obon() {
  local -a commands
  commands=(
    'join:Aggregate panes running the target command into an obon window'
    'break:Restore panes from the obon window to their original locations'
  )

  _arguments -C \
    '(-h --help)'{-h,--help}'[Show help message]' \
    '(-v --version)'{-v,--version}'[Show version]' \
    '1:command:->command' \
    '*::arg:->args'

  case "$state" in
    command)
      _describe -t commands 'obon command' commands
      ;;
    args)
      case "$words[1]" in
        join)
          _obon_join
          ;;
        break)
          _obon_break
          ;;
      esac
      ;;
  esac
}

_obon "$@"
