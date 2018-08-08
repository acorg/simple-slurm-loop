## A simple SLURM loop

Here are some shell scripts to run a loop in SLURM, where the continuation
of the loop is determined by what happened the last time it ran. The idea
is to kick off some work that only gets done in pieces (e.g., an
optimization) and which may need to be continued.

This is all very simple, the scripts don't really do anything much. They
could have been combined but I wanted to separate the functionality to make
the operation more transparent / explicit.

The scripts are:

* `controller.sh` - Starts a new worker (via `sbatch`) and schedules itself
  to run after the worker is finished. Uses `checker.sh` to determine if
  the worker is finished, had an error, or needs to be run again.
* `worker.sh` - Does the work.
* `checker.sh` - Checks to see the result of the last `worker.sh` run and
  exits with a status indicating error, done, or continue.
* `cancel.sh` - Cancels (via the SLURM `scancel` command) the
  currently scheduled jobs, if any.
* `common.sh` - Contains file name variables shared by other scripts.

There is a `Makefile` that can be used via

* `make run` - starts the controller for the first time (via `controller.sh`).
* `make cancel` - stops currently scheduled jobs, if any (via `cancel.sh`).
* `make clean` - cleans up output files.

You can adapt this to your own purposes by replacing the worker and the
checker (and likely altering the shared variables in `common.sh`). You'll
also have to change the SLURM sbatch parameters (the `#SBATCH` lines) at
the start of the worker and controller.

The trivial example worker script just adds a random number to an output
file (`slurm-loop.result`). The checker script looks at the last digit of
the last line of that file to decided whether the overall job should be
considered done, in error, or in progress. If the last digit is a `0` it
considers the worker to have failed, if it's 1, 2, or 3 the worker is
finished, and if it's 4-9 the worker needs to be restarted.  So after each
iteration of the worker there's a 0.1 chance it will have ended in error,
a 0.3 chance it will have ended cleanly, and a 0.6 chance it should be
continued.

A log file (`slurm-loop.log`) is updated as the overall work is performed.
