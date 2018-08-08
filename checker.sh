#!/bin/bash -e

# The worker has finished. Check its output and print a status:
#
#   'error' if there was an error.
#   'finished' if all work has been completed.
#   'iterate' if everything is ok and more work should be scheduled.
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
    0)     echo error;;
    [123]) echo finished;;
    *)     echo iterate;;
esac
