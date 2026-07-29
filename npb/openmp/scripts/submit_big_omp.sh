#!/bin/bash

CLASSES="S A B C"

for CLASS in $CLASSES
do
    echo "Submitting Class $CLASS with 128 OpenMP threads"

    sbatch \
        --partition=ki-parallel \
        --nodes=1 \
        --ntasks=1 \
        --cpus-per-task=128 \
        --time=00:10:00 \
        --job-name="omp${CLASS}-128t" \
        run_openMP.sh "$CLASS"
done

echo
echo "All 128-thread jobs submitted."
