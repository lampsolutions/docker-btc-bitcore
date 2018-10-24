#!/bin/sh

cd /opt/bitcore/mynode/
exec /sbin/setuser bitcore /usr/local/bin/bitcore-node start >> /var/log/bitcore-node.log 2>&1
