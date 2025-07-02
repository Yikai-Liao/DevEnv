# This .zshrc is configured for the dev container environment.

# >>> conda initialize >>>
# !! Contents within this block are managed by \conda init\ !!
__conda_setup="$('/opt/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# Oh My Zsh user configuration
export ZSH="/opt/ohmyzsh"
ZSH_THEME="ys-me"
plugins=(
  z
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh

# Welcome message only if in an interactive shell
if [[ -o interactive ]]; then
  echo ""
  echo "======================================================================"
  echo "      🚀 Welcome to your ISOLATED Modern Development Environment! 🚀"
  echo "======================================================================"
  echo "  Base Image: NVIDIA CUDA 12.6.3 on Ubuntu 24.04"
  echo "  Tools (Conda, uv) are installed in /home/dev."
  echo "  Environment is loaded from /etc/zsh/zshrc"
  echo "======================================================================"
  echo ""
fi