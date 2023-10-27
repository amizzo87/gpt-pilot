FROM python:3.11

# Download precompiled ttyd binary from GitHub releases
RUN apt-get update && \
    apt-get install -y sudo wget vim build-essential psmisc net-tools lsof screen numactl ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings /data/db mkdir /var/log/mongodb /var/lib/mongodb && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin redis-server mongodb-org && \
    wget https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64 -O /usr/bin/ttyd && \
    wget https://raw.githubusercontent.com/amizzo87/gpt-pilot/main/etc/init.d/mongod -O /etc/init.d/mongod && \
    chmod 0755 /etc/init.d/mongod && service mongod start && \
    chmod +x /usr/bin/ttyd && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /root/.nvm

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install node \
    && nvm use node

WORKDIR /usr/src/app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
RUN python -m venv pilot-env
RUN /bin/bash -c "source pilot-env/bin/activate"

RUN pip install -r requirements.txt
WORKDIR /usr/src/app/pilot

EXPOSE 7681
EXPOSE 3000

CMD ["ttyd", "bash"]
