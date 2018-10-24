FROM phusion/baseimage:0.11
ARG DEBIAN_FRONTEND=noninteractive

ENV BITCORE_NODE_VERSION 3.1.3
ENV BITCORE_NODE /usr/local/bin/bitcore-node
ENV BITCORE_PATH /opt/bitcore
ENV DAEMON_USER bitcore

# Update & install dependencies and do cleanup
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
        nodejs \
        npm \
        inetutils-ping \
        build-essential \
        libzmq3-dev \
        curl \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add bitcore system user
RUN useradd -m -r -d $BITCORE_PATH -s /bin/bash $DAEMON_USER

# Install node
RUN npm install --unsafe-perm=true -g bitcore-node@$BITCORE_NODE_VERSION

# Switch user for setting up dashcore services
USER $DAEMON_USER
RUN cd ~ && \
    bitcore-node create mynode && \
    cd mynode && \
    $BITCORE_NODE install insight-api && \
    $BITCORE_NODE install insight-ui

USER root
# Add our startup script
RUN mkdir /etc/service/bitcore-node
COPY bitcore-node.sh /etc/service/bitcore-node/run
RUN chmod +x /etc/service/bitcore-node/run

EXPOSE 3001
VOLUME ["$BITCORE_PATH/mynode/data/"]
CMD ["/sbin/my_init"]
