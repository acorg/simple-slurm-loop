#!/bin/bash -e

# The worker has finished. Check its output and print a status:
#
#   0 if there was an error.
#   1 if all work has been completed.
#   2 if everything is ok and more work should be scheduled
#
# For the purposes of this example, the decision on the status to print is
# based on the last digit of the last line in the results file. That line
# is created by the worker (in worker.sh).

. common.sh

rm -f $JOBIDS

digit=$(tail -n 1 < $RESULT_FILE | awk '{print substr($1, length)}')

case $digit in
    0)     echo 0;;
    [123]) echo 1;;
    *)     echo 2;;
esac
