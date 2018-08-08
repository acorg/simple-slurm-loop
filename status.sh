#!/bin/bash -e

. common.sh

if test -f $JOBIDS
then
    sacct -j $(echo $(cat $JOBIDS) | tr ' ' ,)
else
    echo Nothing is running.
fi
