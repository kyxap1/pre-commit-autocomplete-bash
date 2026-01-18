#!/bin/bash

# Bash completion for pre-commit
# Based on zsh-pre-commit-autocomplete by LIU ZHE YOU
# License: MIT (https://github.com/jason810496/zsh-pre-commit-autocomplete/blob/main/LICENSE)

_pre_commit() {
  local cur prev opts subcommand
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # Main subcommands and global options
  # Derived from pre-commit -h
  opts="autoupdate clean gc init-templatedir install install-hooks migrate-config run sample-config try-repo uninstall validate-config validate-manifest help hook-impl -h --help -V --version --color"

  # 1. Identify if a subcommand has already been chosen
  subcommand=""
  for (( i=1; i < COMP_CWORD; i++ )); do
    local word="${COMP_WORDS[i]}"
    # Check if this word is one of the subcommands
    if [[ " ${opts} " =~ " ${word} " ]]; then
      # Ignore global flags as subcommands
      if [[ "${word}" != -* ]]; then
        subcommand="${word}"
        break
      fi
    fi
  done

  # 2. If no subcommand matches yet, suggest subcommands
  if [[ -z "${subcommand}" ]]; then
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
  fi

  # 3. Handle subcommand specific completions
  case "${subcommand}" in
    run)
      local run_opts="--all-files -a --files --verbose -v --no-stash --show-diff-on-failure --color --hook-stage --source --origin --from-ref --to-ref --remote-branch --local-branch --commits --config -c"
      local available_hooks=""

      if [[ -f .pre-commit-config.yaml ]]; then
        # Parse hooks from .pre-commit-config.yaml
        available_hooks=$(awk '/id:/ {print $3}' .pre-commit-config.yaml)
      fi

      COMPREPLY=( $(compgen -W "${available_hooks} ${run_opts}" -- ${cur}) )
      ;;
    install)
      local install_opts="--color --config -c --force -f --hooks --hook-type -t --install-hooks --overwrite --allow-missing-config"
       COMPREPLY=( $(compgen -W "${install_opts}" -- ${cur}) )
      ;;
    install-hooks)
      local install_hooks_opts="--color --config -c --force -f --verbose -v"
      COMPREPLY=( $(compgen -W "${install_hooks_opts}" -- ${cur}) )
      ;;
    uninstall)
       local uninstall_opts="--color --config -c --hook-type -t"
       COMPREPLY=( $(compgen -W "${uninstall_opts}" -- ${cur}) )
       ;;
    autoupdate)
       local auto_opts="--bleeding-edge --color --config -c --freeze --repo --jobs -j"
       COMPREPLY=( $(compgen -W "${auto_opts}" -- ${cur}) )
       ;;
    gc)
       local gc_opts="--color --config -c"
       COMPREPLY=( $(compgen -W "${gc_opts}" -- ${cur}) )
       ;;
    clean)
       local clean_opts="--color --config -c"
       COMPREPLY=( $(compgen -W "${clean_opts}" -- ${cur}) )
       ;;
    init-templatedir)
       local init_opts="--color --config -c --no-allow-missing-config --hook-type -t"
       COMPREPLY=( $(compgen -W "${init_opts}" -- ${cur}) )
       ;;
    try-repo)
       local try_opts="--color --config -c --ref --rev --verbose -v --all-files -a --files --show-diff-on-failure --hook-stage --remote-branch --local-branch --from-ref --source -s --to-ref --origin -o --commit-msg-filename"
       # Ideally this would also suggest --repo URL, but that's hard to autocomplete.
       # We can suggest hooks if valid, but try-repo often pulls them dynamically.
       COMPREPLY=( $(compgen -W "${try_opts}" -- ${cur}) )
       ;;
    migrate-config|validate-config|validate-manifest)
       # These mostly take file paths
       COMPREPLY=( $(compgen -f -- ${cur}) )
       ;;
    sample-config)
       COMPREPLY=()
       ;;
    help)
       # Suggest other subcommands
       COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
       ;;
    *)
      ;;
  esac
}

complete -F _pre_commit pre-commit
