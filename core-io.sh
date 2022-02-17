#
# core-io.sh
#
#	Core UberGen I/O Routines
#
#	Description:
#
#       Variety of commonly used I/O routines.
#
#	Copyright:
#		Copyright (c) 2021, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2021.04.29  01.03    KurtSchulte    Original Version
#
####################################################################################################

#
# Prompt to Continue
#
SysadminPester() {
	local stepName="$1"
	local ans=
	if [ $optPrompt ] ; then 
		read -p "${stepName}.Ok2GO?: " ans
		if [[ "${ans}" != *[Yy]* ]] ; then exit 1 ; fi
	fi
}

SysadminPesterTrace() {
	local stepName="TRACE:$1"
	if [ $optDebug ] || [ $optTrace ] ; then SysadminPester "${stepName}" ; fi
}

#
# Output Routines
#
barf()   	{ echo "$1" ; barfl "$1" ; }
#catbarf()   { local fn="${1--}"; cat "${fn}" ;  [ $optLog ] && cat  < <(CatStamp "${fn}") >>"${optLogFile}" ; }		# Async output substitute process lags
#catbarfl()  { local fn="${1--}";                [ $optLog ] && cat  < <(CatStamp "${fn}") >>"${optLogFile}" ; }		# Async output substitute process lags
barfl()  	{ [ $optLog ] && 		cat < <(LogStamp "$1") >>"${optLogFile}" ; }
barfv()  	{ [ $optVerbose ] && 	barf "$1" ; }
barfd()  	{ [ $optDebug ] &&		barf "$1" ; }
barfdd() 	{ [ $optDebug ] &&		barf "DEBUG:$1" ; }
barfdt() 	{ [ $optDebug ] &&		barf "TRACE:$1" ; }
barft()  	{ [ $optTrace ] &&		barf "TRACE:$1" ; }
barfe()  	{ barf "$1" ; exit 1 ; }
barfee() 	{ barfe "${prognm}.${progLabel}.Error: $1" ; }

catbarf() {
	local fn="${1--}";
	local buffer=$(cat "${fn}")
	
	if [ "${buffer}" != "" ] ; then
		echo "${buffer}"
		[ $optLog ] && echo "${buffer}" | CatStamp >>"${optLogFile}"
	fi
}

catbarfv() {
	local fn="${1--}";
	local buffer=$(cat "${fn}")

	if [ "${buffer}" != "" ] ; then
		[ $optVerbose ] && echo "${buffer}"
		[ $optLog ] && echo "${buffer}" | CatStamp >>"${optLogFile}"
	fi
}

catbarfl() {
	local fn="${1--}";
	local buffer=$(cat "${fn}")
	
	if [ "${buffer}" != "" ] ; then
		[ $optLog ] && echo "${buffer}" | CatStamp >>"${optLogFile}"
	fi
}

#
# Debug routines
#
dumpVariable() {
	local varName="$1"
	local varValue="${!varName}"
	printf '%-25s : %s\n' "${varName}" "${varValue}"
}

dumpVariable2() {
	local varName="$1"
	local varValue="$2"
	printf '%-25s : %s\n' "${varName}" "${varValue}"
}

traceVariable() {
	local varName="$1"
	local varValue="${!varName}"
	if [ $optTrace ] ; then dumpVariable2  "${varName}" "${varValue}" ; fi
}

traceVariable2() {
	local varName="$1"
	local varValue="$2"
	if [ $optTrace ] ; then dumpVariable2  "${varName}" "${varValue}" ; fi
}

LogInitialize() {
	local logOption=$1
	local logFile="$2"
	local logAppend=$3
	progLabel="LogInitialize"

	local default_log_file="$(pwd)/ubergen.log" ; default_log_file="${default_log_file//\/\//\/}"
	
	# Determine and validate log file location, then initialize
	if [ "${logOption}" == "1" ] ; then
		[ "${logFile}" == "" ] && logFile="${default_log_file}"				# Use default log file spec, if none provided
		[ -f "${logFile}" ] && [[ "${logAppend}" != *[Yy1]* ]] && rm "${logFile}"	# Remove old log
		touch "${logFile}"															# Initialize log file
		[ $? -ne 0 ] && barfee "Can't access log file (logFile=${logFile})"
		optLogFile="${logFile}"
	fi
	barft "${LogInitialize}:logFile='${logFile}'"
}

LogCapture() {
	tee -a "${optLogFile}"
}

LogStamp() {
	local text="$1"
	local currTS=$(date +%Y.%m.%d-%H.%M.%S)

	local logText="${text}"
	[ $(echo "${text}" | grep -c '^[0-9]\{4\}[.][0-9]\{2\}[.][0-9]\{2\}') -eq 0 ] &&
		logText="${currTS}: ${text}"

	printf "%s\n" "${logText}"
}

CatStamp() {
	local fileSpec="$1"
	local currTS=$(date +%Y.%m.%d-%H.%M.%S)
	[ "${fileSpec}" == "" ] && fileSpec=-
	cat "${fileSpec}" | sed -e "s~^~${currTS}: ~"
}

