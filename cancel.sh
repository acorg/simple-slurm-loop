#!/bin/bash -e

. common.sh

if test -f $JOBIDS
then
    jobids=$(cat $JOBIDS)
    scancel $jobids
    rm $JOBIDS
    echo Canceled jobs $jobids at $(date). >> $LOG
    echo Canceled jobs $jobids.
else
    echo Nothing was running.
fi
