#!/bin/bash
yum -y install rpcbind nfs-utils
systemctl start rpcbind
systemctl enable rpcbind
systemctl start nfs-server
systemctl enable nfs-server
netstat -antup | grep 2049
