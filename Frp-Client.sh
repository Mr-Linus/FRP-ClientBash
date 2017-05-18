#!/bin/bash
green='\e[1;32m' # green
red='\e[1;31m' # red
blue='\e[1;34m' # blue  
nc='\e[0m' # normal
#set temp step
rand1=$RANDOM 
rand2=$RANDOM
clear 

download(){
	echo -n "下载FRP . . ."
	sleep 0.3 
	echo -n "."
	rm -rf /etc/frp/ >/dev/null 2>&1  
	mkdir /etc/frp
	wget -O /etc/frp/frp.tar.gz $1
	if [ $? == 0 ] ; then
		echo -e "[${green}成功${nc}]"
	else
		echo -e "[${red}失败${nc}]"
		exit 1
	fi
}

install(){
	echo -n "Installing Frp . . ."
	pcd=`pwd`
	cd /etc/frp/
	sleep 0.3
	echo -n "."
	tar zxf /etc/frp/frp.tar.gz 
	if [ $? == 0 ] ; then
		echo -e "[${green}成功${nc}]"
	else
		echo -e "[${red}失败${nc}]"
		exit 1
	fi
	rm -f /etc/frp/frp.tar.gz
	mv frp_0.* frp-config
	cd $pcd
}

cat << EOF
=========================================================================
______           _          
|  ___|         | |         
| |_ _   _ _ __ | | ___   _ 
|  _| | | | '_ \| |/ / | | |
| | | |_| | | | |   <| |_| |
\_|  \__,_|_| |_|_|\_\\__, |
                       __/ |
                      |___/ 
					  
欢迎使用FRP内网映射脚本
=========================================================================
Author: Mr Funky <QQ:708863861>
版本更新：更新启动脚本功能,断线重连功能
=========================================================================
USER: $USER   HOST: $HOSTNAME  KERNEL: `uname -r`  
DISK :`ls  /dev/?d? 2>/dev/null`
你确定要安装吗？【Y/y】
EOF
config(){
	echo -n "设置FRP Frp . . ."
	pcd=`pwd`
	cd /etc/frp/frp-config
	sleep 0.3
	echo -n "."
	rm -f frpc.ini
	touch frpc.ini
	while (true) do
	read -p  "请输入FRP服务端密码:[geekfan.top123]" password
	if [ ! $password ] ;then
		password=geekfan.top123
	fi
	read -p  "确认密码: $password ? [y/n]" yn
	if [ $yn == 'Y' -o $yn == 'y' ] ;then
		break
	fi
	done
	while (true) do
	read -p  "请输入FRP服务端域名:[www.funkystars.cn]" IP
	if [ ! $IP ] ;then
		IP=www.funkystars.cn
	fi
	read -p  "确认FRP服务端域名: $IP ? [y/n]" yn
	if [ $yn == 'Y' -o $yn == 'y' ] ;then
		break
	fi
	done
	while (true) do
	read -p  "请输入本地IP:[127.0.0.1] ? " Local
	if [ ! $Local ] ;then
		Local=127.0.0.1
	fi
	read -p  "确认本地IP: $Local ? [y/n] " yn
	if [ $yn == 'Y' -o $yn == 'y' ] ;then
		break
	fi
	done
	while (true) do
	read -p  "请输入FRP客户端域名:[www.youname.com]" Domain
	if [ ! $Domain ] ;then
		Domain=www.youname.com
	fi	
	read -p  "确认客户端域名: $Domain ? [y/n] " yn
	if [ $yn == 'Y' -o $yn == 'y' ] ;then
		break
	fi
	done
	while (true) do
	read -p  "请设置HTTP端口隧道名称:[$rand1]" HTTP
	if [ ! $HTTP ] ;then
		HTTP=$rand1
	fi
	read -p  "确认HTTP端口隧道名称: $HTTP ? [y/n]" yn
	if [ $yn == 'Y' -o $yn == 'y' ] ;then	
		break
	fi
	done
	while (true) do
	read -p  "请设置SSH端口隧道名称(默认SSH端口):[$rand2]" SSH
	if [ ! $SSH ] ;then
		SSH=$rand2
	fi
	read -p  "确认SSH端口隧道名称: $SSH ? [y/n] " yn
	if [ $yn == 'Y' -o $yn == 'y' ] ;then
		break
	fi
	done
	
cat > frpc.ini <<EOF
[common]
server_addr = $IP
server_port = 7000
log_file = ./frpc.log
log_level = info
log_max_days = 3
privilege_token = $password

[$HTTP]
privilege_mode = true
type = http
local_ip = $Local
local_port = 80
custom_domains = $Domain

[$SSH]
privilege_mode = true
type = tcp
remote_port = $rand2
local_ip = $Local
local_port = 22
use_gzip = true use_encrypti
EOF

sudo cat > /etc/init.d/frp <<EOF
#!/bin/bash
# chkconfig: - 99 2
# description: FRP Client Control Script
green='\e[1;32m' 
red='\e[1;31m' 
nc='\e[0m'
PIDF=\` ps  -A | grep frpc | awk '{print \$1}'\`
PIDK=\` ps  -A | grep keepalived | awk '{print \$1}'\`
case "\$1" in
        start)
		echo -n "FRP 正在启动..."
        nohup /etc/frp/frp-config/frpc -c /etc/frp/frp-config/frpc.ini >/dev/null 2>&1  &
		RE=\$?
		nohup /etc/frp/frp_keepalived >/dev/null 2>&1  &
		if [ \$? -eq 0 -o \$RE -eq 0 ] 2> /dev/null ; then
				sleep 1
				echo -e "[\${green}成功\${nc}]"
		else 
				echo -e "[\${red}失败\${nc}]"
		fi
        ;;
        stop)
		echo -n "FRP 正在停止..."
        kill -9 \$PIDF
		RE=\$?
		kill -9  \$PIDK
		if [ \$? -eq 0 -o \$RE -eq 0 ] 2> /dev/null ; then
				sleep 1
				echo -e "[\${green}成功\${nc}]"
		else 
				echo -e "[\${red}失败\${nc}]"
		fi		
        ;;
        restart)
        \$0 stop &> /dev/null
        if [ \$? -ne 0 ] 2> /dev/null ; then continue ; fi
        \$0 start
        ;;
        reload)
		echo -n "FRP 正在平滑重启..."
        kill -1 \$PIDF
		RE=\$?
		kill -1 \$PIDK
		if [ \$? -eq 0 -o \$RE -eq 0 ] 2> /dev/null ; then
				sleep 1
				echo -e "[\${green}成功\${nc}]"
		else 
				echo -e "[\${red}失败\${nc}]"
		fi
        ;;
		status)
		echo "FRP 当前状态:"
		cat /frpc.log
		;;
        *)
        echo "Userage: \$0 { start | stop | restart | reload | status }"
        exit 1
esac
exit 0

EOF


chmod +x /etc/init.d/frp

	if [ $? == 0 ] ; then
		echo -e "[${green}成功${nc}]"
	else
		echo -e "[${red}失败${nc}]"
		exit 1
	fi
	cd $pcd
}
frp_keepalived(){
cat > /etc/frp/frp_keepalived << EOF
#!/bin/bash
while  :
do
	PIDF=\` ps  -A | grep frpc | awk '{print \$1}'\`
	if [ \$PIDF -eq 0 ];then
	   nohup /etc/frp/frp-config/frpc -c /etc/frp/frp-config/frpc.ini >/dev/null 2>&1  &	
	fi
	sleep 60
done
EOF
chmod +x /etc/frp/frp_keepalived
}


read -p "请输入Y/y确定安装" key
case $key in 
	"y"|"Y"|"")		
		cat << EOF
请输入你的Linux系统类型:
(1)X86			(2)X64
(3)ARM、树莓派		(4)Mitps
(5)Mitps64 		(6)Mitpsle
(7)Mitps64le 
(8)	如果已经下载好了FRP 
	请将下载好的文件保存到/etc/frp下
	并重命名为frp.tar.gz

EOF
		read -p "请输入序号:" key
		case $key in
			1)
				download http://mirrors.tdsast.cn/frp/frp_0.9.3_linux_386.tar.gz
			;;
			2)
				download http://mirrors.tdsast.cn/frp/frp_0.9.3_linux_amd64.tar.gz
			;;
			3)	
				download http://mirrors.tdsast.cn/frp/frp_0.9.3_linux_arm.tar.gz
			;;
			4)
				download http://mirrors.tdsast.cn/frp/frp_0.9.3_linux_mips.tar.gz
			;;
			5)
				download http://mirrors.tdsast.cn/frp/frp_0.9.3_linux_mips64.tar.gz
			;;
			6)
				download http://mirrors.tdsast.cn/frp/frp_0.9.3_linux_mipsle.tar.gz
			;;
			7)
				download http://mirrors.tdsast.cn/frp/frp_0.9.3_linux_mips64le.tar.gz
			;;
			8)
				echo "OK"
			;;
			*)
				exit
			;;
			esac
			install
			config
			frp_keepalived
			result=$?
			echo -n "FRP客户端安装结果  .."
			if [ $result == 0 ] ; then
				echo -e "[${green}成功${nc}]"
				echo "Enjoy~"
				sleep 1
				echo "你可以通过: \"service frp start\" 命令去启动FRP"
				echo "通过\"chkconfig frp on\" 设置FRP开机启动,  SSH远程端口默认为$rand2 "
				echo "HTTP隧道默认为$rand2 ,FRP 配置文件路径 /etc/frp/frp-config/frpc.ini"
				echo "有任何问题,通过 \"service frp status\"查看frp工作状态,解决"
				read -p "按ENTER键退出安装"
				exit
			else
				echo -e "[${red}失败${nc}]"
				exit 1
			fi
	;;
	*)
	exit
	;;
esac
	
	
