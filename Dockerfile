FROM ubuntu:18.04
LABEL maintainer="Nick Fan <nickfan81@gmail.com>"
ENV HOME /home/www
ENV HOMEPATH /home/www

RUN addgroup www && adduser --gecos "" --ingroup www --disabled-password www
USER root
RUN mkdir -p /data/{app/{backup,etc,tmp,certs,www,ops,downloads/temp},var/{log/app,run,tmp}}
RUN ln -nfs /data/var /data/app/var && \
    chown -R www:www /data/app && \
    chown -R www:www /data/var && \
    ln -nfs /home/www /home/user && \
    ln -nfs /data/app /data/wwwroot && \
    ln -nfs /data/var/log /data/wwwlogs && \
    ln -nfs /data/app /home/wwwroot && \
    ln -nfs /data/var/log /home/wwwlogs && \
    ln -nfs /home /Users
RUN mkdir -p ~/{bin,tmp,setup,opt,go/{src,bin,pkg},var/{log,tmp,run}} && \
    mkdir -p ~/{.local,.config,.yarn,.composer,.aria2} && \
    mkdir -p ~/Downloads/temp && \
    ln -nfs /data/app ~/Code

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    sudo net-tools iputils-ping iproute2 telnet curl wget procps traceroute iperf3 language-pack-en-base \
    zsh autojump \
    build-essential gcc g++ make cmake autoconf automake patch gdb libtool cpp pkg-config libc6-dev libncurses-dev sqlite sqlite3 openssl unixodbc pkg-config re2c keyboard-configuration bzip2 unzip p7zip unrar-free git-core mercurial wget curl nano vim lsof ctags vim-doc vim-scripts ed gawk screen tmux valgrind graphviz graphviz-dev xsel xclip mc urlview tree tofrodos proxychains privoxy socat zhcon supervisor certbot lrzsz mc htop iftop iotop nethogs dstat multitail tig jq ncdu ranger silversearcher-ag asciinema software-properties-common libxml2-dev libbz2-dev libexpat1-dev libssl-dev libffi-dev libsecret-1-dev libgconf2-4 libdb-dev libgmp3-dev zlib1g-dev linux-libc-dev libgudev-1.0-dev uuid-dev libpng-dev libjpeg-dev libfreetype6-dev libxslt1-dev libssh-dev libssh2-1-dev libpcre3-dev libpcre++-dev libmhash-dev libmcrypt-dev libltdl7-dev mcrypt libiconv-hook-dev libsqlite-dev libgettextpo0 libwrap0-dev libreadline-dev zookeeper zookeeper-bin libzookeeper-mt-dev ruby ruby-dev python python-dev python-pip python-setuptools python-lxml python3 python3-dev python3-pip python3-setuptools python3-venv python3-lxml \
    xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils fonts-wqy-microhei fonts-wqy-zenhei xfonts-wqy \
	;
RUN mkdir -p ~/setup && cd ~/setup && \
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb && \
    dpkg -i wkhtmltox_0.12.6-1.bionic_amd64.deb && \
    wget https://github.com/sharkdp/fd/releases/download/v8.2.1/fd_8.2.1_amd64.deb && \
    dpkg -i fd_8.2.1_amd64.deb && \
    wget https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb && \
    dpkg -i ripgrep_12.1.1_amd64.deb && \
    wget https://github.com/sharkdp/bat/releases/download/v0.17.1/bat_0.17.1_amd64.deb && \
    dpkg -i bat_0.17.1_amd64.deb

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
#    -t powerlevel10k/powerlevel10k \
    -p git \
    -p ssh-agent \
    -p z \
    -p autojump \
    -p history \
    -p last-working-dir \
    -p docker \
    -p github \
    -p httpie \
    -p jsontools \
    -p node \
    -p npm \
    -p golang \
    -p tmux \
    -p tmuxinator \
    -p catimg \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -a 'export ZSH_DISABLE_COMPFIX=true' \
    -a 'HIST_STAMPS="yyyy-mm-dd"' \
    -a 'autoload -U compinit && compinit' \
    -a 'export ZSH_TMUX_AUTOSTART=false' \
    -a 'export ZSH_TMUX_AUTOCONNECT=false' \
    -a 'zstyle :omz:plugins:ssh-agent agent-forwarding on' \
    -a 'if [ -f \$HOME/.myenvset ]; then source \$HOME/.myenvset;fi' \
    -a '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' \
    -a 'if [ "\$TERM" = "xterm-256color" ] && [ -z "\$INSIDE_EMACS" ]; then test -e "\${HOME}/.iterm2_shell_integration.zsh" && source "\${HOME}/.iterm2_shell_integration.zsh";fi'

USER www
WORKDIR ${HOMEPATH}
RUN mkdir -p ~/{bin,tmp,setup,opt,go/{src,bin,pkg},var/{log,tmp,run}} && \
    mkdir -p ~/{.local,.config,.yarn,.composer,.aria2} && \
    mkdir -p ~/Downloads/temp && \
    ln -nfs /data/app ~/Code

COPY customize.sh ${HOMEPATH}/customize.sh
RUN chmod +x ${HOMEPATH}/customize.sh && ${HOMEPATH}/customize.sh --install-cronjob

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
#    -t powerlevel10k/powerlevel10k \
    -p git \
    -p ssh-agent \
    -p z \
    -p autojump \
    -p history \
    -p last-working-dir \
    -p docker \
    -p github \
    -p httpie \
    -p jsontools \
    -p node \
    -p npm \
    -p golang \
    -p tmux \
    -p tmuxinator \
    -p catimg \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -a 'export ZSH_DISABLE_COMPFIX=true' \
    -a 'HIST_STAMPS="yyyy-mm-dd"' \
    -a 'autoload -U compinit && compinit' \
    -a 'export ZSH_TMUX_AUTOSTART=false' \
    -a 'export ZSH_TMUX_AUTOCONNECT=false' \
    -a 'zstyle :omz:plugins:ssh-agent agent-forwarding on' \
    -a 'if [ -f \$HOME/.myenvset ]; then source \$HOME/.myenvset;fi' \
    -a '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' \
    -a 'if [ "\$TERM" = "xterm-256color" ] && [ -z "\$INSIDE_EMACS" ]; then test -e "\${HOME}/.iterm2_shell_integration.zsh" && source "\${HOME}/.iterm2_shell_integration.zsh";fi'

RUN cd ~ && git clone https://github.com/gpakosz/.tmux.git && \
    ln -s -f .tmux/.tmux.conf && \
    cp .tmux/.tmux.conf.local .

RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p $HOME/miniconda

USER root
RUN rm -rf /var/lib/apt/lists/*;
RUN rm -rf ~/setup/*;
USER www
RUN rm -rf ~/setup/*;
