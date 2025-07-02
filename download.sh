wget https://github.com/ClementTsang/bottom/releases/download/0.10.2/bottom_0.10.2-1_amd64.deb -O download/bottom.deb
wget https://github.com/bootandy/dust/releases/download/v1.2.1/du-dust_1.2.1-1_amd64.deb -O download/du-dust.deb
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O download/Miniforge3-Linux-x86_64.sh
wget https://astral.sh/uv/install.sh -O download/uv_install.sh
wget https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz -O download/zellij.tar.gz
tar -xzvf  download/zellij.tar.gz -C download/ && rm download/zellij.tar.gz