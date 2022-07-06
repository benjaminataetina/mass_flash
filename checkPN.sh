#!/bin/bash
# 20210917 92-6AN110-2009)

unmount(){

	echo  ${pc_pwd} | sudo -S umount -fl  /media/upload/ > /dev/null 2>&1
	sudo rm -r /media/upload/ > /dev/null 2>&1
}


setup=""
case ${id} in
	7c18)
		devName=jetson-tx2
		mfiName=mfi_jetson-tx2
		boardName=t186ref
		nvDtb=tegra186-quill-p3310-1000-c03-00-base
		patchDfDTB=R32_3_1_TX2_N310_Camera_IMX334_1
		case ${PN} in
			AJSC-00000000CA200 | AJSC-00000000EA200 | AJSC-00000000CA2F0 | AJSC-00000000EA2F0 | AJSC-00000000CA2F1 | AJSC-00000000EA2F2 | AJSC-00000000EA2F1 | 92-6AN510-1001 | 92-6AN510-3001 | 92-6AN510-1002 | 92-6AN510-3003 | 92-6AN510-1003 | 92-6AN510-3004 | 92-CAN510-3000)
				dtsName="R32_4_2_TX2_N510_1"
				;;
			AJSC-00000000CA300 | AJSC-00000000EA300 | AJSC-00000000CA3F0 | AJSC-00000000EA3F0 | 92-6AN622-1001 | 92-6AN622-3001 | 92-6AN622-1004 | 92-6AN622-3002)
				dtsName="R32_4_2_TX2_N622_1"
				;;
			AJSC-00000000RB200 | AJSC-00000000RB201 | AJSC-00000000RB202 | AJSC-00000000RB203 | AJSC-00000000RB204 | AJSC-00000000RB205 | AJSC-00000000MB200 | 92-6AN310-4001 | 92-6AN310-4002 | 92-CAN310-4000 | 92-6AN310-4003 | 92-6AN310-4004 | 92-6AN310-4005 | 92-6AN310-4000)
				dtsName="R32_4_3_TX2_N310_Camera_IMX290_six_1"
				;;
			AJSC-00000000RB206 | 92-6AN310-4006)
				dtsName="R32_4_3_TX2_N310_Camera_IMX334ISP_1"
				;;
			# For test
			92-6AN510-0510)
				dtsName="R32_5_1_TX2_N510_1"
				;;
			41-780000-CBD1 | 41-880801-CBD1)
				dtsName="R32_6_1_TX2-NX_AT017_1"
				devName=jetson-xavier-nx-devkit-tx2-nx
				mfiName=mfi_jetson-xavier-nx-devkit-tx2-nx
				nvDtb=tegra186-p3636-0001-p3509-0000-a01
				;;
			*)
				echo -e "\n\033[0;31m不支援品號 ${PN}\033[0m\n"
				unmount
				exit 1
				;;
		esac
		BSPName="$(echo ${dtsName} |cut -d "_" -f 1-4)"
		case $BSPName in
			R32_4_2_TX2)
				sdkFolder=JetPack_4.4_DP_Linux_DP_JETSON_TX2
				;;
			R32_4_3_TX2)
				sdkFolder=JetPack_4.4_Linux_JETSON_TX2
				;;
			R32_5_1_TX2)
				sdkFolder=JetPack_4.5.1_Linux_JETSON_TX2
				;;
			R32_6_1_TX2-NX)
				sdkFolder=JetPack_4.6_Linux_JETSON_TX2_TARGETS
				;;
		esac
		;;
	7019)
		devName=jetson-xavier
		mfiName=mfi_jetson-xavier
		boardName=t186ref
		nvDtb=tegra194-p2888-0001-p2822-0000
		patchDfDTB=R32_3_1_Xavier_AX710_Camera_IMX334_1
		case ${PN} in
			AJSC-00000000RE2F2 | AJSC-00000000RE2F3 |92-6AX720-4002 | 92-CAX720-2004)
				dtsName="R32_3_1_Xavier_AX720_Camera_IMX290THCV_six_1"
				;;
			AJSC-00000000RC3F5 | 92-6AX710-4005)
				dtsName="R32_4_3_Xavier_AX710_No_Camera_function_1"
				;;
			AJSC-00000000RTCF0 | 92-6AT122-4001)
				dtsName="R32_4_3_Xavier_ACE-T012_V2_1"
				;;
			AJSC-00000000RE2F0 | AJSC-00000000RE2F1 | AJSC-00000000EE2F0 | 92-6AX720-4000 | 92-6AX720-4001 | 92-CAX720-3000)
			 	dtsName="R32_4_4_Xavier_AX720_1"
				;;					
			*)
				echo -e "\n\033[0;31m不支援品號 ${PN}\033[0m\n"
				unmount
				exit 1
				;;
		esac
		BSPName="$(echo ${dtsName} |cut -d "_" -f 1-4)"		
		case $BSPName in
			R32_3_1_Xavier)
				sdkFolder=JetPack_4.3_Linux_JETSON_AGX_XAVIER
				;;
			R32_4_3_Xavier)
				sdkFolder=JetPack_4.4_Linux_JETSON_AGX_XAVIER
				;;
			R32_4_4_Xavier)				
				sdkFolder=JetPack_4.4.1_Linux_JETSON_AGX_XAVIER
				;;		
			R32_5_1_Xavier)
				sdkFolder=JetPack_4.5.1_Linux_JETSON_AGX_XAVIER
				;;
		esac
		;;
	7e19)
		devName=jetson-xavier-nx-devkit-emmc
		mfiName=mfi_jetson-xavier-nx-devkit-emmc
		boardName=t186ref
		nvDtb=tegra194-p3668-all-p3509-0000
		case ${PN} in
			MJSC-00000000WD300 | 92-6AN110-5000)
				dtsName="R32_4_3_Xavier-NX_AN110_Camera_IMX290_Dual_1"
				;;		
			MJSC-00000000WF100 | AJSC-00000000RF1F0 | 92-6AN810-5000 | 92-CAN810-2000)
				dtsName="R32_4_3_Xavier-NX_AN810_1"
				;;
			AJSC-00000000AT017 | AJSC-00000000RA201 | 92-CAT017-2001)
				dtsName="R32_4_3_Xavier-NX_AT017_AUO_1"
				;;
			92-6AN810-3003)
				dtsName="R32_5_1_Xavier-NX_AN810_Camera_IMX290_six_1"
				;;				
			AJSC-00000000EF100 | AJSC-00000000EF1F0 | AJSC-00000000EF1F1 | AJSC-00000000EF1F2 | 92-6AN810-3000 | 92-6AN810-3001 | 92-6AN810-3002 | 92-CAN810-3000)
				dtsName="R32_4_4_Xavier-NX_AN810_1"
				;;
			AJSC-00000000RD301 | AJSC-00000000RD3F0 | AJSC-00000000RD3F1 | AJSC-00000000RD3F3 | AJSC-00000000RD305 | 92-6AN110-4001 | 92-6AN110-2000 | 92-6AN110-2001 | 92-6AN110-2003 | 92-CAN110-2002)
				dtsName="R32_4_4_Xavier-NX_AN110_Camera_IMX290_Dual_1"
				;;
			AJSC-00000000RD3F2 | 92-6AN110-2002)
				dtsName="R32_4_4_Xavier-NX_AN110_Camera_IMX179_J13_1"
				;;
			AJSC-00000000RA2H1 | 92-CAT017-2003)
				dtsName="R32_4_4_Xavier-NX_AT017_1"
				;;
			92-6AN110-2009)
				dtsName="R32_5_1_Xavier-NX_AN110_1"
				;;
			41-770901-CB33)
				dtsName="BSP_R32_5_1_Xavier_NX_AIE-CN11_3"
				;;
			*)
				echo -e "\n\033[0;31m不支援品號 ${PN}\033[0m\n"
				unmount
				exit 1
				;;
		esac
		BSPName="$(echo ${dtsName} |cut -d "_" -f 1-4)"
		case $BSPName in
			R32_4_3_Xavier-NX)
				sdkFolder=JetPack_4.4_Linux_JETSON_XAVIER_NX
				;;
			R32_4_4_Xavier-NX)
				sdkFolder=JetPack_4.4.1_Linux_JETSON_XAVIER_NX
				;;						
			R32_5_1_Xavier-NX)
				sdkFolder=JetPack_4.5.1_Linux_JETSON_XAVIER_NX
				;;
			BSP_R32_5_1)
				sdkFolder=JetPack_4.5.1_Linux_JETSON_XAVIER_NX
				;;
		esac			
		;;
	7f21)
		devName=jetson-nano-emmc
		mfiName=mfi_jetson-nano-emmc
		boardName=t210ref
		nvDtb=tegra210-p3448-0002-p3449-0000-b00
		patchDfDTB=R32_3_1_Nano_AN110_Camera_IMX334_J8_1
		case ${PN} in
			AJSC-00000000RD303 | AJSC-00000000RA200 | 92-CAN110-2000 | 92-CAT017-2000)
				dtsName="R32_3_1_Nano_AT017_AUO_1"
				;;
			AJSC-00000000RD3H2 | 92-6AN110-2007)
				dtsName="R32_4_4_Nano_AN110_Camera_IMX179_J13_1"
				;;			
			AJSC-00000000RD300 | AJSC-00000000RD3H0 | AJSC-00000000RD3H1 | AJSC-00000000RD3H3 | AJSC-00000000RD304 | 92-6AN110-4000 | 92-6AN110-2005 | 92-6AN110-2006 | 92-6AN110-2008 | 92-CAN110-2001)
				dtsName="R32_4_4_Nano_AN110_Camera_IMX290_Dual_1"
				;;
			AJSC-00000000RA2H0 | 92-CAT017-2002)
				dtsName="R32_4_4_Nano_AT017_1"
				;;
			*)
				echo -e "\n\033[0;31m不支援品號 ${PN}\033[0m\n"
				unmount
				exit 1
				;;
		esac
		BSPName="$(echo ${dtsName} |cut -d "_" -f 1-4)"
		case $BSPName in
			R32_3_1_Nano)
				sdkFolder=JetPack_4.3_Linux_P3448-0020
				;;
			R32_4_4_Nano)
				sdkFolder=JetPack_4.4.1_Linux_JETSON_NANO
				;;
			R32_5_1_Nano)
				sdkFolder=JetPack_4.5.1_Linux_JETSON_NANO
				;;
		esac			
		;;
	*)
		echo -e "\n\033[1;31m不支援此module\033[0m\n"
		unmount
		exit 1
		;;
esac
echo $dtsName
BSP="$(echo ${dtsName} |cut -d "_" -f 1-4).tar.gz"
Patch="${dtsName}.tar.gz"
Module=$(echo ${dtsName} |cut -d "_" -f4)
Module="${Module,,}"
Version=$(echo ${dtsName} |cut -d "_" -f 1-3)
BSPName=${BSPName}
PatchName=${dtsName}
if [ $dtsName == "R32_3_1_Nano_AT017_AUO_1" ]; then
	mv JetPack_4.3_Linux_P3448-0020 JetPack_4.3_Linux_JETSON_NANO
fi
if [ $dtsName == "R32_6_1_TX2-NX_AT017_1" ]; then
	BSP="BSP_${BSPName}_1.tar.gz"
fi
if [ $dtsName == "BSP_R32_5_1_Xavier_NX_AIE-CN11_3" ]; then
	BSP="${dtsName}.tar.gz"
	Module=$(echo ${dtsName} |cut -d "_" -f 4-5)
	Module=${Module/"_"/"-"}
	Module="${Module,,}"
	Version=$(echo ${dtsName} |cut -d "_" -f 2-4)
	BSPName="$(echo ${dtsName} |cut -d "_" -f 1-6)"
	flash_BSP=y
fi