#!/bin/bash

# This script does personal backups to a rsync backup server. You will end up
# with a 7 day rotating incremental backup. The incrementals will go
# into subdirectories named after the day of the week.

# Directory to backup. Entire filesystem in our case.
SBDIR=/var/www/wp-content
# Target root for full backups. 
TBDIR=/usr/local/mysql/wp-content-bak/full
# Target root for incremental backups. 
TIBDIR=/usr/local/mysql/wp-content-bak/incr/`date +%A`

# excludes file - this contains a wildcard pattern per line of files to exclude. Excluding such things as proc, dev, sys, mnt, etc.
EXCLUDES=/usr/local/mysql/ex.list

# the name of the source machine. Backing up locally
# SSERVER=

########################################################################

# Incrementals named after weekdays.
OPTS="--force --ignore-errors --delete-excluded --exclude-from=$EXCLUDES
      --delete --backup --backup-dir=$TIBDIR -av"

# Making sure that rsync is in PATH
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin

# the following line clears the last weeks incremental directory
[ -d $HOME/emptydir ] || mkdir $HOME/emptydir
rsync --delete -av $HOME/emptydir/ $TIBDIR/
rmdir $HOME/emptydir

# now the actual transfer
# echo "rsync $OPTS $SSERVER:$SBDIR $TBDIR/"
rsync $OPTS $SBDIR $TBDIR/
