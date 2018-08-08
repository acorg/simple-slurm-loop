#!/bin/bash

# The worker has finished. Check its output and exit with status:
#
#   0 if everything is ok and more work should be scheduled
#   1 if there was an error.
#   2 if all work has been completed.
#
# For the purposes of this example, the decision on how to exit is based on
# the first digit of the last line in the results file. That line is
# created by the worker (in worker.sh).

. common.sh

rm -f $JOBIDS

latestResult=$(tail -n 1 < $RESULT_FILE | cut -c1)

case $latestResult in
    1) exit 1;;
    [2-4]) exit 2;;
    *) exit 0;;
esac
