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
#			Debian 11.x,10.x
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
#           mysql-workbench-install     MySQL Community Workbench
#			brave-install				Brave privacy web browser
#			vsftp-install				Secure FTP Server (VSFTP) install and configuration
#			vnc-install					TigerVNC Remote Desktop Server install and configuration
#			wordpress-mariadb-config	WordPresss database configuration
#			wordpress-install			WordPresss installation
#
#	Usage:
#       ubergen.sh [-laSvdty] [-L <logfile>] [-u] [-p] [-W] -P <password>
#
#           Options:
#               -W            Include WordPress installation
#               -u            Unpack UberGen Distribution, Only
#               -p            Prompt for approval between stages
#               -y            No prompt on destructive actions (ex: distro unpack)
#               -l            Log
#               -L <logfile>  Write log data to <logfile> (default=./ubergen.log)
#               -S            Log separate
#               -v            Verbose (displays detailed info)
#               -d            Debug (displays more detailed info)
#               -t            Trace (displays exhaustive info)
#
#	Copyright:
#		Copyright (c) 2021, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.02.17  01.04    KurtSchulte    Logging updates, bug fixes, cross-reboot opertation
#       2021.04.29  01.03    KurtSchulte    Core routines
#       2021.01.28  01.00    KurtSchulte    Original Version
#
####################################################################################################
prognm=ubergen.sh
scriptFolder=$(echo "${0%/*}" | sed -e "s~^[.]~`pwd`~")

#
# Core Routines
#
source ${scriptFolder}/core-configuration.sh			# UberGen configuration data and routines
source ${scriptFolder}/core-io.sh						# UberGen I/O routines
source ${scriptFolder}/core-restart.sh					# UberGen cross-reboot routines

#
# Constants
#
export UG_UBER_RUN=1

#
# Unpack Distribution
# 
UnpackDistro() {
	barfdt "UnpackDistro.Entry()"

	local keyFile="${scriptFolder}/osinfo.sh"
	local tarBall="${scriptFolder}/UberGen.tar.z"
	local zipPassOption=
	[ "${optDistroPass}" != "" ] && zipPassOption="-P ${optDistroPass}"

	local doUnpack=1
	if [ -e "${keyFile}" ] ; then
		doUnpack=
		if [ $optUnpack ] ; then
			doUnpack=$optYes
			if [ ! $optYes ] ; then
				local ans
				while [[ "${ans}" != *[YyNn]* ]] ; do
					read -p "UberGen is already installed.  Overwrite? [Y/N]: " ans </dev/tty
				done
				[[ "${ans}" == *[Yy]* ]] && doUnpack=1
			fi
		fi
	fi

	if [ $doUnpack ] ; then
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
	optLogSeparate=
	optVerbose=
	optDebug=
	optTrace=
	optUnpack=
	optDistroPass=
	optWordPress=
	optPrompt=
	optYes=

	while getopts "?hlL:vdtupP:WaSy" OPTION
	do
		case $OPTION in
			h)	usage ; exit 1                                      ;;
			W)  optWordPress=1										;;
			u)  optUnpack=1											;;
			P)  optDistroPass=$OPTARG								;;
			p)	optPrompt=1                                         ;;
			y)	optYes=1                                            ;;
			l)	optLog=1                                            ;;
			a)	optLogAppend=1                                      ;;
			S)	optLogSeparate=1                                    ;;
			L)  optLogFile="${OPTARG//\"/}" ; optLog=1				;;
			v)  optVerbose=1 ; optLog=1                             ;;
			d)  optDebug=1 ; optVerbose=1 ; optLog=1                ;;
			t)  optTrace=1; optDebug=1 ;   optVerbose=1 ; optLog=1  ;;
			?)  usage ; exit                                        ;;
		 esac
	done
	shift $(($OPTIND - 1)) 

	verboseFlag=
	[ $optTrace ] && verboseFlag=-v

	# Set option switches for downstream script calls
	[ $optLogSeparate ] && optLogAppend=
	debugFlag=	; 		[ $optDebug ] && 		debugFlag="-d"		;
	verboseFlag= ;		[ $optVerbose ] && 		verboseFlag="-v"	;
	traceFlag= ; 		[ $optTrace ] &&		traceFlag="-t"		;
	logAppendFlag=	; 	[ $optLogAppend ] &&	logAppendFlag="-a" ;
	logFlag=	; 		[ $optLog ] && 			logFlag="-l" ;
	logFileFlag= ;		[ "${optLogFile}" != "" ] && logFileFlag='-L"'"${optLogFile}"'"'
	
	logSeparateFlag= ;	[ $optLogSeparate ] &&	logSeparateFlag="-S" ;
	wordPressFlag= ;	[ $optWordPress ] &&	wordPressFlag="-W" ;

	export UG_UBER_FLAGS="${logSeparateFlag} ${wordPressFlag} ${verboseFlag} ${debugFlag} ${traceFlag} ${logFileFlag}"

	LogInitialize "${optLog}" "${optLogFile}" "${optLogAppend}"
	
	[ $optLog ] && logAppendFlag="-a"			# Cause child modules to append to this log

}

usage() {
    cat <<EOFUsage
${prognm} [-laSvdty] [-L <logfile>] [-u] [-p] [-W] -P <password>

    Options:
        -W            Include WordPress installation
        -u            Unpack UberGen Distribution, Only
        -P            Unpack UBerGen Distribution password
        -p            Prompt between major sections
        -y            No prompt on destructive actions (ex: distro unpack)
        -l            Log
        -L <logfile>  Write log data to <logfile> (default=./ubergen.log)
        -S            Log separate
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

	UberStatusGet

	barf "ug_status_module(returned) : ${ug_status_module}"
	barf "ug_status(returned)        : ${ug_status}"
	barf "UG_STATUS_NONE             : ${UG_STATUS_NONE}"

	uberModules="prerequisites-install"							# Prerequisites
	uberModules="${uberModules},perl-install"					# Perl Language
	uberModules="${uberModules},php-install"					# PHP Language
	uberModules="${uberModules},python-install"					# Python Language
	uberModules="${uberModules},system-hosts"					# System hosts file, configure with region servers
	uberModules="${uberModules},firewall-install"				# Firewall (UFW)
	uberModules="${uberModules},openssl-config Create"			# OpenSSL certificate generation and configuration
	uberModules="${uberModules},system-add-users"				# System users, groups, and support scripts [must come after SSL]
	uberModules="${uberModules},openssh-install"				# OpenSSH server install and configuration
	uberModules="${uberModules},mariadb-install -C"				# Database (MariaDB with InnoDB and ColumnStore engines)
	uberModules="${uberModules},mysql-workbench-install"		# MYSQL Community Workbench
	uberModules="${uberModules},brave-install"					# Brave privacy web browser
	uberModules="${uberModules},vsftp-install"					# Secure FTP Server (VSFTP) install and configure
	uberModules="${uberModules},vnc-install"					# TigerVNC Remote Desktop Server install and configure
	uberModules="${uberModules},apache-install"					# Apache Web Server install and configure

	uberModules="${uberModules},WP:wordpress-mariadb-config"	# Create WordPress database(s) and users
	uberModules="${uberModules},WP:wordpress-mariadb-config -O"	# Permission WordPress database objects
	uberModules="${uberModules},WP:wordpress-install"			# Install WordPress software

	commandDebugFlags="${verboseFlag} ${debugFlag} ${traceFlag}"
	commandLogFlags="${logAppendFlag} ${logFlag} ${logFileFlag}"

	barf "##"
	barf "## UberGen System Build - Start"
	barf "##"

	moduleCt=0
	
	doingRestart= ; [ "${ug_status_module}" != "" ] && doingRestart=1
	
	while read moduleInfo ; do
		moduleCt=$(( $moduleCt + 1 ))
		moduleName="${moduleInfo}"
		moduleParams=""
		moduleFlags=""
		moduleWpOnly=
		moduleInstallNeeded=1
		
		barf "DEBUG: Evaluating moduleInfo '${moduleInfo}'..."
		barf "DEBUG: moduleName1='${moduleName}'"
		barf "DEBUG: moduleWpOnly1='${moduleWpOnly}'"
		
		# Get WP-Only flag, if any
		if [ "${moduleName:0:3}" == "WP:" ] ; then
			moduleName="${moduleName:3}"
			moduleWpOnly=1
		fi
		
		barf "DEBUG: moduleName2='${moduleName}'"
		barf "DEBUG: moduleWpOnly2='${moduleWpOnly}'"

		# Get module options and params, if any
		if [ "${moduleName// /}" != "${moduleName}" ] ; then
			moduleTags="${moduleName##* }"
			moduleName="${moduleName%% *}"
			[ "${moduleTags// /}" != "${moduleTags}" ] && barfe "Ubergen Module '${moduleName}' has multiple params/options. Codefix needed"
			if [ "${moduleTags:0:1}" == "-" ] ; then
				moduleFlags="${moduleTags}"
			else
				moduleParams="${moduleTags}"
			fi
		fi
		moduleScript="${scriptFolder}/${moduleName}.sh"
		
		# Determine if module should be installed
		[ $moduleWpOnly ] && [ ! $optWordPress ] && moduleInstallNeeded=
		
		# If doing restart, skip modules until we hit the one to restart at
		[ $doingRestart ] && [ "${moduleName}" != "${ug_status_module}" ] && moduleInstallNeeded=

		# Install module
		barfd "Install module '${moduleName}',installNeeded=${moduleInstallNeeded}"
		if [ $moduleInstallNeeded ] ; then
		
			# clear doing restart flag... carry on normal from here, if it was a restart
			doingRestart=
		
			# determine log file name, if logging separately
			if [ $optLogSeparate ] ; then
				logFolder="."
				[ "${optLogFile//\//}" != "${optLogFile}" ] && logFolder="${optLogFile%/*}"
				logNumber=$(printf "%02d" "${moduleCt}")
				logFileSeparate="${logFolder}/ubergen-${logNumber}-${moduleName}.log"
				logFileFlag='-L"'"${logFileSeparate}"'"'
				commandLogFlags="${logAppendFlag} ${logFlag} ${logFileFlag}"
			fi
		
			# Run module script
			"${moduleScript}" $moduleFlags $commandDebugFlags $commandLogFlags $moduleParams
			errCode=$? ; [ $errCode -ne 0 ] && barfe "Error executing UberGen module '${moduleName}', err=${errCode}"
			
			if [ $moduleCt -eq 99 ] ; then
				read -p "OK2GO?: " ok2goAns </dev/tty
			fi
			
		fi

	done < <(printf "%s," "${uberModules}" | tr ',' '\n')
	
	barf "#"
	barf "## UberGen System Build - End"
	barf "#"
fi

exit 0