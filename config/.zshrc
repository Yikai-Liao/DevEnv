# This .zshrc is configured for the dev container environment.
export CUDA_HOME="/usr/local/cuda"

# Oh My Zsh user configuration
export ZSH="/etc/ohmyzsh"
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
  echo "  Environment is loaded from /etc/zsh/zshrc"
  echo "======================================================================"
  echo ""
fi