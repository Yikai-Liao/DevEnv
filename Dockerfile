# Dockerfile for a robust, isolated, and modern development environment
# Base: NVIDIA CUDA 12.6.3 with cuDNN on Ubuntu 24.04
# Installs tools and configurations under the non-root 'dev' user for better isolation.

FROM nvidia/cuda:12.6.3-devel-ubuntu24.04

# Set non-interactive frontend for package installers
ENV DEBIAN_FRONTEND=noninteractive

# Copy pre-downloaded packages
COPY download/ /tmp/download/

# Remove NVIDIA CUDA apt sources and update package list
RUN apt-key del 7fa2af80 \
    && rm -rf /etc/apt/sources.list.d/cuda.list \
    && sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu/|' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's|http://security.ubuntu.com/ubuntu/|http://mirrors.tuna.tsinghua.edu.cn/ubuntu/|' /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update \
    && apt-get remove -y --allow-change-held-packages "*nsight*"

# --- Stage 1: Root-level setup for essential tools and user creation ---
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:apt-fast/stable \
    && apt-get update \
    && apt-get install -y apt-fast aria2 \
    && apt-fast install -y \
    # Core utilities and system tools
    sudo \
    curl \
    wget \
    unzip \
    zsh \
    axel \
    git-lfs \
    gocryptfs \
    # Build tools
    build-essential \
    cmake \
    gcc \
    g++ \
    ninja-build \
    # Monitoring and viewing tools
    lsd \
    vim \
    bat \
    htop \
    nvtop \
    # Python related tools
    python3-venv \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /workspace

# Install pre-downloaded .deb packages and zellij
RUN dpkg -i /tmp/download/*.deb \
    && rm /tmp/download/*.deb \
    && cp /tmp/download/zellij /usr/bin/zellij \
    && chmod 755 /usr/bin/zellij \
    && rm /tmp/download/zellij

# Install Python-based tools
RUN echo "Installing Python-based tools..." \
    && python3 -m venv /opt/tools \
    && /opt/tools/bin/pip install "huggingface-hub[hf_xet,cli]" gdown trash glances \
    && ln -s /opt/tools/bin/huggingface-cli /usr/local/bin/huggingface-cli \
    && ln -s /opt/tools/bin/gdown /usr/local/bin/gdown \
    && ln -s /opt/tools/bin/trash /usr/local/bin/trash \
    && ln -s /opt/tools/bin/glances /usr/local/bin/glances \
    && rm -rf ~/.cache/pip

# --- Stage 2: User-level installations and configurations ---

RUN \
    # Install uv to /usr/local/bin/uv
    echo "Installing uv to /usr/local/bin..." \
    && bash /tmp/download/uv_install.sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv \
    && rm /tmp/download/uv_install.sh \
    \
    # Install Oh My Zsh
    && echo "Installing Oh My Zsh for user dev..." \
    && git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /etc/ohmyzsh \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /etc/ohmyzsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /etc/ohmyzsh/custom/plugins/zsh-syntax-highlighting \
    \
    # Configure Git LFS
    && echo "Configuring Git LFS for user dev..." \
    && git lfs install


# Copy custom theme and .zshrc to user's home directory
COPY config/ys-me.zsh-theme /etc/ohmyzsh/themes/ys-me.zsh-theme
COPY config/.zshrc /etc/zsh/.zshrc

# Set permissions for Oh My Zsh and user-specific files
RUN chmod -R 755 /etc/ohmyzsh \
    && chmod 644 /etc/zsh/.zshrc \
    && cp /etc/zsh/.zshrc /etc/zsh/zshrc

# Set default command to launch Zsh shell

CMD ["/bin/zsh"]