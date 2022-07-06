#!/bin/bash

# ***Note*** The build mfi tool needs include checkPN.sh

#20210329 Initial

tool_version=1.0.0

BASEDIR=$(pwd)

untar(){
	Linux_for_Tegra=${sdkFolder}/Linux_for_Tegra
    md5_BSP=${BSP%%.*} 
    md5_Patch=${Patch%%.*}
	mfiPath=$BASEDIR/${Linux_for_Tegra}/bootloader/mfi_${dtsName}
	echo $BSP
	echo $Patch

	if [ -d $mfiPath ] 
	then
		cd $Linux_for_Tegra/bootloader
		tar cvjf mfi_${dtsName}.tbz2 mfi_${dtsName}
		mv mfi_${dtsName}.tbz2 ../../../
		echo
		read -s -n1 -p "請按任一鍵繼續製作mfi..."
		echo
		cd $BASEDIR
		echo -e "\n請掃描工單及品號 QR code: \c"
		read scan
		scan_ct=${#scan}
		PN=${scan#* }
		continue
	elif [ -f $BASEDIR/$BSP ] && [ -f $BASEDIR/$Patch ]
	then
		echo -e "\n壓縮檔驗證...開始...請稍後!\n"
		if md5sum -c $md5_BSP.md5sum && md5sum -c $md5_Patch.md5sum | egrep -w -q '正確|OK'
		then
			cd $BASEDIR
			sudo chmod +x $BSP $Patch
			echo -e "\n解壓縮...開始...請稍後!\n"
			sudo tar -xvpzf $BSP -C . --numeric-owner
			changeFolder
			sudo tar -xvpzf $Patch
			echo -e "\n已解壓縮完成\n"
			Flash ${Version} ${flash_BSP} ${BSP} ${dtsName}
		else
			echo -e "\n\033[0;31m壓縮檔驗證錯誤\033[0m\n"
			exit 1
		fi
	elif [ -f $BASEDIR/$BSP ] && [ ! -f $BASEDIR/$Patch ]
	then
		if  [ "$flash_BSP" == "y" ]
		then
			if md5sum -c $md5_BSP.md5sum | egrep -w -q '正確|OK'
			then
				cd $BASEDIR
				sudo chmod +x $BSP
				echo -e "\n解壓縮...開始...請稍後!\n"
				sudo tar -xvpzf $BSP -C . --numeric-owner
				changeFolder
				echo -e "\n已解壓縮完成\n"
				Flash ${Version} ${flash_BSP} ${BSP} ${dtsName}
			fi
		else
			echo -e "\n\033[0;31m$Patch patch壓縮檔不存在\033[0m\n"
			exit 1
		fi
	elif [ ! -f $BASEDIR/$BSP ] && [ -f $BASEDIR/$Patch ]
	then
		echo -e "\n\033[0;31m$BSP BSP壓縮檔不存在\033[0m\n"
		exit 1
	else
		echo -e "\n\033[0;31mBSP & Patch壓縮檔不存在\033[0m\n"
		exit 1
	fi
}

Flash(){
	patch_file=${Patch%%.*}
	if [ $dtsName == "R32_4_3_Xavier_AX710_No_Camera_function_1" ]; then
		patch_file=R32_4_3_Xavier_AX710_1
	elif [ $dtsName == "R32_4_3_Xavier_ACE-T012_V2_1" ]; then
		patch_file=R32_4_3_Xavier_T012_V2_1
	fi
    
	if  [ "${flash_BSP}" == "y" ]
	then
		cd ${Linux_for_Tegra}
		buildMfi
	else
		cd $BASEDIR/$patch_file
		chmod +x setup.sh
		setupMsg="successfully"
		if [ "${setup}" == "old" ] ; then
			setupMsg="Done"
		fi
		if ./setup.sh | egrep -i -w -q "${setupMsg}"
		then
			echo -e "\nPatch檔案安裝完成\n"
			cd ../
			sudo rm -rf $patch_file
			cd ${Linux_for_Tegra}
			chmod +x flash.sh

			VersionSeries=${Version%%_*}

			if [ $Version == "R32_3_1" ]
			then
				if [ $dtsName != "R32_3_1_Xavier_AX720_Camera_IMX290THCV_six_1" ] || [ $dtsName != "R32_3_1_Nano_AT017_AUO_1" ]
				then
					if [ -f $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${nvDtb}.dtb ]
					then
						cp $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${nvDtb}.dtb $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${patchDfDTB}.dtb
						cp -f $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${dtsName}.dtb $BASEDIR/${Linux_for_Tegra}/kernel/dtb/${nvDtb}.dtb
					else
						echo -e "\n\033[0;31mCopy DTB fail.\033[0m\n"
						exit 1
					fi
				fi
			fi
			buildMfi
		else
			echo -e "\n\033[0;31mPatch檔案安裝失敗\033[0m\n"
			exit 1
		fi
	fi
}

buildMfi(){
	if [ ${Version} == "R32_4_3" ]; then
		cd bootloader/$boardName/cfg/
		sudo mv -f gnu_linux_tegraboot_emmc_full.xml gnu_linux_tegraboot_emmc_full.xml.sav
		cd ../../
		./mkbctpart -G new_config.xml
		mv -f new_config.xml $boardName/cfg/gnu_linux_tegraboot_emmc_full.xml
		cd ../
	fi
	if [ ! -f $BASEDIR/mfi_${dtsName}.tbz2 ]; then
		usbDevCt=$(lsusb |grep -i "NVIDIA Corp." | wc -l)
		while [ "${usbDevCt}" -ne 1 ]
		do
			echo -e "\n\033[0;31m請勿接上其他Jetson裝置\033[0m\n"
			sleep 3
			usbDevCt=$(lsusb |grep -i "NVIDIA Corp." | wc -l)
		done
		if lsusb | egrep -i -w -q "NVidia Corp"; then
			if grep -i -w "dtsName" nvmassflashgen.sh ;then
				sed -i '/dtsName=/dtsName=mfi_'${dtsName}'/' nvmassflashgen.sh
			else
				sed -i '/fill_mfidir ${tfvers} "${mfidir}";/a\dtsName='${dtsName}'\nmv ${mfidir} mfi_${dtsName}\nmfidir=mfi_${dtsName}' nvmassflashgen.sh
			fi

			sudo ./nvmassflashgen.sh ${devName} mmcblk0p1
			if [ $? == 124 ]; then
				echo -e "\n\033[0;031mmfi製作失敗\033[0m\n"
				unmount
				exit 1
			else
				mv mfi_${dtsName}.tbz2 ../../
				echo
				read -s -n1 -p "請按任一鍵繼續製作mfi..."
				echo
				cd $BASEDIR
				echo -e "\n請掃描工單及品號 QR code: \c"
				read scan
				scan_ct=${#scan}
				PN=${scan#* }
				continue
			fi
		else
			echo -e "\n\033[1;31m尚未進入recovery模式\033[0m\n"
			exit 1
		fi
	else
		echo -e "\n\033[1;31m已有mfi_${dtsName}.tbz2\033[0m\n"
		exit 0
	fi
}

# Main function

echo
echo Build mfi file tool version $tool_version
echo

# Check checkPN.sh file.
if [ ! -f $BASEDIR/checkPN.sh ]; then
	echo -e "\n\033[1;31m找不到checkPN.sh\033[0m\n"
	exit 1		
fi

while :
do
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

		if [ "${PN}" == "test" ]; then
			echo -e "請輸入Patch名稱: \c"
			read dtsName
			dtsName=${dtsName} | sed 's/ //g'
		else
			pwd
			source ./checkPN.sh ${id}
			if [ -f $BASEDIR/mfi_${dtsName}.tbz2 ]; then
				echo -e "\n\033[1;31m已有mfi_${dtsName}.tbz2\033[0m\n"
				exit 0			
			else
				untar
			fi
		fi
	else
		echo -e "\n\033[1;31m尚未進入recovery模式\033[0m\n"
		exit 1
	fi

done
