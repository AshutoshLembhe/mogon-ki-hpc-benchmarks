#!/bin/bash

CLASSES="S A B C"
THREADS="1 4 16 64"

for CLASS in $CLASSES
do
    for N in $THREADS
    do
        echo "Submitting Class $CLASS with $N OpenMP threads"

        sbatch \
            --partition=ki-smallcpu \
            --nodes=1 \
            --ntasks=1 \
            --cpus-per-task="$N" \
            --time=00:10:00 \
            --job-name="omp${CLASS}-${N}t" \
            run_openMP.sh "$CLASS"
    done
done

echo
echo "All 1, 4, 16 and 64-thread jobs submitted."
