echo "警告：本脚本只是一个检查的操作，未对服务器做任何修改，管理员可以根据此报告进行相应的设置。"
echo "---------------------------当前系统信息---------------------------"
echo "系统版本"
cat /etc/redhat-release
echo "系统内核"
uname -a
echo "系统UMASK值"
more /etc/profile | grep umask
echo "系统密码文件修改时间"
ls -ltr /etc/passwd
echo '系统最近登录信息'
last
#echo "系统时间"
#date
#echo "系统运行时间"
#uptime
#echo "当前用户"
#who
#echo "本机的ip地址"
#if ! [ -x "$(command -v curl)" ]; then
#  ifconfig | grep --color "\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}"
#else
#  echo "ifconfig 命令不存在"
#fi
#echo "--------------------------路由表、网络连接、接口信息--------------"
#netstat -rn

echo "---------------------------用户用户组及密码文件-------------------------------------"
echo 'cat /etc/passwd'
cat /etc/passwd
echo "cat /etc/shadow"
cat /etc/shadow
echo 'cat /etc/group '
cat /etc/group
echo ''

echo "查看passwd文件中有哪些特权用户"
awk -F: '$3==0 {print $1}' /etc/passwd
echo "查看系统中存在哪些非系统默认用户"
more /etc/passwd |awk -F ":" '{if($3>500){print $1 " " $3}}'
echo "查看系统中是否有未锁定用户"
awk -F":" '{if($2!~/^!|^*/){print $1}}' /etc/shadow
echo "查看系统中是否存在空口令账户"
awk -F: '($2=="!!") {print $1}' /etc/shadow
echo "该结果不适用于Ubuntu系统"

echo "---------------------------密码安全设置-------------------------------------"
echo 'cat /etc/login.defs'
cat /etc/login.defs
echo ''
more /etc/login.defs | grep -E "PASS_MAX_DAYS" | grep -v "#" |awk -F' '  '{if($2!=90){print "/etc/login.defs里面的"$1 "设置的是"$2"天，请管理员改成90天。"}}'
more /etc/login.defs | grep -E "PASS_MIN_LEN" | grep -v "#" |awk -F' '  '{if($2!=6){print "/etc/login.defs里面的"$1 "设置的是"$2"个字符，请管理员改成6个字符。"}}'
more /etc/login.defs | grep -E "PASS_WARN_AGE" | grep -v "#" |awk -F' '  '{if($2!=10){print "/etc/login.defs里面的"$1 "设置的是"$2"天，请管理员将口令到期警告天数改成10天。"}}'

echo '---------------------------PAM模块---------------------------：'
echo 'cat /etc/pam.d/system.auth'
cat /etc/pam.d/system.auth
echo 'cat /etc/pam.d/system-auth'
cat /etc/pam.d/system-auth
echo 'cat /etc/pam.conf'
cat /etc/pam.conf
echo 'cat /etc/pam.d/login'
cat /etc/pam.d./login
echo ''

echo "--------------------------SSH访问策略---------------------------"
echo  "查看系统SSH远程访问设置策略(host.deny拒绝列表)"
if more /etc/hosts.deny | grep -E "sshd: ";more /etc/hosts.deny | grep -E "sshd"; then
  echo  "远程访问策略已设置 "
else
  echo  "远程访问策略未设置 "
fi
echo  "查看系统SSH远程访问设置策略(hosts.allow允许列表)"
if more /etc/hosts.allow | grep -E "sshd: ";more /etc/hosts.allow | grep -E "sshd"; then
  echo  "远程访问策略已设置 "
else
  echo  "远程访问策略未设置 "
fi
# "当hosts.allow和 host.deny相冲突时，以hosts.allow设置为准。"
echo "查看shell是否设置超时锁定策略"
if more /etc/profile | grep -E "TIMEOUT= "; then
  echo  "系统设置了超时锁定策略 "
else
  echo  "未设置超时锁定策略 "
fi
echo ''

echo "--------------------------提权日志--------------------------"
echo 'cat /var/log/sudo.log '
cat /var/log/sudo.log
echo 'cat /var/log/syslog '
cat /var/log/syslog
echo 'cat /var/adm/sulog '
cat /var/adm/sulog
echo 'cat /var/log/secure '
cat /var/log/secure
echo ''

echo "--------------------------sudo root账号--------------------------"
echo 'cat /etc/sudoers '
cat /etc/sudoers
echo ''

echo "--------------------------允许访问终端--------------------------"
echo 'cat /etc/securetty '
cat /etc/securetty
echo ''

echo "--------------------------查看系统关键文件权限------------------------"
echo 'ls -la /etc/exports '
ls -la /etc/exports
echo 'ls -la /etc/inetd.conf '
ls -la /etc/inetd.conf
echo 'ls -la /etc/passwd '
ls -la /etc/passwd
echo 'ls -la /etc/shadow '
ls -la /etc/shadow
echo 'ls -la /etc/group '
ls -la /etc/group
echo 'ls -la /var/log/messages '
ls -la /var/log/messages
echo 'ls -la /etc/services '
ls -la /etc/services
echo 'ls -la /etc/securetty '
ls -la /etc/securetty
echo 'ls -la /etc/ftpusers '
ls -la /etc/ftpusers
echo 'ls -la /etc/gshadow '
ls -la /etc/gshadow
echo 'ls -la /etc/inittab '
ls -la /etc/inittab
echo 'ls -la /etc/profile '
ls -la /etc/profile
echo ''

echo "----------------------------检查root远程登录--------------------------"
cat /etc/ssh/sshd_config | grep -v ^# |grep "PermitRootLogin no"
if [ $? -eq 0 ];then
  echo "已设置远程root不能登陆，符合要求"
else
  echo "未设置远程root不能登陆，不符合要求，建议/etc/ssh/sshd_config添加PermitRootLogin no"
fi
echo ''

echo "----------------------------------------------------------------"
grep TMOUT /etc/profile /etc/bashrc > /dev/null|| echo "未设置登录超时限制，请设置，设置方法：在/etc/profile或者/etc/bashrc里面添加TMOUT=600参数"

echo "----------------------------定时任务文件设置账号----------------------------"
echo 'cat /etc/cron.allow '
cat /etc/cron.allow
echo 'cat /etc/cron.deny '
cat /etc/cron.deny
echo 'cat /etc/at.allow '
cat /etc/at.allow
echo 'cat /etc/at.deny '
cat /etc/at.deny
echo 'cat /var/adm/cron/cron.allow'
cat /var/adm/cron/cron.allow
echo 'cat /var/adm/cron/at.allow'
cat /var/adm/cron/at.allow
echo 'cat /var/adm/cron/cron.deny'
cat /var/adm/cron/cron.deny
echo 'cat /var/adm/cron/at.deny'
cat /var/adm/cron/at.deny
echo ''

echo "----------------------------定时任务文件访问权限----------------------------"
echo 'ls -la /etc/cron.allow'
ls -la /etc/cron.allow
echo 'ls -la /etc/cron.deny '
ls -la /etc/cron.deny
echo 'ls -la /etc/at.allow '
ls -la /etc/at.allow
echo 'ls -la /etc/at.deny '
ls -la /etc/at.deny
echo 'ls -la /var/log/cron'
ls -la /var/log/cron
echo 'ls -la /var/spool/cron/* '
ls -la /var/spool/cron/*
echo 'ls -la /var/spool/at/* '
ls -la /var/spool/at/*
echo 'ls -la /etc/cron*'
ls -la /etc/cron*
echo 'ls -la /etc/at*'
ls -la /etc/at*
echo ''


echo "----------------------------cron及at定时任务文件----------------------------"
echo 'ls -l /var/spool/cron/ | grep -v "total" '
ls -l /var/spool/cron/ | grep -v "total"
echo 'ls -l /var/spool/at/ | grep -v "total" '
ls -l /var/spool/at/ | grep -v "total"
echo 'crontab -l'
crontab -l
echo ''

echo '----------------------------cron定时任务执行日志----------------------------'
echo 'cat /var/log/cron '
cat /var/log/cron
echo ''


echo "-----------------------查看服务开启状态-----------------------------------------"
if service sshd status | grep -E "listening on|active \(running\)"; then
  echo "SSH服务已开启"
else
  echo "SSH服务未开启"
fi
if more /etc/xinetd.d/telnetd 2>&1|grep -E "disable=no"; then
  echo "TELNET服务已开启 "
else
  echo "TELNET服务未开启 "
fi
if service rsyslog status | egrep " active \(running";then
  echo "rsyslog服务已开启"
else
  echo "rsyslog服务未开启，建议通过service rsyslog start开启日志审计功能"
fi
if more /etc/rsyslog.conf | egrep "@...\.|@..\.|@.\.|\*.\* @...\.|\*\.\* @..\.|\*\.\* @.\.";then
  echo "客户端syslog日志已开启外发"
else
  echo "客户端syslog日志未开启外发"
fi
if ps -ef | grep auditd; then
    echo "审计服务已开启"
  else
    echo "审计服务未开启"
fi
if ps -elf |grep xinet |grep -v "grep xinet";then
  echo "xinetd 服务正在运行，请检查是否可以把xinnetd服务关闭"
else
  echo "xinetd 服务未开启"
fi

echo "-------------------------查看root用户外连情况---------------------------------------"
lsof -u root |egrep "ESTABLISHED|SYN_SENT|LISTENING"
#"ESTABLISHED的意思是建立连接。表示两台机器正在通信。"
#"LISTENING的"
#"SYN_SENT状态表示请求连接"
echo "------------------------查看系统中root用户TCP连接情况------------------------------------"
lsof -u root |egrep "TCP"
echo "------------------------检查系统守护进程----------------------------------------"
more /etc/xinetd.d/rsync | grep -v "^#"
echo "-------------------------检查系统是否存在入侵行为---------------------------------------"
more /var/log/secure |grep refused

echo "--------------------------检查系统中core文件是否开启--------------------------------------"
ulimit -c
#core是unix系统的内核。当你的程序出现内存越界的时候,操作系统会中止你的进程,并将当前内存状态倒出到core文件中,以便进一步分析，如果返回结果为0，则是关闭了此功能，系统不会生成core文件
echo "--------------------------检查系统中关键文件修改时间--------------------------"
ls -ltr /bin/ls /bin/login /etc/passwd /bin/ps /usr/bin/top /etc/shadow|awk '{print "文件名："$9"  ""最后修改时间："$8" "$6" "$7}'
#ls文件：是存储ls命令的功能函数，被删除以后，就无法执行ls命令，黑客可利用篡改ls文件来执行后门或其他程序
#login文件：login是控制用户登录的文件，一旦被篡改或删除，系统将无法切换用户或登陆用户
#user/bin/passwd是一个命令，可以为用户添加、更改密码，但是，用户的密码并不保存在/etc/passwd当中，而是保存在了/etc/shadow当中
#etc/passwd是一个文件，主要是保存用户信息。
#sbin/portmap是文件转换服务，缺少该文件后，无法使用磁盘挂载、转换类型等功能。
#bin/ps 进程查看命令功能支持文件，文件损坏或被更改后，无法正常使用ps命令。
#usr/bin/top  top命令支持文件，是Linux下常用的性能分析工具,能够实时显示系统中各个进程的资源占用状况。
#etc/shadow shadow 是 /etc/passwd 的影子文件，密码存放在该文件当中，并且只有root用户可读。"
echo ""

echo "------------------------主机性能检查--------------------------------"
echo "查看僵尸进程"
ps -ef | grep zombie
echo "----------------------------------------------------------------"
echo "耗CPU最多的进程"
ps auxf |sort -nr -k 3 |head -5
echo "----------------------------------------------------------------"
echo "耗内存最多的进程"
ps auxf |sort -nr -k 4 |head -5
echo "----------------------------------------------------------------"
cat /etc/security/limits.conf
echo "----------------------------------------------------------------"



