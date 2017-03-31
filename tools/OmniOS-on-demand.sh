#!/usr/bin/ksh

#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2014 OmniTI Computer Consulting, Inc. All rights reserved.
#

#
# OmniOS-on-demand is a wrapper script designed to be run by cron(1) once
# per minute.
#
# Every minute it checks for "gate churn", that is, changes to source repos.
# If there is no gate churn, AND no previously recorded gate churn, this
# script exits immediately.
#
# If there is gate churn, the script records it (see STATEFILE below), and
# subsequent gate churn checks are counted.  Once DELAY_CYCLES times without
# gate churn have run, then the build happens.
#
# This script assumes being run by cron as a regular user.  To this end, a
# file needs to be dropped into /etc/sudoers.d, so root-requiring omnios-build
# scripts (notably Kayak) can be run.
#
# This script also takes advantage of PREBUILT_ILLUMOS in omnios-build to
# run the illumos-omnios nightly.sh script in parallel with the rest of
# omnios-build.  Because of quirks in omnios-build, this is not as
# Amdahl's Law efficient as desired.  Subsequent fixes to omnios-build may
# eliminate those chokepoints, if not even the need for PREBUILT_ILLUMOS.
#

#
# Shell variables for use locally (no export) or with sub-programs (exported).
#

# Log file.
LOGFILE=$HOME/log-`date "+%m-%d-%Y:%H:%M:%S"`

# Directory where in-progress IPS repo goes.
# NOTE: If this script succeeds, this repo will become FINAL_REPO (below).
INPROGRESS_REPO=$HOME/builder-new.repo

# Directory where final built IPS repo goes.
# NOTE: If this script fails, FINAL_REPO remains untouched.
FINAL_REPO=$HOME/builder.repo

# Hacky workaround... some shells don't set this.
export USER=`whoami`

# Child of illumos-omnios, on a filesystem upon which we can build.
ILLUMOS_PATH=$HOME/data/illumos-omnios

# env file for "nightly" - NOTE: This script uses nightly from the gate itself.
ILLUMOS_ENV=$HOME/data/illumos-omnios.env

# Child of omnios-build, on a filesystem upon which we can log.
BUILD_PATH=$HOME/data/omnios-build

# omnios-build's site.sh variables we need - export 'em.
# export KVM_CMD_ROLLBACK=1c6181be55d1cadc4426069960688307a6083131
export PREBUILT_ILLUMOS=$ILLUMOS_PATH
export PKGSRVR=file://$INPROGRESS_REPO

# List of repos to check for changes.  Since omnios-build is updated as
# upstream sources change (e.g. version updates), this list will be likely just
# ILLUMOS_PATH and BUILD_PATH gates.
GATEPATHS="$ILLUMOS_PATH $BUILD_PATH"

# Set to non-zero if we have any changes in GATEPATHS above.
GATE_CHANGES=0
PULL_LOG=$HOME/pull-log

# So we can keep sane during once-per-cycle invocations, save our state if
# need be.
#
# An operator can override this script by putting a number <= 0 in $STATEFILE,
# which means suspend all operations of this script.  (Even if it was
# overridden during the delay between gate churn and kicking off a build.)
#
# An operator can also put a positive number in here that is one less than
# $DELAY_CYCLES (seee below) to immediately spin a build.  It is recommended
# that $PULL_LOG be non-empty if the operator performs this trick.
#
STATEFILE=$HOME/building

# This is cron(1)-driven: One cycle == 1 minute elapsed.
# We count $DELAY_CYCLES times after gate churn settles down, then build.
# The idea is if there are multiple deltas or pushed to multiple gates, we
# get them all before turning the crank on a build.
DELAY_CYCLES=10


#
# Functions
#

# What it says on the tin. Sets GATE_CHANGES to 1 if any gates have new bits.
pull_and_check_gates() {
	for gate in $GATEPATHS; do
		cd $gate
		# Don't do "--all", just stick with master for now.
		git pull >/tmp/gitout.$$ 2>&1
		if [ $? != 0 ]; then
			date
			echo "Git pull failed: ($STATEFILE = `cat $STATEFILE`)"
			echo "   gate == $gate"
			echo ""
			echo "NOTE: Setting gate-churn counter $STATEFILE to 0."
			echo "      You will have to fix things and clear it."
			# /bin/rm $STATEFILE
			echo 0 > $STATEFILE
			cat /tmp/gitout.$$
			rm /tmp/gitout.$$
			# Yeah, when we have git pull problems, we bail!
			exit 1
		fi
		grep -q "Already up-to-date." /tmp/gitout.$$
		if [ $? -ne 0 ]; then
			GATE_CHANGES=1
			cat /tmp/gitout.$$ >> $PULL_LOG
		fi
		rm /tmp/gitout.$$
	done
}

# What it says on the tin.  We start the illumos-omnios build concurrently
# with the omnios-build.  Omnios-build now has enough smarts to honor
# PREBUILT_ILLUMOS and wait for it to finish.  Eventually we should either
# rearrange the order omnios-build works to maximize parallelism, or further
# decouple the two.
build_gates() {
	#echo "It's BUILDING TIME!!!"

	# Use the gate's copy of nightly.
	cp $ILLUMOS_PATH/usr/src/tools/scripts/nightly.sh /tmp/nightly.$$
	chmod 0700 /tmp/nightly.$$
	# Build illumos-omnios in the background.
	# omnios-build knows to pwait(1) for it.
	# If this changes, use $! to capture the pid of the amped-off process.
	/tmp/nightly.$$ $ILLUMOS_ENV &

	cd $BUILD_PATH/build
	# NOTE: -l flag should eventually go away once we pkglint-clean
	# the world.  Also, use KAYAK_SUDO_BUILD to make kayak happen.
	# Per above, /etc/sudoers.d needs an appropriate file with
	# appropriate permissions.
	export KAYAK_SUDO_BUILD=1
	# Also clobber kayak's special rpool.
	export KAYAK_CLOBBER=1

	# The kayak-kernel bits MUST go at the end, because it depends on
	# everything else having been built already.  This is a hack.
	./buildctl list-build | awk '{print $2}' | grep -v kayak-kernel \
	    > /tmp/blist.$$
	./buildctl list-build | awk '{print $2}' | grep kayak-kernel \
	    >> /tmp/blist.$$
	./buildctl -lb build `cat /tmp/blist.$$`
	rm -f /tmp/blist.$$

	# NOW clean the existing packages, and replace 'em.
	# /bin/rm -rf $FINAL_REPO
	# mv $INPROGRESS_REPO $FINAL_REPO

	# NOW upgrade the existing packages with the ones you just built.
	echo "Sending just-built packages upstream. Using /bin/time..."
	/bin/time pkgrecv -s $INPROGRESS_REPO -d $FINAL_REPO 'pkg:/*' > /dev/null
	/bin/rm -rf $INPROGRESS_REPO
	echo "Refreshing $FINAL_REPO"
	pkgrepo refresh -s $FINAL_REPO
}

#
# Main script functionality starts now.
#

# Check to see if we are disabled.
if [ -e $STATEFILE ]; then
	# Yes, I understand someone who runs two of these together will
	# create a race.  This should be run once a minute by cron(1).
	COUNT=`cat $STATEFILE`
	if [ $COUNT -le 0 ]; then
		# echo "Exiting, $STATEFILE set to 0, therefore overridden."
		exit 1
	fi
	COUNT=`expr $COUNT + 1`
else
	# Not disabled, but set to 0 in case we have gate churn.
	COUNT=0
fi
# Lock out other invocations, in case pulling & checking the gates
# takes too long.
echo "0" > $STATEFILE

# Check gates for updates.
pull_and_check_gates
if [ $GATE_CHANGES != 0 ]; then
	# AHA!  We have gate churn, so reset the counter to 1 until we have
	# DELAY_CYCLES of unchanged gates.
	COUNT=1
fi

if [ $COUNT == 0 ]; then
	# Common-case -> exit because there have been no gate changes to
	# kick off a build after DELAY_CYCLES times.
	rm -f $STATEFILE
	exit 0
fi

if [ $COUNT -lt $DELAY_CYCLES ]; then
	# Record how many times (minutes) we've run, by...
	# echo "Incrementing $STATEFILE to $COUNT."
	echo $COUNT > $STATEFILE
	exit 0
fi


# If we reach here, build and then clobber things.  The gates have settled down
# after DELAY_CYCLES checks.
# Record build's start date.
echo "Build start date: `date`" | tee -a $LOGFILE
# Remove omnios-build's tmp gate.
/bin/rm -rf /tmp/build_$USER
build_gates >> $LOGFILE 2>&1
# Record build's end date to see how long it took.
echo "Build end date: `date`" | tee -a $LOGFILE
echo "Log in $LOGFILE"
echo "Pull log is below:" | tee -a $LOGFILE
cat $PULL_LOG | tee -a $LOGFILE
# Cleanup on bit from build_gates.
rm -f /tmp/nightly.$$
rm -f $PULL_LOG
# Reset everything to normal for next gate checks.
rm -f $STATEFILE
exit 0
