#!/bin/bash

# Keep approximately the same number of elements per OpenMP thread.

sbatch --partition=ki-smallcpu \
       --cpus-per-task=1 \
       --job-name=omp-weak-1t \
       run_omp_weak.sh 30

sbatch --partition=ki-smallcpu \
       --cpus-per-task=8 \
       --job-name=omp-weak-8t \
       run_omp_weak.sh 60

sbatch --partition=ki-smallcpu \
       --cpus-per-task=27 \
       --job-name=omp-weak-27t \
       run_omp_weak.sh 90

sbatch --partition=ki-smallcpu \
       --cpus-per-task=64 \
       --job-name=omp-weak-64t \
       run_omp_weak.sh 120

sbatch --partition=ki-parallel \
       --cpus-per-task=128 \
       --job-name=omp-weak-128t \
       run_omp_weak.sh 151

echo "All OpenMP weak-scaling jobs submitted."
