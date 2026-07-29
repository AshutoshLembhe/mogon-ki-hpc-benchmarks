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

# Fixed global mesh for strong scaling
MESH=120

cd "$SLURM_SUBMIT_DIR/.." || exit 1

export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"
export OMP_PLACES=cores
export OMP_PROC_BIND=close
export OMP_DYNAMIC=false

echo "=================================="
echo "LULESH OpenMP strong scaling"
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $SLURM_JOB_NODELIST"
echo "Slurm tasks: $SLURM_NTASKS"
echo "OpenMP threads: $OMP_NUM_THREADS"
echo "Fixed mesh size: $MESH x $MESH x $MESH"
echo "Working directory: $(pwd)"
echo "=================================="

srun ./build/openmp/lulesh2.0 \
     -s "$MESH" \
     -i 100

echo
echo "OpenMP strong-scaling job finished."
