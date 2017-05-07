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
	mkdir /root/frp
	wget -O /root/frp/frp.tar.gz $1
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
	cd /root/frp/
	sleep 0.3
	echo -n "."
	tar zxf /root/frp/frp.tar.gz 
	if [ $? == 0 ] ; then
		echo -e "[${green}成功${nc}]"
	else
		echo -e "[${red}失败${nc}]"
		exit 1
	fi
	rm -f /root/frp/frp.tar.gz
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
版本更新：采用0.93版本搭建，新增开启启动功能
=========================================================================
USER: $USER   HOST: $HOSTNAME  KERNEL: `uname -r`  
DISK :`ls  /dev/sd? 2>/dev/null`
你确定要安装吗？【Y/y】
EOF
config(){
	echo -n "设置FRP Frp . . ."
	pcd=`pwd`
	cd /root/frp/frp-config
	sleep 0.3
	echo -n "."
	rm -f frpc.ini
	touch frpc.ini
	read -p  "请输入FRP服务端密码:[geekfan.top123]" password
	if [ ! $password ] ;then
		password=geekfan.top123
	fi
	read -p  "请输入FRP服务端域名:[www.funkystars.cn]" IP
	if [ ! $IP ] ;then
		IP=www.funkystars.cn
	fi
	read -p  "请输入本地IP:[127.0.0.1]" Local
	if [ ! $Local ] ;then
		Local=127.0.0.1
	fi
	read -p  "请输入FRP客户端域名:[www.youname.com]" Domain
	if [ ! $Domain ] ;then
		Domain=www.youname.com
	fi	
	read -p  "请设置HTTP端口隧道名称:[$rand1]" HTTP
	if [ ! $HTTP ] ;then
		HTTP=$rand1
	fi
	read -p  "请设置SSH端口隧道名称(默认SSH端口):[$rand2]" SSH
	if [ ! $SSH ] ;then
		SSH=$rand2
	fi
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
	if [ $? == 0 ] ; then
		echo -e "[${green}成功${nc}]"
	else
		echo -e "[${red}失败${nc}]"
		exit 1
	fi
	cd $pcd
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
	请将下载好的文件保存到/root/frp下
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
			result=$?
			echo -n "FRP客户端安装结果  .."
			if [ $result == 0 ] ; then
				echo -e "[${green}成功${nc}]"
				echo "Enjoy~"
				sleep 1
				echo "你可以在/frp/frp-config目录下通过: \"./frpc -c ./frpc.ini\" 命令去启动FRP，SSH远程端口默认为11 "
				read -p "是否设置开机启动？Y/y[y]" key
				case $key in 
				"y"|"Y"|"")
						chmod +x /etc/rc.d/rc.local
						sed -i  '$i\/root/frp/frp-config/frpc -c /root/frp/frp-config/frpc.ini'  /etc/rc.d/rc.local
						if [ $? == 0 ] ; then
								echo -e "[${green}成功${nc}]"
						else
								echo -e "[${red}失败${nc}]"
								exit 1
						fi
				;;
				*)
				;;
				esac
				sleep 1
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
	
	
