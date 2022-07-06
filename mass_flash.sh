#!/bin/bash

# ***Note*** The mass flash tool needs include checkPN.sh and setting.conf

#2021029 Initial

tool_version=1.0.0

BASEDIR=$(pwd)

checkStatus(){

	if [ $? -eq 0 ]; then
		echo -e "$(date +"Finish time : %Y-%m-%d %H:%M.%S")\n" | tee -a $log $addLog
		upload_log  ${log} ${addLog} ${uploadLog} ${FTPLog} ${fileSize}
		sudo gedit $log
		echo
		echo -e "\n\033[0;31m請確認所有Jetson都進入recovery mode.\033[0m\n"
		read -s -n1 -p "請按任一鍵繼續燒錄..."
		echo
		cd $BASEDIR
	else
		echo -e "\n燒錄失敗\n" | tee -a $log $addLog
		echo -e "\n\033[0;31m燒錄失敗\033[0m\n"
		unmount
		exit 1
	fi
}

checkUpload(){

	cat $addLog >> $uploadLog
	cp -f $uploadLog $FTPLog
	if [ $? -eq 0 ]; then
		echo "" > $addLog
	fi
}

upload_log(){

	if [ ! -d /media/upload/ ];then
		sudo mkdir /media/upload/ > /dev/null 2>&1
		sudo chmod -R 777 /media/upload/ > /dev/null 2>&1
	fi

	if ping -c 3 $ip > /dev/null 2>&1; then
	
		timeout 3 sudo curlftpfs ${ip} /media/upload/ -o user=${user}:${pwd},allow_other > /dev/null 2>&1
		
		if [ $? == 124 ]; then
			echo -e "\n\033[0;031mLog上傳失敗\033[0m\n"
			unmount
			exit 1
		fi
		if [ $? -eq 0 ]; then
			if [ ! -d /media/upload/$orderid ];then
				mkdir /media/upload/$orderid > /dev/null 2>&1
			fi
			sudo chmod -R 777 /media/upload/$orderid > /dev/null 2>&1
			FTPLog=/media/upload/$orderid/Log_${orderid}.txt
			if [ -f ${FTPLog} ]; then
				fileSize=$(stat -c%s ${FTPLog})
				if [ "$(stat -c%s ${FTPLog})" != 0 ]; then
					cp $FTPLog $uploadLog
					checkUpload
					unmount
				else
					echo -e "\n\033[0;031mFTP的log檔案毀損\033[0m\n"
					echo -e "若要上傳目前log檔案，請按y\n"
					read cpLog
					if [ $cpLog == "y" ] || [ $cpLog == "Y" ]; then
						checkUpload
						unmount
					fi
				fi
			else
				checkUpload
				unmount
			fi
		else
			echo -e "\n\033[0;031m上傳log檔案失敗\033[0m\n"
			unmount
		fi
	else
		echo -e "\n\033[0;031mFTP連線失敗\033[0m\n"
		exit 1
	fi

}

unmount(){

	sudo umount -fl  /media/upload/ > /dev/null 2>&1
	sudo rm -r /media/upload/ > /dev/null 2>&1
}

massFlash(){

	BSPName=${BSP%%.tar.gz*} 
	PatchName=${dtsName}

	echo "工單號碼	:" $orderid | tee -a $log $addLog
	echo "品號		:" $PN | tee -a $log $addLog
	echo "BSP         : ${BSPName}" | tee -a $log $addLog
	echo "Patch       : ${PatchName}" | tee -a $log $addLog

	cd $BASEDIR
	if [ -f $BASEDIR/mfi_${dtsName}.tbz2 ]; then
		if [ ! -d $BASEDIR/mfi_${dtsName} ]; then
			echo  ${pc_pwd} | sudo -S tar xvjf mfi_${dtsName}.tbz2
		fi
		cd mfi_${dtsName}
		echo -e "\n\033[0;31m請確認所有Jetson都進入recovery mode.\033[0m\n"
		echo -e "\n請輸入燒錄數量: \c"
		read ct
		usbDevCt=$(lsusb |grep -i "NVIDIA Corp." | wc -l)
		while [ "$(lsusb |grep -i "NVIDIA Corp." | wc -l)" -lt "$ct" ]
		do
			echo -e "\n\033[0;31m其他Jetson尚未進入recovery mode.\033[0m\n"
			sleep 5
			usbDevCt=$(lsusb |grep -i "NVIDIA Corp." | wc -l)		
		done	
		echo  ${pc_pwd} | sudo -S ./nvmflash.sh [--showlogs]
		cd -
	else
		echo -e "\n\033[0;031mmfi_${dtsName}.tbz2 不存在\033[0m\n"
		exit 1		
	fi
}

# Main function

echo
echo Mass flash tool version $tool_version
echo

if [ ! /usr/bin/curlftpfs ]; then
	echo -e "\n\033[0;031m請將curlftpfs複製到/usr/bin/\033[0m\n"
	exit 1
fi

# Check checkPN.sh file and $setting.conf file.
if [ ! -f $BASEDIR/checkPN.sh ]; then
	echo -e "\n\033[1;31m找不到checkPN.sh\033[0m\n"
	exit 1
fi
if [ ! -f $BASEDIR/setting.conf ]; then
	echo -e "\n\033[1;31m找不到setting.conf\033[0m\n"
	exit 1
fi

while :
do
	source ./setting.conf ${pc_pwd} ${userName} ${password} ${ip}
	if lsusb | egrep -i -w -q "NVidia Corp"
	then
		until [[ "${scan_ct}" == "29" || "${scan_ct}" == "33" ]]
		do
			echo -e "\n請掃描工單及品號 QR code: \c"
			read scan
			scan_ct=${#scan}
			PN=${scan#* }
			if [ "${PN}" == "test" ]; then
				break
			fi
		done

		id=$(lsusb |grep -i "NVidia Corp.")
		id=${id% NVidia Corp.*}
		id=${id:28:4}
		orderid=${scan%%" "*}
		log=$BASEDIR/Log_${orderid}.txt
		addLog=$BASEDIR/.addLog_${orderid}.txt
		uploadLog=$BASEDIR/.Log_${orderid}.txt

		if [ "${PN}" == "test" ]; then
			echo -e "請輸入Patch名稱: \c"
			read dtsName
			dtsName=${dtsName} | sed 's/ //g'
		else
			source ./checkPN.sh ${id}
			massFlash
			checkStatus
		fi
	else
		echo -e "\n\033[1;31m尚未進入recovery模式\033[0m\n"
		unmount
		exit 1
	fi

done
