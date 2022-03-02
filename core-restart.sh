#
# core-restart.sh
#
#	UberGen Restartability Module
#
#	Description:
#
#       Tracks install phase status and assists with restart functionality.
#
#	Copyright:
#		Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.02.23  01.04    KurtSchulte    Original Version
#
####################################################################################################

#
# Constants
#
UG_STATUS_NONE="<none>"

#
#  Status Tracking Initializaztion
#
UberStatusInitialize() {
	local progLabel="UberStatusInitialize" ; barfdt "${progLabel}.Entry()"

	[ -f "${ug_status_file}" ] && rm $verboseFlag "${ug_status_file}"

	barfdt "UberStatusInitialize.Exit"
}

#
#  Status Tracking Initializaztion
#
UberStatusSet() {
	local newStatus="$1"
	local progLabel="UberStatusSet" ; barfdt "${progLabel}.Entry(newStatus='${newStatus}')"

	[ "${ug_status_file}" == "" ] && barfee "Error: UberGen configuration variable ug_status_file is not set."

	ug_status="${newStatus}"							# Set working status
	echo "status=${newStatus}" >"${ug_status_file}"		# Persist status

	barfdt "UberStatusSet.Exit"
}

#
# Determine if an install is in progress and unfinished
#
UberStatusGet() {
	local progLabel="UberStatusGet" ; barfdt "${progLabel}.Entry()"

	[ "${ug_status_file}" == "" ] && barfee "Error: UberGen configuration variable ug_status_file is not set."

	ug_status="${UG_STATUS_NONE}"
	ug_status_module=""
	[ -f "${ug_status_file}" ] && {
		ug_status=$(cat "${ug_status_file}" | sed -e 's~^[ \t]*status[ \t]*=~~;s~[\ ]\+$~~') ;
		ug_status_module="${ug_status%%:*}" ;
	}

	barfdt "ug_status_module = '${ug_status_module}'"
	barfdt "ug_status        = '${ug_status}'"
	
	barfdt "UberStatusGet.Exit"
}

#
#  Status Tracking Finalization
#
UberStatusFinalize() {
	local progLabel="UberStatusFinalize" ; barfdt "${progLabel}.Entry()"

	[ -f "${ug_status_file}" ] && rm $verboseFlag "${ug_status_file}"

	barfdt "UberStatusFinalize.Exit"
}

#
# Prepare ~/.bashrc for script to run on reboot
#
RebootScriptConfigure() {
	local rebootScript="$1"
	progLabel="RebootScriptConfigure" ; barfdt "${progLabel}.Entry(rebootsctipt='${rebootScript}')"

	local rebootText="${rebootScript}  # ${RESTART_EDIT_TAG}"
	echo "${rebootText}" >>"${HOME}/.bashrc"
	
	barfds "RebootScriptConfigure.Write: Added '${rebootText}' to '${HOME}/.bashrc'"

	barfdt "RebootScriptConfigure.Exit()"
}

#
# Remove restart script call from ~/.bashrc
#
RebootScriptClear() {
	local rebootScript="$1"
	progLabel="RebootScriptClear" ; barfdt "${progLabel}.Entry()"

	sed -i -e "/# ${RESTART_EDIT_TAG}/d" "${HOME}/.bashrc"

	barfdt "RebootScriptClear.Exit()"
}

