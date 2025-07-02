# Dockerfile for a robust, isolated, and modern development environment
# Base: NVIDIA CUDA 12.6.3 with cuDNN on Ubuntu 24.04
# Installs tools and configs under the non-root 'dev' user for better isolation.

FROM nvidia/cuda:12.6.3-cudnn-devel-ubuntu24.04

# Set non-interactive frontend for package installers to prevent prompts
ENV DEBIAN_FRONTEND=noninteractive

# Copy pre-downloaded packages and libcurl.so.4
COPY download/ /tmp/download/

# Remove NVIDIA CUDA apt sources to prevent fetching from NVIDIA repo
RUN apt-key del 7fa2af80 \
    && rm -rf /etc/apt/sources.list.d/cuda.list

RUN apt-get update \
    && apt-get install -y curl
RUN \
    mv /tmp/download/fast-apt-mirror.sh /usr/local/bin/fast-apt-mirror.sh \
    && chmod 755 /usr/local/bin/fast-apt-mirror.sh \
    && fast-apt-mirror.sh find --apply --speedtests 64 --parallel 4

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
    vim \
    bat \
    htop \
    nvtop \
    gocryptfs \
    python3-venv \
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

# Install pre-downloaded .deb packages and zellij
RUN dpkg -i /tmp/download/*.deb \
    && rm /tmp/download/*.deb \
    # Install zellij to /usr/bin
    && cp /tmp/download/zellij /usr/bin/zellij \
    && chmod 755 /usr/bin/zellij \
    && rm /tmp/download/zellij

# Install python-based tools
RUN echo "Installing Python-based tools..." \
    cd /opt \
    && python3 -m venv tools \
    && source tools/bin/activate \
    && pip install "huggingface-hub[hf_xet,cli]" gdown trash \
    && rm -rf ~/.cache/pip


# --- Stage 3: User-level installations and configurations ---
# All tools are installed in the user's home directory.
RUN \
    # --- Install uv to /usr/bin/uv ---
    echo "Installing uv to /usr/bin..." \
    && bash /tmp/download/uv_install.sh \
    && mv $HOME/.local/bin/uv /usr/bin/uv \
    && rm /tmp/download/uv_install.sh \  
    \
    # --- Install Oh My Zsh to opt ---
    && echo "Installing Oh My Zsh for user dev..." \
    && git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /opt/ohmyzsh \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /opt/ohmyzsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /opt/ohmyzsh/custom/plugins/zsh-syntax-highlighting

# --- Add custom theme ---
COPY config/ys-me.zsh-theme /opt/ohmyzsh/themes/ys-me.zsh-theme

# --- Configure user's .zshrc ---
COPY config/.zshrc /etc/zsh/zshrc

RUN \
    # give permission to all users
    touch /etc/zsh/.zshrc \
    && chmod 644 /etc/zsh/zshrc \
    && chmod 644 /etc/zsh/.zshrc \
    # give opt permission to all users
    && chmod -R 755 /opt \
    # --- Configure Git LFS for the user ---
    && echo "Configuring Git LFS for user dev..." \
    && git lfs install

# Set the default command to launch the Zsh shell
CMD ["/bin/zsh"]