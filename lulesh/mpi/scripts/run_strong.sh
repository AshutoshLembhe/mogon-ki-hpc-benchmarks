#!/bin/bash

#SBATCH --account=ki-mawahpc
#SBATCH --cpus-per-task=1
#SBATCH --hint=nomultithread
#SBATCH --time=02:00:00
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module purge
module load mpi/OpenMPI/5.0.3-GCC-13.3.0

# Mesh size supplied by the submission script
MESH=$1

cd "$SLURM_SUBMIT_DIR/.." || exit 1

echo "=================================="
echo "LULESH strong scaling"
echo "Job ID: $SLURM_JOB_ID"
echo "Node(s): $SLURM_JOB_NODELIST"
echo "MPI ranks: $SLURM_NTASKS"
echo "Local mesh size: $MESH x $MESH x $MESH"
echo "Working directory: $(pwd)"
echo "=================================="

srun ./build/mpi/lulesh2.0 -s "$MESH" -i 100

echo
echo "Strong-scaling job finished."
