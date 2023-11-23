#!/bin/bash
#先检查有没有安装net-tools,没有则安装
echo "1.检查wget,netstat是否安装"
if command -v wget > /dev/null; then
    yum -y install wget
fi
if  command -v netstat > /dev/null; then
    yum -y install net-tools
fi
# 关闭 防火墙
systemctl stop firewalld
systemctl disable firewalld

echo "2.请输入hostname:"
read hostname
hostnamectl set-hostname ${hostname}
echo "3.请输入本机IP:"
read ip
#截取网卡设备名 enp33
enp=$(ls /etc/sysconfig/network-scripts/|egrep ifcfg|grep "en.*" |awk -F '-' '{print $2}')
#网卡路径
enpway=/etc/sysconfig/network-scripts/ifcfg-${enp}
#截取路由
rt=$(netstat -rn|head -3|tail -1|awk -F ' ' '{print $2}')
#修改配置文件
sed -i 's/dhcp/static/g' ${enpway}
sed -i '/ONBOOT/c ONBOOT=yes' ${enpway}
#追加配置内容
cat >>/etc/sysconfig/network-scripts/ifcfg-${enp} <<EOF
NM_CONTROLLED=no
IPADDR=$ip

GATEWAY=${rt}
NETMASK=255.255.255.0
DNS1=223.5.5.5
DNS2=8.8.8.8
EOF
#重启网卡
systemctl restart network
