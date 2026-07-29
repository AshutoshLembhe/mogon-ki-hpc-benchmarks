#!/bin/bash

# Global mesh remains approximately 120 x 120 x 120

sbatch --partition=ki-smallcpu --nodes=1 --ntasks=1 \
       --job-name=strong-1r run_strong.sh 120

sbatch --partition=ki-smallcpu --nodes=1 --ntasks=8 \
       --job-name=strong-8r run_strong.sh 60

sbatch --partition=ki-smallcpu --nodes=1 --ntasks=27 \
       --job-name=strong-27r run_strong.sh 40

sbatch --partition=ki-smallcpu --nodes=1 --ntasks=64 \
       --job-name=strong-64r run_strong.sh 30

sbatch --partition=ki-parallel --nodes=1 --ntasks=125 \
       --job-name=strong-125r run_strong.sh 24

sbatch --partition=ki-parallel --nodes=2 --ntasks=216 \
       --job-name=strong-216r run_strong.sh 20

echo "All strong-scaling jobs submitted."
