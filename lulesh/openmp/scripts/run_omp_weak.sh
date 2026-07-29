#!/bin/bash

#SBATCH --account=ki-mawahpc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --hint=nomultithread
#SBATCH --time=02:00:00
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module purge
module load compiler/GCC/13.3.0

# Mesh size supplied by the submission script
MESH=$1

# Move from bashfiles to the LULESH source directory
cd "$SLURM_SUBMIT_DIR/.." || exit 1

# Number of OpenMP threads equals CPUs requested from Slurm
export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"
export OMP_PLACES=cores
export OMP_PROC_BIND=close
export OMP_DYNAMIC=false

echo "=================================="
echo "LULESH OpenMP weak scaling"
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_JOB_NODELIST"
echo "Slurm tasks: $SLURM_NTASKS"
echo "OpenMP threads: $OMP_NUM_THREADS"
echo "Mesh size: $MESH x $MESH x $MESH"
echo "Working directory: $(pwd)"
echo "=================================="

srun ./build/openmp/lulesh2.0 \
     -s "$MESH" \
     -i 100

echo
echo "OpenMP weak-scaling job finished."
