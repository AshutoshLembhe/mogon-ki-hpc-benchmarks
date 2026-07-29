#!/bin/bash

#======== Slurm requirements ========#
#SBATCH --account=ki-mawahpc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --hint=nomultithread
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

# Load the compiler used to build NPB
module purge
module load compiler/GCC/13.3.0

# Class supplied during submission: S, A, B or C
CLASS=$1

# Move from bashfiles to NPB3.4-OMP
cd "$SLURM_SUBMIT_DIR/.." || exit 1

# Number of OpenMP threads equals CPUs requested from Slurm
export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"
export OMP_PROC_BIND=close
export OMP_PLACES=threads
export OMP_DYNAMIC=false

echo "======================================"
echo "NPB OpenMP Class $CLASS"
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_JOB_NODELIST"
echo "Slurm tasks: $SLURM_NTASKS"
echo "OpenMP threads: $OMP_NUM_THREADS"
echo "Working directory: $(pwd)"
echo "======================================"
echo

for BENCHMARK in ep cg ft mg is bt sp lu
do
    echo "Running ${BENCHMARK}.${CLASS}.x"
    echo "OpenMP threads: $OMP_NUM_THREADS"

    srun "./bin/${BENCHMARK}.${CLASS}.x"

    echo
done

echo "All OpenMP Class $CLASS benchmarks finished."
