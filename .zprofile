# ~/.zprofile
# Environment setup (login shells). Keep this FAST and side-effect free.

# --- OS detection ---
case "$(uname -s)" in
  Darwin) export OS_TYPE="macos" ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      export OS_TYPE="wsl2"
    else
      export OS_TYPE="linux"
    fi
    ;;
  *) export OS_TYPE="unknown" ;;
esac

# --- PATH helpers ---
path_prepend() { [[ -d "$1" ]] && export PATH="$1:$PATH"; }
path_append()  { [[ -d "$1" ]] && export PATH="$PATH:$1"; }

# --- Homebrew (macOS + some Linux) ---
if [[ "$OS_TYPE" == "macos" ]] && [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- Android SDK ---
export ANDROID_HOME="$HOME/Android/Sdk"
path_append "$ANDROID_HOME/emulator"
path_append "$ANDROID_HOME/platform-tools"

# --- Yarn global bins (only if they exist) ---
path_prepend "$HOME/.yarn/bin"
path_prepend "$HOME/.config/yarn/global/node_modules/.bin"

# --- History file location (applies to interactive too) ---
export HISTFILE="$HOME/.zshhist"

# --- Runtime managers (availability only; do not fully init here) ---
# ASDF (preferred)
if [[ -r /opt/homebrew/opt/asdf/libexec/asdf.sh ]]; then
  export ASDF_DIR="/opt/homebrew/opt/asdf/libexec"
elif [[ -r "$HOME/.asdf/asdf.sh" ]]; then
  export ASDF_DIR="$HOME/.asdf"
fi

# NVM location (lazy-loaded in ~/.zshrc)
export NVM_DIR="$HOME/.nvm"
