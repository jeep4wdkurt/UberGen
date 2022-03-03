#
# core-configuration.sh
#
#	UberGen Configuration Routines
#
#	Description:
#
#       Routines to parse configuration
#
#	Copyright:
#		Copyright (c) 2021, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.02.23  01.04    KurtSchulte    Updated logging, bugfixes, migrate folders and other
#                                             non-user controller constants from BuildVariables
#                                             to here.
#       2021.04.29  01.03    KurtSchulte    Original Version
#
####################################################################################################

[ "${scriptFolder}" == "" ] && { echo "ERROR! Configuration variable [scriptFolder] is not set." ; exit 1; }

#
# Constants
#
UBERGEN_VERSION=01.04

k_section_certs="Cert Servers"
k_section_ssl="SSL Servers"
k_section_web="Web Servers"
k_section_wordpress="WordPress Hosts"
k_section_localhost="Local Host"

#
# Filesystem Permissions
#
PERM_FILE_WORLD_READONLY=744                            # File world read only access
PERM_FILE_WORLD_READ_EXECUTE=755                        # File world read and execute access
PERM_FOLDER_WORLD_READONLY=755                          # Folder world read and traverse access

#
# Folders		(spec,prot,desc,init,owner,group)
#
ug_shared_files_root=/usr/share/cognogistics            # Cognogistics shared user files					TODO: NOT USED ANYWHERE?
ug_skeleton_folder=/etc/skel                            # System folder for new user template files
ug_kits_root="/var/kits,${PERM_FOLDER_WORLD_READONLY},Install Kits,,root,root"                      # Software kits
ug_web_root=/var/www                                    # Web Data root folder
ug_ssl_root=/etc/ssl                                    # SSL Configuration root folder
ug_certs_root=/opt/ca                                   # Certificates Data Root Folder
ug_temp_folder="${HOME}/temp,  ${PERM_FOLDER_WORLD_READONLY},  User temporary data,"				# Scratch files folder
ug_user_local_folder="${HOME}/ubergen,  ${PERM_FOLDER_WORLD_READONLY},  UberGen local user data,"	# UberGen local user data folder
ug_status_folder="${HOME}/temp,  ${PERM_FOLDER_WORLD_READONLY},  UberGen status tracking data,"		# Status tracking folder
ug_log_folder="${HOME}/temp,  ${PERM_FOLDER_WORLD_READONLY},  UberGen logs,"						# Logs folder
ug_mysqlwb_apt_kit_folder="${ug_kits_root%%,*}/mysql-workbench-apt,${PERM_FOLDER_WORLD_READONLY},Mysql Workbench APT Configuration Kit,,root,root"	# MYSQL Workbench APT Configuration package

#
# Files			(spec,prot,desc,init,owner,group)
#
ug_status_file="${ug_status_folder%%,*}/ubergen.install.status.txt"	# UberGen installation status tracking file
ug_ubergen_script="${scriptFolder}/ubergen.sh"
ug_mariadb_install_script="${scriptFolder}/mariadb-install.sh"
ug_mysqlwb_apt_kit_file="${ug_mysqlwb_apt_kit_folder%%,*}/mysql-apt-config_0.8.22-1_all.deb"
ug_mysqlwb_apt_kit_uri="https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb"

#echo "DEBUG: ug_mariadb_install_script='${ug_mariadb_install_script}'"


#
# SELinux Security Context
#
ug_rhel_context_web="httpd_sys_content_t"               # Security context for web content

#
# Password Criteria
#
ug_generated_password_length=20                         # Size of generated passwords

#
# OS Flavor Constants
#
OS_DEBIAN="Debian"
OS_UBUNTU="Ubuntu"
OS_CENTOS="CentOS"
OS_REDHAT="RedHat"
OS_SLES="SLES"

#
# OS Base Distro Constants
#
OS_BASE_DEBIAN="Debian"
OS_BASE_REDHAT="RedHat"

#
# Fetch Build Variables
#
BuildVariablesFetch() {
	progLabel="BuildVariablesFetch" ; barfdt "${progLabel}.Entry()"

	source ${scriptFolder}/build-variables.sh

	# Define where to put scratch files
	tempFolder=~/temp
	if [ ! -d "${tempFolder}" ] ; then
		mkdir $verboseFlag "${tempFolder}"
		[ $? -ne 0 ] && barfee "Problem making scratch folder (tempFolder=${tempFolder})"
	fi
	
	tempStatus="${tempFolder}/ubergen.status.tmp"

	# Add sbin to path if it's not there
	if [[ "${PATH}" != */sbin/* ]] ; then PATH=${PATH}:/sbin/ ; fi

	# Get OS Information
	GetOsInfo

	# Validate OS Compatibility
	CheckOsCompatibility
	
	barfdt "BuildVariablesFetch.Exit()"
}

#
# Get Operating System Information
#
GetOsInfo() {
	progLabel="GetOsInfo" ; barfdt "${progLabel}.Entry()"
	
	OS_DISTROBASE=$("${scriptFolder}/osinfo.sh" -s OS_DISTROBASE)				; traceVariable OS_DISTROBASE
	OS_FLAVOR=$("${scriptFolder}/osinfo.sh" -s OS_FLAVOR)						; traceVariable OS_FLAVOR
	OS_VERSION=$("${scriptFolder}/osinfo.sh" -s OS_VERSION)						; traceVariable OS_VERSION
	OS_FLAVVERFLAV=$("${scriptFolder}/osinfo.sh" -s OS_FLAVVERFLAV)				; traceVariable OS_FLAVVERFLAV
	OS_CODENAME=$("${scriptFolder}/osinfo.sh" -s OS_CODENAME)					; traceVariable OS_CODENAME

	barfdt "GetOsInfo.Exit"
}

#
# Check OS Compatibility
#
CheckOsCompatibility() {
	progLabel="CheckOsCompatibility" ; barfdt "${progLabel}.Entry()"

	local osVersionMinimum=0
	case $OS_FLAVOR in
		$OS_CENTOS)			barfe "Unsupported OS Flavor '$OS_FLAVOR'" ;;
		$OS_DEBIAN)			osVersionMinimum=10 ;;
		$OS_UBUNTU)			osVersionMinimum=20 ;;
		*)					barfe "${prognm}.Error: Unsupported OS Flavor '$OS_FLAVOR'" ;;
	esac
	
	[ "${OS_DISTROBASE}" != $OS_BASE_DEBIAN ] && [ "${OS_DISTROBASE}" != $OS_BASE_REDHAT ] && \
		barfe "${progLabel}.Error: Unsupported OS_DISTROBASE (${OS_DISTROBASE})"

	[ $OS_VERSION -lt $osVersionMinimum ] && barfe "${prognm}.Error: Unsupported ${OS_FLAVOR} version (required=${osVersionMinimum},current=${OS_VERSION})"

	barfdt "CheckOsCompatibility.Exit"
}

#
# Get Variables for a Server or Client (ug_[server|client]_<env>_data variables)
#	Server data format:
#		ug_[server|client]_<env>_data = <hostname>;<type>;<short_desc>;<desc>;<owner_user>;<owner_group>;<prot_mask>;<ip_addr>;<email>
#		parsed to ug_env_xxx variables
#
ServerVarsSet() {
	local envId=$1
	local sectionId="$2"
	local progLabel="ServerVarsSet" ; barfdt "${progLabel}.Entry(envId=$envId,section=$sectionId)"

	local sysType="server"
	[ $( echo "${ug_client_list}," | grep -c "${envId}," ) -gt 0 ] && sysType="client"

	envDataRef="ug_${sysType}_${envId}_data"
	envData="${!envDataRef}"

	[ "${envData}" == "" ] && barfee "Your configuration sucks. No ug_<sysType>_<envId>_data variable declared in BuildVariables for sysType='${sysType}',envId='${envId}'" 

	envServerName=$(Trim $(echo "${envData}" | cut -d ';' -f 1))
	envServerType=$(Trim $(echo "${envData}" | cut -d ';' -f 2))					; traceVariable envServerType
	envServerShortDesc=$(Trim $(echo "${envData}" | cut -d ';' -f 3))				; traceVariable envServerShortDesc
	envServerDesc=$(Trim $(echo "${envData}" | cut -d ';' -f 4))					; traceVariable envServerDesc
	envFileOwner=$(Trim $(echo "${envData}" | cut -d ';' -f 5))						; traceVariable envFileOwner
	envFileGroup=$(Trim $(echo "${envData}" | cut -d ';' -f 6))						; traceVariable envFileGroup
	envFileMask=$(Trim $(echo "${envData}" | cut -d ';' -f 7))						; traceVariable envFileMask
	envServerIpAddr=$(Trim $(echo "${envData}" | cut -d ';' -f 8))
	[ "${envServerIpAddr}" == "" ] && envServerIpAddr=127.0.0.1						; traceVariable envServerIpAddr
	envServerDatabase=$(Trim $(echo "${envData}" | cut -d ';' -f 9))				; traceVariable envServerDatabase
	envServerWebRoot=$(Trim $(echo "${envData}" | cut -d ';' -f 10))				; traceVariable envServerWebRoot
	envServerEmail=$(Trim $(echo "${envData}" | cut -d ';' -f 11) | sed -e "s~^\$~${ug_org_email}~")	; traceVariable envServerEmail

	case sectionId in
		"${k_section_localhost}")	envServerExtDesc="${envServerDesc}" ;;
		"${k_section_certs}")		envServerExtDesc="${envServerDesc}" ;;
		"${k_section_ssl}")			envServerExtDesc="${envServerDesc}" ;;
		"${k_section_wordpress}")	envServerExtDesc="${envServerDesc} region database (${envServerName})" ;;
		*)							envServerExtDesc= ;;
	esac
	envServerCommonName="${envServerName}.${ug_server_domain}"
	envWebFolder="${ug_web_root}/${envServerWebRoot}"

	barfdt "ServerVarsSet.Exit()"
}

# 
# Get variables for a System User
#	System User Data Format:
#		ug_sysuser_<userid>_data = "<username>:<userdesc>:<usergroups>:<userpass>"
#
SystemUserVarsSet() {
	sysUserId=$1
	local progLabel="SystemUserVarsSet" ; barfdt "${progLabel}.Entry(sysUserId=${sysUserId})"
	
	local sysUserDataRef=ug_sysuser_${sysUserId}_data
	local sysUserData=${!sysUserDataRef}

	[ "${sysUserData}" == "" ] && barfee "Your configuration sucks. No ug_sysuser_<userid>_data variable declared in BuildVariables for sysUserId='${sysUserId}'" 

	sysUserName=$(Trim $(echo "${sysUserData}" | cut -d ';' -f 1))
	sysUserDesc=$(Trim $(echo "${sysUserData}" | cut -d ';' -f 2))
	sysUserGroups=$(Trim $(echo "${sysUserData}" | cut -d ';' -f 3))
	sysUserPass=$(Trim $(echo "${sysUserData}" | cut -d ';' -f 4))

	sysUserPrimaryGroup=$(Trim $(echo "${sysUserGroups}" | cut -d ':' -f 1))
	sysUserIsSystem= ; [ "${sysUserGroups}" != "${sysUserGroups//:SYSTEM/}" ] && sysUserIsSystem=1

	barfdt "SystemUserVarsSet.Parsed(sysUserName='${sysUserName}')"
	barfdt "SystemUserVarsSet.Parsed(sysUserDesc='${sysUserDesc}')"
	barfdt "SystemUserVarsSet.Parsed(sysUserGroups='${sysUserGroups}')"
	barfdt "SystemUserVarsSet.Parsed(sysUserPass='${sysUserPass}')"
	barfdt "SystemUserVarsSet.Parsed(sysUserPrimaryGroup='${sysUserPrimaryGroup}')"
	barfdt "SystemUserVarsSet.Parsed(sysUserIsSystem='${sysUserIsSystem}')"
	
	barfdt "SystemUserVarsSet.Exit()"
}