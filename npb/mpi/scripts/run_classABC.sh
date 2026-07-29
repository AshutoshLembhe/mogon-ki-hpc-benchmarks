#!/bin/bash

#======== Slurm requirements ========#
#SBATCH --account=ki-mawahpc
#SBATCH --cpus-per-task=1
#SBATCH --hint=nomultithread
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module purge
module load mpi/OpenMPI/5.0.3-GCC-13.3.0

# Class is provided during submission: A, B or C
CLASS=$1

# Move from bashfiles to NPB3.4-MPI
cd "$SLURM_SUBMIT_DIR/.." || exit 1

echo "========================================"
echo "NPB Class $CLASS Benchmarks"
echo "Job ID: $SLURM_JOB_ID"
echo "Node(s): $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_NNODES"
echo "MPI ranks: $SLURM_NTASKS"
echo "CPUs per MPI rank: $SLURM_CPUS_PER_TASK"
echo "Working directory: $(pwd)"
echo "Date: $(date)"
echo "========================================"
echo

echo "Running EP Class $CLASS"
mpirun -np "$SLURM_NTASKS" ./bin/ep.${CLASS}.x

echo "Running CG Class $CLASS"
mpirun -np "$SLURM_NTASKS" ./bin/cg.${CLASS}.x

echo "Running FT Class $CLASS"
mpirun -np "$SLURM_NTASKS" ./bin/ft.${CLASS}.x

echo "Running MG Class $CLASS"
mpirun -np "$SLURM_NTASKS" ./bin/mg.${CLASS}.x

echo "Running IS Class $CLASS"
mpirun -np "$SLURM_NTASKS" ./bin/is.${CLASS}.x

# BT and SP require a square number of MPI ranks.
# Therefore, skip them when using 128 ranks.
if [ "$SLURM_NTASKS" -ne 128 ]
then
    echo "Running BT Class $CLASS"
    mpirun -np "$SLURM_NTASKS" ./bin/bt.${CLASS}.x

    echo "Running SP Class $CLASS"
    mpirun -np "$SLURM_NTASKS" ./bin/sp.${CLASS}.x
else
    echo "Skipping BT at 128 ranks"
    echo "Skipping SP at 128 ranks"
fi

echo "Running LU Class $CLASS"
mpirun -np "$SLURM_NTASKS" ./bin/lu.${CLASS}.x

echo
echo "========================================"
echo "NPB Class $CLASS job finished"
echo "Finish time: $(date)"
echo "========================================"