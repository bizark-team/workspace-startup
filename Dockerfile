# syntax = docker/dockerfile:experimental
ARG USER_NAME="www"
ARG USER_PASSWORD="abc123"
#ARG ZSH_THEME="ys"
ARG ZSH_THEME="powerlevel10k"
ARG TERM="xterm-256color"
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=etc/UTC
ARG CONDA_ENV_NAME="myenv"
ARG CONDA_ENV_PY_VER="3.7"

FROM ubuntu:18.04
LABEL maintainer="Nick Fan <nickfan81@gmail.com>"
ARG DEBIAN_FRONTEND
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND}
ARG TZ
ENV TZ=${TZ}
ARG USER_NAME
ARG USER_PASSWORD
ENV USER_NAME=${USER_NAME}
ENV USER_PASSWORD=${USER_PASSWORD}
ARG TERM
ENV TERM=${TERM}
ARG ZSH_THEME
ENV ZSH_THEME=${ZSH_THEME}
ARG CONDA_ENV_NAME
ENV CONDA_ENV_NAME=${CONDA_ENV_NAME}
ARG CONDA_ENV_PY_VER
ENV CONDA_ENV_PY_VER=${CONDA_ENV_PY_VER}

#ENV HOME /home/${USER_NAME}
ENV HOMEPATH /home/${USER_NAME}
SHELL ["/bin/bash", "-c"]

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    sudo net-tools iputils-ping iproute2 telnet curl wget nano procps traceroute iperf3 gnupg-agent apt-transport-https ca-certificates software-properties-common openssh-client openssh-server ntp ntpdate language-pack-en-base language-pack-zh-hans \
    zsh autojump fonts-powerline xfonts-75dpi xfonts-base xfonts-encodings xfonts-utils fonts-wqy-microhei fonts-wqy-zenhei xfonts-wqy && \
    chsh -s /bin/zsh root && \
    addgroup ${USER_NAME} && adduser --quiet --disabled-password --shell /bin/zsh --ingroup ${USER_NAME} --home /home/${USER_NAME} --gecos "User" ${USER_NAME} && \
    echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo ${USER_NAME} && usermod -aG adm ${USER_NAME} && usermod -aG www-data ${USER_NAME} && \
    sed -i -E "s/^Defaults env_reset/Defaults env_reset, timestamp_timeout=-1/g" /etc/sudoers && \
    sed -i -E "/\.myenvset/d" /root/.profile && \
    echo "export PATH=$PATH:/usr/local/go/bin" >> /root/.profile && \
    echo "if [ -f $HOME/.myenvset ]; then source $HOME/.myenvset;fi" >> /root/.profile && \
    echo 'JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"' >> /etc/environment && \
    echo 'GOROOT="/usr/local/go"' >> /etc/environment && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    mkdir -p /data/{app/{backup,etc,tmp,certs,www,ops,downloads/temp},var/{log/app,run,tmp}} && \
    ln -nfs /data/var /data/app/var && \
    chown -R ${USER_NAME}:${USER_NAME} /data/app && \
    chown -R ${USER_NAME}:${USER_NAME} /data/var && \
    ln -nfs /home/${USER_NAME} /home/user && \
    ln -nfs /data/app /data/wwwroot && \
    ln -nfs /data/var/log /data/wwwlogs && \
    ln -nfs /data/app /home/wwwroot && \
    ln -nfs /data/var/log /home/wwwlogs && \
    ln -nfs /home /Users
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash -
RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN add-apt-repository ppa:neovim-ppa/stable
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    nodejs yarn vim-nox neovim python-neovim python3-neovim xxd wamerican \
    redis-tools mysql-client \
    build-essential gcc g++ make cmake autoconf automake patch gdb libtool cpp pkg-config libc6-dev libncurses-dev sqlite sqlite3 openssl unixodbc pkg-config re2c keyboard-configuration bzip2 unzip p7zip unrar-free git-core mercurial wget curl nano vim lsof ctags vim-doc vim-scripts ed gawk screen tmux valgrind graphviz graphviz-dev xsel xclip mc urlview tree tofrodos proxychains privoxy socat zhcon supervisor certbot lrzsz mc htop iftop iotop nethogs dstat multitail tig jq ncdu ranger silversearcher-ag asciinema software-properties-common libxml2-dev libbz2-dev libexpat1-dev libssl-dev libffi-dev libsecret-1-dev libgconf2-4 libdb-dev libgmp3-dev zlib1g-dev linux-libc-dev libgudev-1.0-dev uuid-dev libpng-dev libjpeg-dev libfreetype6-dev libxslt1-dev libssh-dev libssh2-1-dev libpcre3-dev libpcre++-dev libmhash-dev libmcrypt-dev libltdl7-dev mcrypt libiconv-hook-dev libsqlite-dev libgettextpo0 libwrap0-dev libreadline-dev zookeeper zookeeper-bin libzookeeper-mt-dev gnupg2 pass rng-tools software-properties-common ruby ruby-dev python python-dev python-pip python-setuptools python-lxml python3 python3-dev python3-pip python3-setuptools python3-venv python3-lxml openjdk-8-jdk maven
RUN mkdir -p ~/{bin,tmp,setup,opt,go/{src,bin,pkg},var/{log,tmp,run}} && \
    mkdir -p ~/{.ssh/{config.d,ctrl.d},.local,.config,.cache,.m2,.yarn,.npm,.node-gyp,.composer,.aria2} && \
    mkdir -p ~/Downloads/temp && \
    ln -nfs /data/app ~/Code

RUN mkdir -p ~/setup && cd ~/setup && \
    wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb && \
    dpkg -i wkhtmltox_0.12.6-1.bionic_amd64.deb && \
    wget https://github.com/sharkdp/fd/releases/download/v8.2.1/fd_8.2.1_amd64.deb && \
    dpkg -i fd_8.2.1_amd64.deb && \
    wget https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb && \
    dpkg -i ripgrep_12.1.1_amd64.deb && \
    wget https://github.com/sharkdp/bat/releases/download/v0.17.1/bat_0.17.1_amd64.deb && \
    dpkg -i bat_0.17.1_amd64.deb && \
    wget https://golang.org/dl/go1.16.6.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.6.linux-amd64.tar.gz && \
echo $' \n\
export GOROOT="/usr/local/go" \n\
export PATH="$PATH:/usr/local/go/bin" \n\
' > /etc/profile.d/go

RUN wget -O ~/.p10k.zsh https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-lean.zsh && sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
    -t powerlevel10k/powerlevel10k \
    -p git \
    -p ssh-agent \
    -p z \
    -p autojump \
    -p history \
    -p last-working-dir \
    -p docker \
    -p github \
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
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -a 'export ZSH_DISABLE_COMPFIX=true' \
    -a 'HIST_STAMPS="yyyy-mm-dd"' \
    -a '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' \
    -a 'export ZSH_TMUX_AUTOSTART=false' \
    -a 'export ZSH_TMUX_AUTOCONNECT=false' \
    -a 'zstyle :omz:plugins:ssh-agent agent-forwarding on' \
    -a 'if [ -f $HOME/.myenvset ]; then source $HOME/.myenvset;fi' \
    -a '[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh' \
    -a 'if [ "$TERM" = "xterm-256color" ] && [ -z "$INSIDE_EMACS" ]; then test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh";fi'
RUN sed -i -E "/POWERLEVEL9K_/d" /root/.zshrc && \
    cp -af /root/.oh-my-zsh /home/${USER_NAME}/ && \
    cp -af /root/.zshrc /home/${USER_NAME}/ && sed -i 's/root/home\/${USER_NAME}/g' /home/${USER_NAME}/.zshrc && \
    cp -af /root/.p10k.zsh /home/${USER_NAME}/ && \
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.oh-my-zsh && \
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.zshrc && \
    chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.p10k.zsh

RUN cd ~ && git clone https://github.com/gpakosz/.tmux.git && \
    ln -s -f .tmux/.tmux.conf && \
    cp .tmux/.tmux.conf.local . && \
    sed -i -E '/^# -- clipboard/,$d' ~/.tmux.conf.local && \
    echo $' \n\
tmux_conf_copy_to_os_clipboard=true \n\
bind - splitw -v # vertical split (prefix -)  \n\
bind | splitw -h # horizontal split (prefix |)  \n\
tmux_conf_theme_24b_colour=true \n\
set -g history-limit 10000 \n\
set -g mouse on \n\
set -gu prefix2 \n\
unbind C-a \n\
unbind C-b \n\
set -g prefix C-g \n\
bind C-g send-prefix \n\
' >> ~/.tmux.conf.local && \
    cp -af /root/.tmux.conf.local /home/${USER_NAME}/ && chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.tmux.conf.local && \
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

#RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
#    bash ~/miniconda.sh -b -p /root/miniconda3

USER ${USER_NAME}
WORKDIR ${HOMEPATH}
RUN mkdir -p ~/{bin,tmp,setup,opt,go/{src,bin,pkg},var/{log,tmp,run}} && \
    mkdir -p ~/{.ssh/{config.d,ctrl.d},.local,.config,.cache,.m2,.yarn,.npm,.node-gyp,.composer,.aria2} && \
    mkdir -p ~/.local/share/fonts && \
    mkdir -p ~/Downloads/temp && \
    ln -nfs /data/app ~/Code && \
    cd ~/tmp && \
    git clone https://github.com/powerline/fonts.git --depth=1 && \
    cd ~/tmp/fonts && \
    ~/tmp/fonts/install.sh && \
    cd ~/.local/share/fonts && rm -rf ~/tmp/fonts && \
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip && \
    unzip Hack.zip && \
    rm -rf Hack.zip && \
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Meslo.zip && \
    unzip Meslo.zip && \
    rm -rf Meslo.zip && \
    fc-cache -vf

RUN sed -i -E "/\.myenvset/d" ${HOMEPATH}/.profile && \
    echo "export PATH=$PATH:/usr/local/go/bin" >> ${HOMEPATH}/.profile && \
    echo "if [ -f $HOME/.myenvset ]; then source $HOME/.myenvset;fi" >> ${HOMEPATH}/.profile && \
    cp -n /usr/share/maven/conf/settings.xml ~/.m2/
RUN curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
RUN cd ~ && git clone https://github.com/gpakosz/.tmux.git && \
    ln -s -f .tmux/.tmux.conf && \
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p ${HOME}/miniconda3
RUN echo $' \n\
show_channel_urls: true \n\
auto_activate_base: true \n\
report_errors: false \n\
channels: \n\
  - defaults \n\
  - conda-forge \n\
' > ~/.condarc
RUN /home/${USER_NAME}/miniconda3/bin/conda init zsh && . ~/.zshrc && conda update -y -n base -c defaults conda && conda create -y --name ${CONDA_ENV_NAME} python=${CONDA_ENV_PY_VER} && \
    conda install -y -n ${CONDA_ENV_NAME} pip setuptools wheel && \
    conda install -y -n ${CONDA_ENV_NAME} -c conda-forge nodejs=12 yarn=1.22 && \
    conda activate ${CONDA_ENV_NAME} && \
    echo "source /home/${USER_NAME}/miniconda3/bin/activate ${CONDA_ENV_NAME}" >> ~/.zshrc && \
    source /home/${USER_NAME}/miniconda3/bin/activate ${CONDA_ENV_NAME}
RUN /home/${USER_NAME}/miniconda3/envs/${CONDA_ENV_NAME}/bin/pip install -U pip setuptools wheel six pqi
USER root
RUN ln -nfs /home/${USER_NAME}/miniconda3/envs/${CONDA_ENV_NAME}/bin/node /usr/local/bin/
USER ${USER_NAME}
RUN /home/${USER_NAME}/miniconda3/envs/${CONDA_ENV_NAME}/bin/npm install -g nrm yrm cnpm cyarn pm2@latest typescript npm-check @vue/cli @vue/cli-service-global @vue/cli-init
USER root
RUN env PATH=$PATH:/home/${USER_NAME}/miniconda3/envs/${CONDA_ENV_NAME}/bin /home/${USER_NAME}/miniconda3/envs/${CONDA_ENV_NAME}/lib/node_modules/pm2/bin/pm2 startup upstart -u ${USER_NAME} --hp /home/${USER_NAME}
COPY customize.sh ${HOMEPATH}/customize.sh
RUN chmod +x ${HOMEPATH}/customize.sh && chown ${USER_NAME}:${USER_NAME} ${HOMEPATH}/customize.sh
USER ${USER_NAME}
RUN /home/${USER_NAME}/miniconda3/envs/${CONDA_ENV_NAME}/bin/pm2 update && /home/${USER_NAME}/miniconda3/envs/${CONDA_ENV_NAME}/bin/pm2 install pm2-logrotate && \
    curl -sLf https://spacevim.org/install.sh | bash
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y -q
RUN ${HOMEPATH}/customize.sh --install-cronjob

USER root
RUN rm -rf /var/lib/apt/lists/* && rm -rf ~/setup/* && rm -rf ~/miniconda.sh
RUN printf "%b" '#!'"/usr/bin/env sh\n \
if [ \"\$1\" = \"daemon\" ];  then \n \
 cron -f \n \
else \n \
 exec \$@ \n \
fi" >/entry.sh && chmod +x /entry.sh

USER ${USER_NAME}
RUN rm -rf ~/setup/* && rm -rf ~/miniconda.sh
VOLUME ["/data/app"]
ENTRYPOINT ["/entry.sh"]
CMD ["zsh"]
