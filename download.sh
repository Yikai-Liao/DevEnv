mkdir -p download
wget https://github.com/ClementTsang/bottom/releases/download/0.10.2/bottom_0.10.2-1_amd64.deb -O download/bottom.deb
wget https://github.com/bootandy/dust/releases/download/v1.2.1/du-dust_1.2.1-1_amd64.deb -O download/du-dust.deb
wget https://astral.sh/uv/install.sh -O download/uv_install.sh
wget https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz -O download/zellij.tar.gz
wget https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-musl_10.2.0_amd64.deb -O download/fd.deb
wget https://raw.githubusercontent.com/vegardit/fast-apt-mirror.sh/v1/fast-apt-mirror.sh -O download/fast-apt-mirror.sh
tar -xzvf  download/zellij.tar.gz -C download/ && rm download/zellij.tar.gz