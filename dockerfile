FROM kalilinux/kali-rolling:latest
LABEL maintainer="admin@csalab.id"

# Update package sources and install GPG keys first
RUN apt-get update && \
    apt-get install -y gnupg ca-certificates wget && \
    wget -q -O /usr/share/keyrings/kali-archive-keyring.gpg https://archive.kali.org/archive-key.asc && \
    echo "deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" > /etc/apt/sources.list

# Install desktop environment and tools
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y upgrade && \
    apt-get -yq install \
    sudo \
    openssh-server \
    python3 \
    python3-pip \
    dialog \
    firefox-esr \
    inetutils-ping \
    htop \
    nano \
    net-tools \
    tigervnc-standalone-server \
    tigervnc-xorg-extension \
    tigervnc-viewer \
    novnc \
    dbus-x11

# Install desktop environment and Kali tools
RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install \
    xfce4 \
    xfce4-goodies \
    kali-desktop-xfce \
    kali-tools-top10 \
    metasploit-framework \
    nmap \
    hydra \
    john \
    sqlmap \
    aircrack-ng \
    wireshark && \
    apt-get -y full-upgrade

# Cleanup to reduce image size
RUN apt-get -y autoremove && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m -c "Kali Linux" -s /bin/bash -d /home/kali kali && \
    sed -i "s/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g" /etc/ssh/sshd_config && \
    sed -i "s/off/remote/g" /usr/share/novnc/app/ui.js && \
    echo "kali ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /run/dbus && \
    touch /usr/share/novnc/index.htm

# Setup startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

USER kali
WORKDIR /home/kali
ENV PASSWORD=kalilinux
ENV SHELL=/bin/bash
EXPOSE 8080

ENTRYPOINT ["/bin/bash", "/startup.sh"]