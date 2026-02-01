# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Goto
[[ -s "~/code/iridakos/goto/goto.sh" ]] && source ~/code/iridakos/goto/goto.sh

# NVM lazy load
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

if [ -s "$HOME/.nvm/nvm.sh" ]; then
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  alias nvm='unalias nvm node npm && . "$NVM_DIR"/nvm.sh && nvm'
  alias node='unalias nvm node npm && . "$NVM_DIR"/nvm.sh && node'
  alias npm='unalias nvm node npm && . "$NVM_DIR"/nvm.sh && npm'
fi

# ASDF
[[ -s "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]] && . /opt/homebrew/opt/asdf/libexec/asdf.sh

# Fix Interop Error that randomly occurs in vscode terminal when using WSL2
fix_wsl2_interop() {
    for i in $(pstree -np -s $$ | grep -o -E '[0-9]+'); do
        if [[ -e "/run/WSL/${i}_interop" ]]; then
            export WSL_INTEROP=/run/WSL/${i}_interop
        fi
    done
}

# Kubectl Functions
# ---
#
alias k="kubectl"
alias h="helm"

kn() {
    if [ "$1" != "" ]; then
	    kubectl config set-context --current --namespace=$1
    else
	    echo -e "\e[1;31m Error, please provide a valid Namespace\e[0m"
    fi
}

knd() {
    kubectl config set-context --current --namespace=default
}

ku() {
    kubectl config unset current-context
}

# Colormap
function colormap() {
  for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done
}

# SetEnv
bookmark() {
    if [ "$1" != "" ]; then
	    goto -u $1 && goto -r $1 .
    else
	    echo -e "Please provide bookmark name"
    fi
}

# SetEnv
setenv() {
    if [ "$1" != "" ]; then
	    set -o allexport; source ~/.envs/$1/.env.$2; set +o allexport; export AWS_PROFILE=$2
    else
	    set -o allexport; source .env; set +o allexport;
    fi
}

gitorg() {
    if [ "$1" != "" ]; then
      gh repo list $1 --limit 1000 | while read -r repo _; do
        gh repo clone "$repo"
      done      
    else
	    echo -e "Please provide an org name to clone"
    fi
}

initshell() {
    if [ "$1" != "" ]; then
      chsh -s /usr/bin/zsh
    else
	    echo -e "Please provide an shell name to use"
    fi
}

checkport() {
    if [ "$1" != "" ]; then
      sudo lsof -i -P -n | grep LISTEN | grep $1
    else
      echo -e "Please provide a port number to check"
    fi
}

aws-session-start() {
  if [ "$1" != "" ]; then
    aws ssm start-session --region eu-west-2 --target $1 --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters=host=$2,portNumber=5432,localPortNumber=5432 
  else
    echo -e "Please target an instance to start a session"
  fi    
}


# ALIAS COMMANDS
alias configure="code ~/.zshrc"
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"
alias g="goto"
alias grep='grep --color'

alias ceb="code /home/bucky/code/eb"
alias csd="code /home/bucky/code/sd"

alias listshell="cat /etc/shells"
alias initconfig="yadm clone https://github.com/bucky-uk/dotfiles"

alias android-studio="$HOME/applications/android-studio/bin/studio.sh"
alias aws-ec2-list=" aws ec2 describe-instances --query \"Reservations[*].Instances[*].{InstanceId:InstanceId,PublicIP:PublicIpAddress,PrivateIP:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value,Type:InstanceType,Status:State.Name,VpcId:VpcId}\" --filters Name=instance-state-name,Values=running --output table"
alias aws-rds-list="aws rds describe-db-instances --query \"DBInstances[*].{DBInstanceIdentifier:DBInstanceIdentifier,Engine:Engine,Status:DBInstanceStatus,Endpoint:Endpoint.Address,Port:Endpoint.Port,InstanceClass:DBInstanceClass,MultiAZ:MultiAZ}\" --output table"
alias ss='aws ssm start-session --region eu-west-2 --target "$AWS_BASTION" --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters=host="$AWS_RDS_HOST",portNumber=5432,localPortNumber=5432'


# find out which distribution we are running on
LFILE="/etc/*-release"
MFILE="/System/Library/CoreServices/SystemVersion.plist"
if [[ -f $LFILE ]]; then
  _distro=$(awk '/^ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }')
elif [[ -f $MFILE ]]; then
  _distro="macos"
fi

# set an icon based on the distro
# make sure your font is compatible with https://github.com/lukas-w/font-logos
case $_distro in
    *kali*)                  ICON="ﴣ";;
    *arch*)                  ICON="";;
    *debian*)                ICON="";;
    *raspbian*)              ICON="";;
    *ubuntu*)                ICON="";;
    *elementary*)            ICON="";;
    *fedora*)                ICON="";;
    *coreos*)                ICON="";;
    *gentoo*)                ICON="";;
    *mageia*)                ICON="";;
    *centos*)                ICON="";;
    *opensuse*|*tumbleweed*) ICON="";;
    *sabayon*)               ICON="";;
    *slackware*)             ICON="";;
    *linuxmint*)             ICON="";;
    *alpine*)                ICON="";;
    *aosc*)                  ICON="";;
    *nixos*)                 ICON="";;
    *devuan*)                ICON="";;
    *manjaro*)               ICON="";;
    *rhel*)                  ICON="";;
    *macos*)                 ICON="";;
    *)                       ICON="";;
esac

export STARSHIP_DISTRO="$ICON"

# Load Starship
eval "$(starship init zsh)"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

export HISTFILE="$HOME/.zshhist"
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#eval "$(oh-my-posh --init --shell zsh --config ~/.poshthemes/angularic.omp.json)"
#source ~/code/romkatv/powerlevel10k/powerlevel10k.zsh-theme
