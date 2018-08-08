#!/bin/bash -e

#SBATCH -J control
#SBATCH -A ACORG-SL2-CPU
#SBATCH -o controller-slurm.out
#SBATCH -p skylake
#SBATCH --time=00:01:00

. common.sh

function scheduleWork()
{
    # Schedule the worker script to run under SLURM.
    workerJobId=$(sbatch -n 1 worker.sh | cut -f4 -d' ')
    echo "Worker script scheduled to run under SLURM with job id $workerJobId." >> $LOG

    # Schedule ourselves to be run again once the worker has finished (either cleanly
    # or with an error - see man sbatch for the --dependency options).
    jobid=$(sbatch --dependency=afterany:$workerJobId -n 1 controller.sh | cut -f4 -d' ')
    echo "Scheduled the controller to re-run (job id $jobid) once the worker is done." >> $LOG

    # Save the running job ids so they can be canceled (via 'make cancel').
    echo $workerJobId $jobid > $JOBIDS
}

if [ -z "$SLURM_JOB_ID" ]
then
    # Not running under SLURM. This is a first invocation from the command line.
    echo "SLURM loop started at $(date)" > $LOG
    echo >> $LOG
    scheduleWork
    cat $LOG
    exit 0
else
    echo >> $LOG

    status=$(./checker.sh)

    case $status in
        error)
            echo "Error! Exiting at $(date)" >> $LOG
            exit 1
            ;;

        finished)
            # All work is completed.
            echo "Done at $(date), after $(wc -l < $RESULT_FILE) iterations." >> $LOG
            exit 0
            ;;

        iterate)
            # Everything was ok on the last run, but more computation is needed. Schedule it.
            scheduleWork
            exit 0
            ;;

        *)
            echo "Unknown status ($status) printed by checker.sh at $(date). Exiting." >> $LOG
            exit 1
            ;;
    esac
fi
