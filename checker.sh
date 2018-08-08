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

# Clean up SLURM output files.
for what in worker controller
do
    file=$what-slurm.out
    if [ -f $file ]
    then
        if [ -s $file ]
        then
            echo "WARNING: SLURM output file $file was non-empty!" >> $LOG
            echo "--- Begin $file content ---" >> $LOG
            # Append the file content to the log because the file will be
            # overwritten on the next iteration (if any).
            cat $file >> $LOG
            echo "--- End $file content ---" >> $LOG
        fi
        rm $file
    fi
done

digit=$(tail -n 1 < $RESULT_FILE | awk '{print substr($1, length)}')

case $digit in
    0)     echo 0;;
    [123]) echo 1;;
    *)     echo 2;;
esac
