#!/bin/bash -e

#SBATCH -J control
#SBATCH -A ACORG-SL2-CPU
#SBATCH -o controller-%A.out
#SBATCH -p skylake
#SBATCH --time=00:05:00

. common.sh

function scheduleWork()
{
    # Schedule the worker script to run under SLURM.
    workerJobId=$(sbatch -n 1 worker.sh | cut -f4 -d' ')
    echo "Worker script scheduled to run under SLURM with job id $workerJobId" >> $LOG

    # Schedule ourselves to be run again once the worker has finished.
    jobid=$(sbatch --dependency=afterok:$workerJobId -n 1 controller.sh | cut -f4 -d' ')
    echo "Scheduled the controller to re-run (job id $jobid) once the worker is done" >> $LOG

    # Save the running job ids so they can be canceled (via 'make cancel').
    echo $workerJobId $jobid > $JOBIDS
}

if [ -z "$SLURM_JOB_ID" ]
then
    # Not running under SLURM. This is a first invocation from the command line.
    echo "SLURM loop started at $(date)" > $LOG
    scheduleWork
    cat $LOG
    exit 0
else
    status=$(./checker.sh)

    case $status in
        0)
            # Everything was ok on the last run, but more computation is
            # required, schedule more work.
            scheduleWork
            exit 0
            ;;

        1)
            # There was an error.
            echo "Error! Exiting at $(date)" >> $LOG
            exit 1
            ;;

        2)
            # Work completed.
            echo "Done at $(date), after $(wc -l < $RESULT_FILE) iterations." >> $LOG
            exit 0
            ;;

        *)
            # Huh?
            echo "Unknown exit status ($status) from checker.sh at $(date). Exiting." >> $LOG
            exit 1
            ;;
    esac
fi
