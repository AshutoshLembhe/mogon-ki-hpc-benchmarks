#!/bin/bash

#SBATCH --account=ki-mawahpc
#SBATCH --cpus-per-task=1
#SBATCH --hint=nomultithread
#SBATCH --time=02:00:00
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module purge
module load mpi/OpenMPI/5.0.3-GCC-13.3.0

# Move from bashfiles to the source directory
cd "$SLURM_SUBMIT_DIR/.." || exit 1

echo "=================================="
echo "LULESH weak scaling"
echo "Job ID: $SLURM_JOB_ID"
echo "Node(s): $SLURM_JOB_NODELIST"
echo "MPI ranks: $SLURM_NTASKS"
echo "Local mesh size: 30 x 30 x 30"
echo "Working directory: $(pwd)"
echo "=================================="

srun ./build/mpi/lulesh2.0 -s 30 -i 100

echo
echo "Weak-scaling job finished."
