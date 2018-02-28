#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS/Debian/Ubuntu
#	Description: Cloud Torrent
#	Version: 1.1.3
#	Author: Toyo
#	Blog: https://doub.io/wlzy-12/
#=================================================

file="/etc/cloudtorrent"
ct_file="/etc/cloudtorrent/cloud-torrent"
dl_file="/etc/cloudtorrent/downloads"
ct_config="/etc/cloudtorrent/cloud-torrent.json"
ct_conf="/etc/cloudtorrent/cloud-torrent.conf"
IncomingPort="50007"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}
check_installed_status(){
	[[ ! -e ${ct_file} ]] && echo -e "${Error} Cloud Torrent 没有安装，请检查 !" && exit 1
}
check_pid(){
	PID=`ps -ef | grep cloud-torrent | grep -v grep | awk '{print $2}'`
}
check_new_ver(){
	ct_new_ver=`wget --no-check-certificate -qO- https://github.com/jpillora/cloud-torrent/releases/latest | grep "<title>" | sed -r 's/.*Release (.+) · jpillora.*/\1/'`
	if [[ -z ${ct_new_ver} ]]; then
		echo -e "${Error} Cloud Torrent 最新版本获取失败，请手动获取最新版本号[ https://github.com/jpillora/cloud-torrent/releases ]"
		stty erase '^H' && read -p "请输入版本号 [ 格式 x.x.xx , 如 0.8.16 ] :" ct_new_ver
		[[ -z "${ct_new_ver}" ]] && echo "取消..." && exit 1
	else
		echo -e "${Info} 检测到 Cloud Torrent 最新版本为 ${ct_new_ver}"
	fi
}
check_ver_comparison(){
	ct_now_ver=`cat /etc/cloudtorrent/ct_ver.txt`
	[[ -z ${ct_now_ver} ]] && echo "${ct_new_ver}" > /etc/cloudtorrent/ct_ver.txt
	if [[ ${ct_now_ver} != ${ct_new_ver} ]]; then
		echo -e "${Info} 发现 Cloud Torrent 已有新版本 [ ${ct_new_ver} ]"
		stty erase '^H' && read -p "是否更新 ? [Y/n] :" yn
		[ -z "${yn}" ] && yn="y"
		if [[ $yn == [Yy] ]]; then
			check_pid
			[[ ! -z $PID ]] && kill -9 ${PID}
			rm -rf ${ct_file}
			Download_ct
			Start_ct
		fi
	else
		echo -e "${Info} 当前 Cloud Torrent 已是最新版本 [ ${ct_new_ver} ]" && exit 1
	fi
}
Download_ct(){
	cd ${file}
	if [ ${bit} == "x86_64" ]; then
		wget --no-check-certificate -O cloud-torrent.gz "https://github.com/jpillora/cloud-torrent/releases/download/${ct_new_ver}/cloud-torrent_linux_amd64.gz"
	elif [ ${bit} == "i386" ]; then
		wget --no-check-certificate -O cloud-torrent.gz "https://github.com/jpillora/cloud-torrent/releases/download/${ct_new_ver}/cloud-torrent_linux_386.gz"
	elif [ ${bit} == "i686" ]; then
		wget --no-check-certificate -O cloud-torrent.gz "https://github.com/jpillora/cloud-torrent/releases/download/${ct_new_ver}/cloud-torrent_linux_386.gz"
	else
		echo -e "${Error} 不支持 ${bit} !" && exit 1
	fi
	[[ ! -e "cloud-torrent.gz" ]] && echo -e "${Error} Cloud Torrent 下载失败 !" && exit 1
	gzip -d cloud-torrent.gz
	[[ ! -e ${ct_file} ]] && echo -e "${Error} Cloud Torrent 解压失败(可能是 压缩包损坏 或者 没有安装 Gzip) !" && exit 1
	rm -rf cloud-torrent.gz
	chmod +x cloud-torrent
	echo "${ct_new_ver}" > ct_ver.txt
}
Service_ct(){
	if [[ ${release} = "centos" ]]; then
		if ! wget --no-check-certificate https://www.moerats.com/usr/down/cloudt/cloudt_centos -O /etc/init.d/cloudt; then
			echo -e "${Error} Cloud Torrent服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/cloudt
		chkconfig --add cloudt
		chkconfig cloudt on
	else
		if ! wget --no-check-certificate https://www.moerats.com/usr/down/cloudt/cloudt_debian -O /etc/init.d/cloudt; then
			echo -e "${Error} Cloud Torrent服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/cloudt
		update-rc.d -f cloudt defaults
	fi
	echo -e "${Info} Cloud Torrent服务 管理脚本下载完成 !"
}
Installation_dependency(){
	gzip_ver=`gzip -V`
	if [[ -z ${gzip_ver} ]]; then
		if [[ ${release} == "centos" ]]; then
			yum update
			yum install -y gzip
		else
			apt-get update
			apt-get install -y gzip
		fi
	fi
	echo "nameserver 8.8.8.8" > /etc/resolv.conf
	echo "nameserver 8.8.4.4" >> /etc/resolv.conf
	mkdir ${file}
	mkdir ${dl_file}
}
Write_config(){
	cat > ${ct_conf}<<-EOF
port=${ct_port}
user=${ct_user}
passwd=${ct_passwd}
EOF
}
Read_config(){
	[[ ! -e ${ct_conf} ]] && echo -e "${Error} Cloud Torrent 配置文件不存在 !" && exit 1
	port=`cat ${ct_conf}|grep "port"|awk -F "=" '{print $NF}'`
	user=`cat ${ct_conf}|grep "user"|awk -F "=" '{print $NF}'`
	passwd=`cat ${ct_conf}|grep "passwd"|awk -F "=" '{print $NF}'`
}
Set_port(){
	while true
		do
		echo -e "请输入 Cloud Torrent 监听端口 [1-65535]"
		stty erase '^H' && read -p "(默认端口: 8000):" ct_port
		[[ -z "$ct_port" ]] && ct_port="8000"
		expr ${ct_port} + 0 &>/dev/null
		if [[ $? -eq 0 ]]; then
			if [[ ${ct_port} -ge 1 ]] && [[ ${ct_port} -le 65535 ]]; then
				echo && echo "========================"
				echo -e "	端口 : ${Red_background_prefix} ${ct_port} ${Font_color_suffix}"
				echo "========================" && echo
				break
			else
				echo "输入错误, 请输入正确的端口。"
			fi
		else
			echo "输入错误, 请输入正确的端口。"
		fi
		done
}
Set_user(){
	echo "请输入 Cloud Torrent 用户名"
	stty erase '^H' && read -p "(默认用户名: admin):" ct_user
	[[ -z "${ct_user}" ]] && ct_user="admin"
	echo && echo "========================"
	echo -e "	用户名 : ${Red_background_prefix} ${ct_user} ${Font_color_suffix}"
	echo "========================" && echo

	echo "请输入 Cloud Torrent 用户名的密码"
	stty erase '^H' && read -p "(默认密码: admin):" ct_passwd
	[[ -z "${ct_passwd}" ]] && ct_passwd="admin"
	echo && echo "========================"
	echo -e "	密码 : ${Red_background_prefix} ${ct_passwd} ${Font_color_suffix}"
	echo "========================" && echo
}
Set_conf(){
	Set_port
	stty erase '^H' && read -p "是否设置 用户名和密码 ? [Y/n] :" yn
	[[ -z "${yn}" ]] && yn="y"
	if [[ $yn == [Yy] ]]; then
		Set_user
	else
		ct_user="" && ct_passwd=""
	fi
}
Set_ct(){
	check_installed_status
	check_sys
	check_pid
	Set_conf
	Read_config
	Del_iptables
	Write_config
	Add_iptables
	Save_iptables
	Restart_ct
}
Install_ct(){
	[[ -e ${ct_file} ]] && echo -e "${Error} 检测到 Cloud Torrent 已安装 !" && exit 1
	check_sys
	echo -e "${Info} 开始设置 用户配置..."
	Set_conf
	echo -e "${Info} 开始安装/配置 依赖..."
	Installation_dependency
	echo -e "${Info} 开始检测最新版本..."
	check_new_ver
	echo -e "${Info} 开始下载/安装..."
	Download_ct
	echo -e "${Info} 开始下载/安装 服务脚本(init)..."
	Service_ct
	echo -e "${Info} 开始写入 配置文件..."
	Write_config
	echo -e "${Info} 开始设置 iptables防火墙..."
	Set_iptables
	echo -e "${Info} 开始添加 iptables防火墙规则..."
	Add_iptables
	echo -e "${Info} 开始保存 iptables防火墙规则..."
	Save_iptables
	echo -e "${Info} 所有步骤 安装完毕，开始启动..."
	Start_ct
}
Start_ct(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} Cloud Torrent 正在运行，请检查 !" && exit 1
	service cloudt start
}
Stop_ct(){
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Cloud Torrent 没有运行，请检查 !" && exit 1
	service cloudt stop
}
Restart_ct(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && service cloudt stop
	service cloudt start
}
Log_ct(){
# 判断日志是否存在
	if [ ! -e ${file}"/ct.log" ]; then
		echo -e "${Error} Cloud Torrent 日志文件不存在 !" && exit 1
	else
		echo && echo -e "${Tip} 按 ${Red_font_prefix}Ctrl+C${Font_color_suffix} 终止查看日志" && echo
		tail -f /etc/cloudtorrent/ct.log
	fi
}
Update_ct(){
	check_installed_status
	check_sys
	check_new_ver
	check_ver_comparison
}
Uninstall_ct(){
	check_installed_status
	echo "确定要卸载 Cloud Torrent ? (y/N)"
	echo
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		check_pid
		[[ ! -z $PID ]] && kill -9 ${PID}
		Read_config
		Del_iptables
		rm -rf ${file} && rm -rf /etc/init.d/cloudt
		if [[ ${release} = "centos" ]]; then
			chkconfig --del cloudt
		else
			update-rc.d -f cloudt remove
		fi
		echo && echo "Cloud torrent 卸载完成 !" && echo
	else
		echo && echo "卸载已取消..." && echo
	fi
}
View_ct(){
	check_installed_status
	Read_config
	ip=`wget -qO- -t1 -T2 ipinfo.io/ip`
	[[ -z ${ip} ]] && ip="VPS_IP"
	if [[ -z ${user} ]]; then
		clear && echo "————————————————" && echo
		echo -e " 你的 Cloud Torrent 信息 :" && echo
		echo -e " 地址\t: ${Green_font_prefix}http://${ip}:${port}${Font_color_suffix}"
		echo && echo "————————————————"
	else
		clear && echo "————————————————" && echo
		echo -e " 你的 Cloud Torrent 信息 :" && echo
		echo -e " 地址\t: ${Green_font_prefix}http://${ip}:${port}${Font_color_suffix}"
		echo -e " 用户\t: ${Green_font_prefix}${user}${Font_color_suffix}"
		echo -e " 密码\t: ${Green_font_prefix}${passwd}${Font_color_suffix}"
		echo && echo "————————————————"
	fi
}
Add_iptables(){
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${ct_port} -j ACCEPT
	iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${ct_port} -j ACCEPT
	iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport ${IncomingPort} -j ACCEPT
	iptables -I INPUT -m state --state NEW -m udp -p udp --dport ${IncomingPort} -j ACCEPT
	iptables -I OUTPUT -m state --state NEW -m tcp -p tcp --dport ${IncomingPort} -j ACCEPT
	iptables -I OUTPUT -m state --state NEW -m udp -p udp --dport ${IncomingPort} -j ACCEPT
}
Del_iptables(){
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${port} -j ACCEPT
	iptables -D INPUT -m state --state NEW -m udp -p udp --dport ${port} -j ACCEPT
	iptables -D INPUT -m state --state NEW -m tcp -p tcp --dport ${IncomingPort} -j ACCEPT
	iptables -D INPUT -m state --state NEW -m udp -p udp --dport ${IncomingPort} -j ACCEPT
	iptables -D OUTPUT -m state --state NEW -m tcp -p tcp --dport ${IncomingPort} -j ACCEPT
	iptables -D OUTPUT -m state --state NEW -m udp -p udp --dport ${IncomingPort} -j ACCEPT
}
Save_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
	else
		iptables-save > /etc/iptables.up.rules
	fi
}
Set_iptables(){
	if [[ ${release} == "centos" ]]; then
		service iptables save
		chkconfig --level 2345 iptables on
	elif [[ ${release} == "debian" ]]; then
		iptables-save > /etc/iptables.up.rules
		cat > /etc/network/if-pre-up.d/iptables<<-EOF
#!/bin/bash
/sbin/iptables-restore < /etc/iptables.up.rules
EOF
		chmod +x /etc/network/if-pre-up.d/iptables
	elif [[ ${release} == "ubuntu" ]]; then
		iptables-save > /etc/iptables.up.rules
		echo -e "\npre-up iptables-restore < /etc/iptables.up.rules
post-down iptables-save > /etc/iptables.up.rules" >> /etc/network/interfaces
		chmod +x /etc/network/interfaces
	fi
}
echo && echo -e "请输入一个数字来选择选项

 ${Green_font_prefix}1.${Font_color_suffix} 安装 Cloud Torrent
 ${Green_font_prefix}2.${Font_color_suffix} 升级 Cloud Torrent
 ${Green_font_prefix}3.${Font_color_suffix} 卸载 Cloud Torrent
————————————
 ${Green_font_prefix}4.${Font_color_suffix} 启动 Cloud Torrent
 ${Green_font_prefix}5.${Font_color_suffix} 停止 Cloud Torrent
 ${Green_font_prefix}6.${Font_color_suffix} 重启 Cloud Torrent
————————————
 ${Green_font_prefix}7.${Font_color_suffix} 设置 Cloud Torrent 账号
 ${Green_font_prefix}8.${Font_color_suffix} 查看 Cloud Torrent 账号
 ${Green_font_prefix}9.${Font_color_suffix} 查看 Cloud Torrent 日志
————————————" && echo
if [[ -e ${ct_file} ]]; then
	check_pid
	if [[ ! -z "${PID}" ]]; then
		echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix}"
	else
		echo -e " 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未启动${Font_color_suffix}"
	fi
else
	echo -e " 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
fi
echo
stty erase '^H' && read -p " 请输入数字 [1-9]:" num
case "$num" in
	1)
	Install_ct
	;;
	2)
	Update_ct
	;;
	3)
	Uninstall_ct
	;;
	4)
	Start_ct
	;;
	5)
	Stop_ct
	;;
	6)
	Restart_ct
	;;
	7)
	Set_ct
	;;
	8)
	View_ct
	;;
	9)
	Log_ct
	;;
	*)
	echo "请输入正确数字 [1-9]"
	;;
esac