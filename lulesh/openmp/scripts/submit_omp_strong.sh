#!/bin/bash

# Fixed mesh: 120 x 120 x 120

sbatch --partition=ki-smallcpu \
       --cpus-per-task=1 \
       --job-name=omp-strong-1t \
       run_omp_strong.sh

sbatch --partition=ki-smallcpu \
       --cpus-per-task=8 \
       --job-name=omp-strong-8t \
       run_omp_strong.sh

sbatch --partition=ki-smallcpu \
       --cpus-per-task=27 \
       --job-name=omp-strong-27t \
       run_omp_strong.sh

sbatch --partition=ki-smallcpu \
       --cpus-per-task=64 \
       --job-name=omp-strong-64t \
       run_omp_strong.sh

sbatch --partition=ki-parallel \
       --cpus-per-task=128 \
       --job-name=omp-strong-128t \
       run_omp_strong.sh

echo "All OpenMP strong-scaling jobs submitted."
