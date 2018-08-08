run:
	./controller.sh

cancel:
	./cancel.sh

clean:
	rm -f controller-*.out worker-*.out slurm-loop.* *~
