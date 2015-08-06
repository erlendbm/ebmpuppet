#!/bin/bash
# Script to clean out old kernels
# Erlend Midttun, <erlend.midttun@ntnu.no>

KEEPKERNELS=3
REBOOTFILE="/var/run/reboot-required"
ALREADYPRESENT=false

TMPFILE=$(mktemp -t kernelclean.XXXXXXXXXX)
if [ $? -ne 0 ]; then
    echo "Could not create temp file, exiting"
    exit 1
fi

if [ -e "$REBOOTFILE" ]; then
    ALREADYPRESENT=true
fi

if grep -q "Ubuntu" /etc/issue; then
    dpkg -S vmlinuz | sed -e 's/:.*$//' | sort -n > $TMPFILE
    DELCMD="aptitude purge -y"
elif grep -q "Red Hat" /etc/issue; then
    rpm -q kernel | sort -n > $TMPFILE
    DELCMD="rpm -e"
elif grep -q "SUSE" /etc/issue; then
    # Both kernel-default, kernel-smp and kernel-bigsmp may appear here
    rpm -qa | egrep -c 'kernel-smp|kernel-bigsmp|kernel-default' | sort -n > $TMPFILE
    DELCMD="rpm -e"
else
    echo "No supported operating system found"
    exit 1
fi

COUNT=$(cat $TMPFILE | wc -l)
if [ "$COUNT" -gt "$KEEPKERNELS" ]; then
    SPARE=$(($COUNT-$KEEPKERNELS))
    if [ "$1" == "--force" ]; then
        echo "Removing the following kernels"
        cat $TMPFILE | head -n $SPARE
        echo "Keep the following kernels"
        cat $TMPFILE | sed -e 1,${SPARE}d
        $DELCMD $(cat $TMPFILE | head -n $SPARE)
    else
        echo "Would remove the following kernels"
        cat $TMPFILE | head -n $SPARE
    fi
    echo "Keep the following kernels"
    cat $TMPFILE | sed -e 1,${SPARE}d
fi

if [ "$ALREADYPRESENT" == "false" ]; then
    rm -f /var/run/reboot-required
fi

rm -f $TMPFILE
# If we made it this far, we are ok
exit 0

