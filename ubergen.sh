#
# ubergen.sh
#
#	UberGen System Confabulation Suite
#	Godzilla Module - The Beast That Does It All
#
#	Description:
#			Sets up a LAMP3(w) Environment (Linux, Apache, MariaDB, Perl/Python/PHP, and
#			optionally, WordPress). 
#
#		Supported Linux Distros
#			Debian 10.x
#			Ubuntu Workstation 20.x
#
#		Component Scripts:
#			build-variables				Driving data
#			perl-install				Perl Language and handy libraries
#			php-install					PHP Language and handy libraries
#			python-install				Python Language and handy libraries
#			prerequisites-install		Prerequisite software
#			system-add-users			Add system users, groups, and support scripts
#			firewall-install			Firewall (UFW) installation
#			openssl-config				OpenSSL certificate generation and configuration
#			openssh-install				OpenSSH server install and configuration
#			mariadb-install				Database (MariaDB) installation and configuration
#			mariadb-add-users			Database users creation
#			brave-install				Brave privacy web browser
#			vsftp-install				Secure FTP Server (VSFTP) install and configuration
#			vnc-install					TigerVNC Remote Desktop Server install and configuration
#			wordpress-mariadb-config	WordPresss database configuration
#			wordpress-install			WordPresss installation
#
#	Usage:
#       ubergen.sh [-l] [-L <logfile>] [-v] [-d] [-t] [-u] [-p] [-W]
#
#           Options:
#               -W            Include WordPress installation
#               -u            Unpack UberGen Distribution, Only
#               -p            Prompt for approval between stages
#               -l            Log
#               -L <logfile>  Write log data to <logfile> (default=./ubergen.log)
#               -v            Verbose (displays detailed info)
#               -d            Debug (displays more detailed info)
#               -t            Trace (displays exhaustive info)
#
#	Copyright:
#		Copyright (c) 2021, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2021.04.29  01.03    KurtSchulte    Core routines
#       2021.01.28  01.00    KurtSchulte    Original Version
#
####################################################################################################
prognm=ubergen.sh
scriptFolder=$(echo "${0%/*}" | sed -e "s~^[.]~`pwd`~")

#
# Core Routines
#
source ${scriptFolder}/core-io.sh							# UberGen IO routines

#
# Unpack Distribution
# 
UnpackDistro() {
	barfdt "UnpackDistro.Entry()"

	local keyFile="${scriptFolder}/osinfo.sh"
	local tarBall="${scriptFolder}/UberGen.tar.z"
	local zipPassOption=
	[ "${optDistroPass}" != "" ] && zipPassOption="-P ${optDistroPass}"

	if [ ! -e "${keyFile}" ] ; then
		barf "Unpacking UberGen distribution tarball (${tarBall})..."
		cd "${scriptFolder}"
		unzip $zipPassOption -p "${tarBall}" | tar -x 
		errCode=$? && [ $errCode -ne 0 ] && barfee "Failed to unpack distribution.... ABORT!"

		# Permission files.  Unzip should make owner executor, but it doesn't when zip is created
		# on Cygwin and unpacked on Debian. WTF.
		chown root:root "${scriptFolder}"/*
		errCode=$? && [ $errCode -ne 0 ] && barfee "Failed to permission extracted distribution.... ABORT!"

		barf "Unpacked UberGen distribution successfully!"
		ls -l 
	else
		[ $optUnpack ] && barf "UberGen distro is already unpacked." && ls -l
	fi
	
	barfdt "UnpackDistro.Exit()"
}

#
# Command Line Options
#
getOptions() {
	progLabel="getOptions"
	
	optLog=
	optLogAppend=
	optLogFile=
	optVerbose=
	optDebug=
	optTrace=
	optUnpack=
	optDistroPass=
	optWordPress=
	optPrompt=

	while getopts "?hlL:vdtupP:W" OPTION
	do
		case $OPTION in
			h)	usage ; exit 1                                      ;;
			W)  optWordPress=1										;;
			u)  optUnpack=1											;;
			P)  optDistroPass=$OPTARG								;;
			p)	optPrompt=1                                         ;;
			l)	optLog=1                                            ;;
			L)  optLogFile=$OPTARG ; optLog=1						;;
			v)  optVerbose=1 ; optLog=1                             ;;
			d)  optDebug=1 ;   optVerbose=1 ; optLog=1              ;;
			t)  optTrace=1; optDebug=1 ;   optVerbose=1 ; optLog=1  ;;
			?)  usage ; exit                                        ;;
		 esac
	done
	shift $(($OPTIND - 1)) 

	verboseFlag=
	[ $optTrace ] && verboseFlag=-v

	LogInitialize "${optLog}" "${optLogFile}"

	# Set option switches for downstream script calls
	logSwitch=		; [ $optLog ] && 		logSwitch="-l"			;
	debugSwitch=	; [ $optDebug ] && 		debugSwitch="-d"		;
	verboseSwitch=	; [ $optVerbose ] && 	verboseSwitch="-v"		;
	traceSwitch=	; [ $optTrace ] &&		traceSwitch="-t"		;
	logFileSwitch=	; [ "${optLogFile}" != "" ] && logFileSwitch='-L "'"${optLogFile}"'"'
	optSwitches="${logSwitch} ${logFileSwitch} ${verboseSwitch} ${debugSwitch} ${traceSwitch}"
}

usage() {
    cat <<EOFUsage
${prognm} [-l] [-L <logfile>] [-vdtup]

    Options:
        -W            Include WordPress installation
        -u            Unpack UberGen Distribution, Only
        -P            Unpack UBerGen Distribution password
        -p            Prompt between major sections
        -l            Log
        -L <logfile>  Write log data to <logfile> (default=./ubergen.log)
        -v            Verbose (displays detailed info)
        -d            Debug (displays more detailed info)
        -t            Trace (displays exhaustive info)
EOFUsage
}


############################################################################################
#
# UBER GEN -- MAIN
#
############################################################################################
getOptions "$@"

cd "${scriptFolder}"

UnpackDistro									# Unpack UberGen distribution
if [ ! $optUnpack ] ; then
	osw="${optSwitches}"
	barf "##"
	barf "## UberGen System Build - Start"
	barf "##"
	./prerequisites-install.sh		$osw		# Prerequisites
	./perl-install.sh				$osw		# Perl Language
	./php-install.sh				$osw		# PHP Language
	./python-install.sh				$osw		# Python Language
	./system-hosts.sh				$osw		# System hosts file, configure with region servers
	./firewall-install.sh			$osw		# Firewall (UFW)
	./openssl-config.sh Create		$osw		# OpenSSL certificate generation and configuration
	./system-add-users.sh			$osw		# System users, groups, and support scripts [must come after SSL]
	./openssh-install.sh			$osw		# OpenSSH server install and configuration
	./mariadb-install.sh			$osw		# Database (MariaDB)
	./brave-install.sh				$osw		# Brave privacy web browser
	./vsftp-install.sh				$osw		# Secure FTP Server (VSFTP) install and configure
	./vnc-install.sh				$osw		# TigerVNC Remote Desktop Server install and configure
	./apache-install.sh				$osw		# Apache Web Server install and configure
	if [ $optWordPress ] ; then
		./wordpress-mariadb-config.sh	 $osw	# Create WordPress database(s) and users
		./wordpress-mariadb-config.sh -O $osw	# Permission WordPress database objects
		./wordpress-install.sh			 $osw	# Install WordPress software
	fi
	barf "#"
	barf "## UberGen System Build - End"
	barf "#"
fi