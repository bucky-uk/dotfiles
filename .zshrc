# ~/.zshrc
# Interactive shell config (aliases, functions, prompt). Keep startup fast.

# p10k instant prompt...
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Basics ---
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# --- WSL2 interop fix (only used on WSL2; function only, doesn't run) ---
fix_wsl2_interop() {
  # Only relevant for WSL2 terminals (e.g., VS Code remote)
  [[ "${OS_TYPE:-}" != "wsl2" ]] && return 0

  for i in $(pstree -np -s $$ 2>/dev/null | grep -o -E '[0-9]+'); do
    if [[ -e "/run/WSL/${i}_interop" ]]; then
      export WSL_INTEROP="/run/WSL/${i}_interop"
      return 0
    fi
  done
}

# Completions (needed for compdef)
autoload -Uz compinit
compinit -C

# --- goto ---
if [[ -s "$HOME/code/iridakos/goto/goto.sh" ]]; then
  source "$HOME/code/iridakos/goto/goto.sh"
fi

# --- ASDF (fast-ish; keep in interactive so shims work) ---
if [[ -n "${ASDF_DIR:-}" ]]; then
  if [[ -r "$ASDF_DIR/asdf.sh" ]]; then
    source "$ASDF_DIR/asdf.sh"
  elif [[ -r "$ASDF_DIR/libexec/asdf.sh" ]]; then
    source "$ASDF_DIR/libexec/asdf.sh"
  fi
fi

# --- NVM (lazy-load) ---
if [[ -r "$NVM_DIR/nvm.sh" ]]; then
  unalias nvm node npm 2>/dev/null

  _lazy_load_nvm() {
    unset -f nvm node npm 2>/dev/null
    source "$NVM_DIR/nvm.sh"
  }

  nvm()  { _lazy_load_nvm; nvm  "$@"; }
  node() { _lazy_load_nvm; node "$@"; }
  npm()  { _lazy_load_nvm; npm  "$@"; }
fi


# --- Kubectl / Helm helpers ---
alias k="kubectl"
alias h="helm"

kn() {
  if [[ -n "$1" ]]; then
    kubectl config set-context --current --namespace="$1"
  else
    echo -e "\e[1;31m Error, please provide a valid Namespace\e[0m"
  fi
}

knd() { kubectl config set-context --current --namespace=default; }
ku()  { kubectl config unset current-context; }

# --- Utilities ---
reloadui() {
  export NEOFETCH_SHOWN=0
  source ~/.zprofile
  source ~/.zshrc
}

colormap() {
  for i in {0..255}; do
    print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
  done
}

bookmark() {
  if [[ -n "$1" ]]; then
    goto -u "$1" && goto -r "$1" .
  else
    echo -e "Please provide bookmark name"
  fi
}

setenv() {
  if [[ -n "$1" ]]; then
    set -o allexport
    source "$HOME/.envs/$1/.env.$2"
    set +o allexport
    export AWS_PROFILE="$2"
  else
    set -o allexport
    source .env
    set +o allexport
  fi
}

gitorg() {
  if [[ -n "$1" ]]; then
    gh repo list "$1" --limit 1000 | while read -r repo _; do
      gh repo clone "$repo"
    done
  else
    echo -e "Please provide an org name to clone"
  fi
}

checkport() {
  if [[ -n "$1" ]]; then
    sudo lsof -i -P -n | grep LISTEN | grep "$1"
  else
    echo -e "Please provide a port number to check"
  fi
}

aws-session-start() {
  if [[ -n "$1" ]]; then
    aws ssm start-session --region eu-west-2 --target "$1" \
      --document-name AWS-StartPortForwardingSessionToRemoteHost \
      --parameters="host=$2,portNumber=5432,localPortNumber=5432"
  else
    echo -e "Please target an instance to start a session"
  fi
}

# --- Aliases ---
alias edit="code"
alias configure="edit ~/.zshrc | edit ~/.zprofile | edit ~/.p10k.zsh | edit ~/.gitconfig | edit ~/.ssh/config"

# Prefer eza if installed; otherwise fall back to ls
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza --icons --group-directories-first -l"
fi

alias g="goto"
alias grep='grep --color'

alias ssh-list="cat ~/.ssh/config"
alias ssh-edit="edit ~/.ssh/config"

alias shell-list="cat /etc/shells"
alias shell-zsh="chsh -s /usr/bin/zsh"

alias yadm-init="yadm clone https://github.com/bucky-uk/dotfiles"

# macOS-only app alias
if [[ "${OS_TYPE:-}" == "macos" ]]; then
  alias android-studio="$HOME/applications/android-studio/bin/studio.sh"
fi

alias aws-ec2-list="aws ec2 describe-instances --query \"Reservations[*].Instances[*].{InstanceId:InstanceId,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value,Type:InstanceType,Status:State.Name,VpcId:VpcId}\" --filters Name=instance-state-name,Values=running --output table"
alias aws-rds-list="aws rds describe-db-instances --query \"DBInstances[*].{DBInstanceIdentifier:DBInstanceIdentifier,Engine:Engine,Status:DBInstanceStatus,Endpoint:Endpoint.Address,Port:Endpoint.Port,InstanceClass:DBInstanceClass,MultiAZ:MultiAZ}\" --output table"
alias ss='aws ssm start-session --region eu-west-2 --target "$AWS_BASTION" --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters=host="$AWS_RDS_HOST",portNumber=5432,localPortNumber=5432'

# # --- Prompt: Powerlevel10k only ---
# if [[ -r /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
#   source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
# elif [[ -r "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
#   source "$HOME/.local/share/powerlevel10k/powerlevel10k.zsh-theme"
# fi

# [[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/angularic.omp.json)"
  # eval "$(oh-my-posh init zsh --config ~/code/JanDeDobbeleer/oh-my-posh/themes/dracula.omp.json)"
fi

# --- Optional: neofetch gated (off by default) ---
if [[ -t 1 && -z "${NEOFETCH_SHOWN:-}" ]] && command -v neofetch >/dev/null 2>&1; then
  export NEOFETCH_SHOWN=1
  neofetch
fi
