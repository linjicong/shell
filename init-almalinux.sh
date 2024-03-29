#!/bin/bash
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭selinux
sudo setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 配置sshd
if [ "$#" -ge 1 ]; then
  ssh_port=$1
  sed -i 's/#Port 22/Port $ssh_port/g' /etc/ssh/sshd_config
fi
sed -i 's/#PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# 系统更新
dnf upgrade -y

# 安装必备软件
dnf install vim sysstat net-tools nfs-utils gdisk telnet fpart rsync lrzsz -y
