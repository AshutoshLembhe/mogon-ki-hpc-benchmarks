#!/bin/bash

# Classes and MPI-rank counts
CLASSES="A B C"
RANKS="1 4 16 64 128 256"

for CLASS in $CLASSES
do
    for N in $RANKS
    do
        # Select partition and number of nodes
        if [ "$N" -le 64 ]
        then
            PARTITION="ki-smallcpu"
            NODES=1
            TASKS_PER_NODE=$N
        elif [ "$N" -eq 128 ]
        then
            PARTITION="ki-parallel"
            NODES=1
            TASKS_PER_NODE=128
        else
            PARTITION="ki-parallel"
            NODES=2
            TASKS_PER_NODE=128
        fi

        echo "Submitting Class $CLASS with $N MPI ranks"

        sbatch \
            --partition="$PARTITION" \
            --nodes="$NODES" \
            --ntasks="$N" \
            --ntasks-per-node="$TASKS_PER_NODE" \
            --mem=32G \
            --time=02:00:00 \
            --job-name="npb${CLASS}-${N}r" \
            run_classABC.sh "$CLASS"
    done
done

echo
echo "All A, B and C jobs submitted."
echo "Use 'squeue --me' to monitor them."
