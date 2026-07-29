#!/bin/bash

# Partial-node jobs
sbatch --partition=ki-smallcpu --nodes=1 --ntasks=1  \
       --job-name=weak-1r run_weak.sh

sbatch --partition=ki-smallcpu --nodes=1 --ntasks=8  \
       --job-name=weak-8r run_weak.sh

sbatch --partition=ki-smallcpu --nodes=1 --ntasks=27 \
       --job-name=weak-27r run_weak.sh

sbatch --partition=ki-smallcpu --nodes=1 --ntasks=64 \
       --job-name=weak-64r run_weak.sh

# Full-node jobs
sbatch --partition=ki-parallel --nodes=1 --ntasks=125 \
       --job-name=weak-125r run_weak.sh

sbatch --partition=ki-parallel --nodes=2 --ntasks=216 \
       --job-name=weak-216r run_weak.sh

echo "All weak-scaling jobs submitted."
