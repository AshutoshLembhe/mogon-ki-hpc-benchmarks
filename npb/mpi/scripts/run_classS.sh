#!/bin/bash

#========[requirements]========#
#SBATCH --account=ki-mawahpc
#SBATCH --partition=ki-smallcpu

#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --hint=nomultithread
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err

module purge
module load mpi/OpenMPI/5.0.3-GCC-13.3.0

cd "$SLURM_SUBMIT_DIR/.."

echo "NPB Class S Benchmarks"
echo "job id: $SLURM_JOB_ID"
echo "Node: $SLURM_JOB_NODELIST"
echo "MPI ranks:$SLURM_NTASKS"
echo "working directory: $(pwd)"
echo

echo "Running EP"
mpirun -np "$SLURM_NTASKS" ./bin/ep.S.x

echo "Running CG" 
mpirun -np "$SLURM_NTASKS" ./bin/cg.S.x 

echo "Running FT" 
mpirun -np "$SLURM_NTASKS" ./bin/ft.S.x 

echo "Running MG" 
mpirun -np "$SLURM_NTASKS" ./bin/mg.S.x 

echo "Running IS" 
mpirun -np "$SLURM_NTASKS" ./bin/is.S.x 

echo "Running BT" 
mpirun -np "$SLURM_NTASKS" ./bin/bt.S.x 

echo "Running SP" 
mpirun -np "$SLURM_NTASKS" ./bin/sp.S.x 

echo "Running LU" 
mpirun -np "$SLURM_NTASKS" ./bin/lu.S.x

echo

echo "All class S benchmarks finished"
