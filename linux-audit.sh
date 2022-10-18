echo "警告：本脚本只是一个检查的操作，未对服务器做任何修改，管理员可以根据此报告进行相应的设置。"
echo "---------------------------主机安全检查---------------------------" >>audit.txt
echo "系统版本" >>audit.txt
uname -a >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "本机的ip地址是：" >>audit.txt
ifconfig | grep --color "\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
awk -F":" '{if($2!~/^!|^*/){print "("$1")" " 是一个未被锁定的账户，请管理员检查是否需要锁定它或者删除它。"}}' /etc/shadow >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
more /etc/login.defs | grep -E "PASS_MAX_DAYS" | grep -v "#" |awk -F' '  '{if($2!=90){print "/etc/login.defs里面的"$1 "设置的是"$2"天，请管理员改成90天。"}}' >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
more /etc/login.defs | grep -E "PASS_MIN_LEN" | grep -v "#" |awk -F' '  '{if($2!=6){print "/etc/login.defs里面的"$1 "设置的是"$2"个字符，请管理员改成6个字符。"}}' >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
more /etc/login.defs | grep -E "PASS_WARN_AGE" | grep -v "#" |awk -F' '  '{if($2!=10){print "/etc/login.defs里面的"$1 "设置的是"$2"天，请管理员将口令到期警告天数改成10天。"}}' >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo '查看口令复杂度设置：'  >>audit.txt
cat /etc/pam.d/system-auth  >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
grep TMOUT /etc/profile /etc/bashrc > /dev/null|| echo "未设置登录超时限制，请设置之，设置方法：在/etc/profile或者/etc/bashrc里面添加TMOUT=600参数" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
if ps -elf |grep xinet |grep -v "grep xinet";then >>audit.txt
echo "xinetd 服务正在运行，请检查是否可以把xinnetd服务关闭" >>audit.txt
else
echo "xinetd 服务未开启" >>audit.txt
fi
echo "----------------------------------------------------------------" >>audit.txt
echo "查看系统关键文件权限" >>audit.txt
ls -la /var/log/messages >>audit.txt
ls -la /var/log/messages.* >>audit.txt
ls -la /etc/shadow >>audit.txt
ls -la /etc/passwd >>audit.txt
ls -la /etc/group >>audit.txt
ls -la /etc/gshadow >>audit.txt
ls -la /etc/inittab >>audit.txt
ls -la /etc/profile >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看系统UMASK值" >>audit.txt
more /etc/profile | grep umask >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看系统密码文件修改时间" >>audit.txt
ls -ltr /etc/passwd >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo  "查看是否开启了ssh服务" >>audit.txt
if service sshd status | grep -E "listening on|active \(running\)"; then >>audit.txt
echo "SSH服务已开启" >>audit.txt
else
echo "SSH服务未开启" >>audit.txt
fi
echo "----------------------------------------------------------------" >>audit.txt
echo '检查root远程登录' >>audit.txt
cat /etc/ssh/sshd_config | grep -v ^# |grep "PermitRootLogin no" >>audit.txt
if [ $? -eq 0 ];then
  echo "已经设置远程root不能登陆，符合要求" >>audit.txt
else
  echo "不已经设置远程root不能登陆，不符合要求，建议/etc/ssh/sshd_config添加PermitRootLogin no" >>audit.txt
fi
echo "----------------------------------------------------------------" >>audit.txt
echo "查看是否开启了TELNET服务" >>audit.txt
if more /etc/xinetd.d/telnetd 2>&1|grep -E "disable=no"; then >>audit.txt
echo  "TELNET服务已开启 " >>audit.txt
else
echo  "TELNET服务未开启 " >>audit.txt
fi
echo "----------------------------------------------------------------" >>audit.txt
echo  "查看系统SSH远程访问设置策略(host.deny拒绝列表)" >>audit.txt
if more /etc/hosts.deny | grep -E "sshd: ";more /etc/hosts.deny | grep -E "sshd"; then >>audit.txt
echo  "远程访问策略已设置 " >>audit.txt
else
echo  "远程访问策略未设置 " >>audit.txt
fi
echo "----------------------------------------------------------------" >>audit.txt
echo  "查看系统SSH远程访问设置策略(hosts.allow允许列表)" >>audit.txt
if more /etc/hosts.allow | grep -E "sshd: ";more /etc/hosts.allow | grep -E "sshd"; then >>audit.txt
echo  "远程访问策略已设置 " >>audit.txt
else
echo  "远程访问策略未设置 " >>audit.txt
fi
echo "当hosts.allow和 host.deny相冲突时，以hosts.allow设置为准。" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看shell是否设置超时锁定策略" >>audit.txt
if more /etc/profile | grep -E "TIMEOUT= "; then >>audit.txt
echo  "系统设置了超时锁定策略 " >>audit.txt
else
echo  "未设置超时锁定策略 " >>audit.txt
fi
echo "----------------------------------------------------------------" >>audit.txt
echo "查看syslog日志审计服务是否开启" >>audit.txt
if service rsyslog status | egrep " active \(running";then >>audit.txt
echo "rsyslog服务已开启" >>audit.txt
else
echo "rsyslog服务未开启，建议通过service rsyslog start开启日志审计功能" >>audit.txt
fi
echo "----------------------------------------------------------------" >>audit.txt
echo "查看syslog日志是否开启外发" >>audit.txt
if more /etc/rsyslog.conf | egrep "@...\.|@..\.|@.\.|\*.\* @...\.|\*\.\* @..\.|\*\.\* @.\.";then >>audit.txt
echo "客户端syslog日志已开启外发" >>audit.txt
else
echo "客户端syslog日志未开启外发" >>audit.txt
fi
echo "----------------------------------------------------------------" >>audit.txt
echo "查看是否开启了审计服务" >>audit.txt
ps -ef | grep auditd >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看passwd文件中有哪些特权用户" >>audit.txt
awk -F: '$3==0 {print $1}' /etc/passwd >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看系统中是否存在空口令账户" >>audit.txt
awk -F: '($2=="!!") {print $1}' /etc/shadow >>audit.txt
echo "该结果不适用于Ubuntu系统" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看系统中root用户外连情况" >>audit.txt
lsof -u root |egrep "ESTABLISHED|SYN_SENT|LISTENING" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "ESTABLISHED的意思是建立连接。表示两台机器正在通信。" >>audit.txt
echo "LISTENING的" >>audit.txt
echo "SYN_SENT状态表示请求连接" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看系统中root用户TCP连接情况" >>audit.txt
lsof -u root |egrep "TCP" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看系统中存在哪些非系统默认用户" >>audit.txt
echo "root:x:“该值大于500为新创建用户，小于或等于500为系统初始用户”" >>audit.txt
more /etc/passwd |awk -F ":" '{if($3>500){print "/etc/passwd里面的"$1 "的值为"$3"，请管理员确认该账户是否正常。"}}' >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "检查系统守护进程" >>audit.txt
more /etc/xinetd.d/rsync | grep -v "^#" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "检查系统是否存在入侵行为" >>audit.txt
more /var/log/secure |grep refused >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "--------------------------路由表、网络连接、接口信息--------------" >>audit.txt
netstat -rn  >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看正常情况下登录到本机的所有用户的历史记录" >>audit.txt
last >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "检查系统中core文件是否开启" >>audit.txt
ulimit -c >>audit.txt
echo "core是unix系统的内核。当你的程序出现内存越界的时候,操作系统会中止你的进程,并将当前内存状态倒出到core文件中,以便进一步分析，如果返回结果为0，则是关闭了此功能，系统不会生成core文件" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "检查系统中关键文件修改时间" >>audit.txt
ls -ltr /bin/ls /bin/login /etc/passwd /bin/ps /usr/bin/top /etc/shadow|awk '{print "文件名："$8"  ""最后修改时间："$6" "$7}' >>audit.txt
echo "ls文件：是存储ls命令的功能函数，被删除以后，就无法执行ls命令，黑客可利用篡改ls文件来执行后门或其他程序
login文件：login是控制用户登录的文件，一旦被篡改或删除，系统将无法切换用户或登陆用户
user/bin/passwd是一个命令，可以为用户添加、更改密码，但是，用户的密码并不保存在/etc/passwd当中，而是保存在了/etc/shadow当中
etc/passwd是一个文件，主要是保存用户信息。
sbin/portmap是文件转换服务，缺少该文件后，无法使用磁盘挂载、转换类型等功能。
bin/ps 进程查看命令功能支持文件，文件损坏或被更改后，无法正常使用ps命令。
usr/bin/top  top命令支持文件，是Linux下常用的性能分析工具,能够实时显示系统中各个进程的资源占用状况。
etc/shadow shadow 是 /etc/passwd 的影子文件，密码存放在该文件当中，并且只有root用户可读。" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "---------------------------主机日志检查---------------------------" >>audit.txt
log=/var/log/syslog >>audit.txt
log2=/var/log/messages >>audit.txt
if [ -e "$log" ]; then
echo  "syslog日志文件存在！ " >>audit.txt
else
echo  "/var/log/syslog日志文件不存在！ " >>audit.txt
fi
if [ -e "$log2" ]; then
echo  "/var/log/messages日志文件存在！ " >>audit.txt
else
echo  "/var/log/messages日志文件不存在！ " >>audit.txt
fi
echo "----------------------------------------------------------------" >>audit.txt
echo "------------------------主机性能检查--------------------------------" >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "查看僵尸进程" >>audit.txt
ps -ef | grep zombie >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "耗CPU最多的进程" >>audit.txt
ps auxf |sort -nr -k 3 |head -5 >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
echo "耗内存最多的进程" >>audit.txt
ps auxf |sort -nr -k 4 |head -5 >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
cat /etc/security/limits.conf >>audit.txt
echo "----------------------------------------------------------------" >>audit.txt
