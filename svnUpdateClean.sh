#!env bash

# NOTE: This script destroys all local mods - run it with caution!

if [ "$1" == "" -o "$2" == "" ] ; then
	echo "usage: $0 lock_dir_suffix framework_base_dir" >&2
	echo "NOTE: This script destroys all local mods - run it with caution!"   >&2
	exit 1;
fi

if [ ! -d "$2" ] ; then
	echo "$2 is not a directory"
	exit 1;
fi

# lock dirs/files
LOCKDIR="/tmp/svnUpdate.$1"
PIDFILE="${LOCKDIR}/PID"

# exit codes and text for them - additional features nobody needs :-)
ENO_SUCCESS=0;  ETXT[0]="ENO_SUCCESS"
ENO_GENERAL=1;  ETXT[1]="ENO_GENERAL"
ENO_LOCKFAIL=2; ETXT[2]="ENO_LOCKFAIL"
ENO_RECVSIG=3;  ETXT[3]="ENO_RECVSIG"

###
### start locking attempt
###

trap 'ECODE=$?; 
#	echo "TRACE : Exit: ${ETXT[ECODE]}($ECODE)" >&2
	' 0

if mkdir "${LOCKDIR}" &>/dev/null; then

	# lock succeeded, store the PID and install signal handlers
	echo "$$" >"${PIDFILE}"

	trap 'ECODE=$?;
#		echo "TRACE : Removing lock. Exit: ${ETXT[ECODE]}($ECODE)" >&1
		rm -rf "${LOCKDIR}"' 0

	# the following handler will exit the script on receiving these signals
	# the trap on "0" (EXIT) from above will be triggered by this trap's "exit" command!
	trap '
		echo "NOTICE: Killed by a signal." >&2
		exit ${ENO_RECVSIG}
		' 1 2 3 15

#	echo "TRACE : Lock acquired, installed signal handlers"
else
	# lock failed, now check if the other PID is alive
	OTHERPID="$(cat "${PIDFILE}" 2&>/dev/null )"

	# if cat wasn't able to read the file anymore, another instance probably is
	# about to remove the lock -- exit, we're *still* locked
	#  Thanks to Grzegorz Wierzowiecki for pointing this race condition out on
	#  http://wiki.grzegorz.wierzowiecki.pl/code:mutex-in-bash
	if [ $? != 0 ]; then
		echo "WARN  : lock failed, PID ${OTHERPID} is active" >&2
		exit ${ENO_LOCKFAIL}
	fi

	if ! kill -0 $OTHERPID &>/dev/null; then
		# lock is stale, remove it and restart
		echo "NOTICE: removing stale lock of nonexistant PID ${OTHERPID}" >&2
		rm -rf "${LOCKDIR}"
#		echo "TRACE : restarting myself" >&2
		exec $0 "$@"
	else
		# lock is valid and OTHERPID is active - exit, we're locked!
		echo "WARN  : lock failed, PID ${OTHERPID} is active" >&2
		exit ${ENO_LOCKFAIL}
	fi
fi

# CD into working directory
cd "$2"

if [ ! -d './.svn' ] ; then
	echo "$2 is not under version control"
	exit 1;
fi

SVN_AUTH="--username your_svn_username --password your_svn_password"

# SVN Cleanup
SVN_CLEANUP="svn cleanup ${SVN_AUTH} ."
CLEANUP=$( $SVN_CLEANUP )
if [ ! "${CLEANUP}" == "" ] ; then
	echo
	echo "CLEANING UP WORKING COPY:"
	echo
	echo "${CLEANUP}"
fi

# Revert any local modifications
SVN_REVERT="svn revert ${SVN_AUTH} --depth infinity ."
REVERTED=$( $SVN_REVERT )
if [ ! "${REVERTED}" == "" ] ; then
	echo
	echo "REVERTING LOCAL MODIFICATIONS:"
	echo
	echo "${REVERTED}"
fi

# Delete any local additions
SVN_STATUS="svn status ${SVN_AUTH}"
DELETED=""
for file in $( $SVN_STATUS | grep '^?' | cut -c9- ) ; do 
	if [ "${DELETED}" == "" ] ; then
		echo
		echo
		echo "DELETING LOCAL ADDITIONS:"
		echo
		DELETED=1
	fi
	if   [ -f $file ] ; then
		echo "F '${file}'"
		rm -f ${file}
	elif [ -d $file ] ; then
		echo "D '${file}'"
		rm -rf ${file}
	else
		echo "? '${file}'"
	fi
done

# Update Repository
SVN_UPDATE="svn update ${SVN_AUTH} --force ."
UPDATED_FULL=$( $SVN_UPDATE )
UPDATED=$( echo "${UPDATED_FULL}" | grep -v 'At revision' )
if [ ! "${UPDATED}" == "" ] ; then
	echo
	echo "UPDATING FROM REPOSITORY:"
	echo
	echo "${UPDATED_FULL}"
fi

