#!/bin/bash
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
# 关闭selinux
sudo setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 配置sshd
sed -i 's/#Port 22/Port 51000/g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
