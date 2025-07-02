# Dockerfile for a robust, isolated, and modern development environment
# Base: NVIDIA CUDA 12.6.3 with cuDNN on Ubuntu 24.04
# Installs tools and configs under the non-root 'dev' user for better isolation.

FROM nvidia/cuda:12.6.3-cudnn-devel-ubuntu24.04

# Set non-interactive frontend for package installers to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-key del 7fa2af80

# --- Stage 1: Root-level setup for essential tools ---
# The CUDA base image already includes most build tools. We only add essentials.
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    build-essential \
    cmake \
    ninja-build \
    clang \
    zsh \
    axel \
    git-lfs \
    lsd \
    bat \
    gocryptfs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Create user 'dev' with home directory and zsh shell
    && useradd --create-home --shell /bin/zsh dev \
    # Add 'dev' to the sudo group
    && adduser dev sudo \
    # Set a password for 'dev' (e.g., 'dev')
    && echo "dev:dev" | chpasswd \
    # Configure passwordless sudo for the sudo group
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    # Create a workspace directory owned by 'dev'
    && mkdir /workspace \
    && chown -R dev:dev /workspace

RUN wget https://github.com/bootandy/dust/releases/download/v1.2.1/du-dust_1.2.1-1_amd64.deb \
    && dpkg -i du-dust_1.2.1-1_amd64.deb \
    && rm du-dust_1.2.1-1_amd64.deb

# --- Stage 3: User-level installations and configurations ---
# All tools are installed in the user's home directory.
RUN \
    # --- Install Miniforge to /home/dev/miniforge3 ---
    echo "Installing Miniforge to $HOME/miniforge3..." \
    && curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh" \
    && bash Miniforge3-Linux-x86_64.sh -b -p /opt/miniforge3 \
    && rm Miniforge3-Linux-x86_64.sh \
    \
    # --- Install uv to /usr/bin/uv ---
    && echo "Installing uv to $HOME/.local/bin..." \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv $HOME/.local/bin/uv /usr/bin/uv \  
    \
    # --- Install Oh My Zsh to opt ---
    && echo "Installing Oh My Zsh for user dev..." \
    && git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /opt/ohmyzsh \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /opt/ohmyzsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /opt/ohmyzsh/custom/plugins/zsh-syntax-highlighting

# --- Add custom theme ---
COPY ys-me.zsh-theme /opt/ohmyzsh/themes/ys-me.zsh-theme

# --- Configure user's .zshrc ---
COPY zshrc /etc/zsh/zshrc

RUN \
    # give permission to all users
    chmod 644 /etc/zsh/zshrc \
    # give opt permission to all users
    && chmod -R 755 /opt \
    # --- Configure Git LFS for the user ---
    && echo "Configuring Git LFS for user dev..." \
    && git lfs install

# Set the default command to launch the Zsh shell
CMD ["/bin/zsh"]