#!/bin/bash

#SBATCH --job-name=io500-debug
#SBATCH --account=ki-mawahpc
#SBATCH --partition=ki-smallcpu

#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00

#SBATCH --output=io500-debug-%j.out
#SBATCH --error=io500-debug-%j.err


# -------------------------------
# Load the MPI environment
# -------------------------------

module purge
module load mpi/OpenMPI/5.0.3-GCC-13.3.0


# -------------------------------
# Main IO500 directories
# -------------------------------

IO500_REPO="$HOME/io500/source/io500"
IO500_HOME="$HOME/io500"

# Replace this with your real writable Lustre directory
IO500_LUSTRE="/lustre/project/ki-mawahpc/ashutoshio500"


# -------------------------------
# Unique directories for this job
# -------------------------------

RUN_DATA="${IO500_LUSTRE}/io500-debug-${SLURM_JOB_ID}"
RUN_RESULTS="${IO500_HOME}/results/io500-debug-${SLURM_JOB_ID}"
RUN_CONFIG="${IO500_HOME}/config/io500-debug-${SLURM_JOB_ID}.ini"

mkdir -p "$RUN_DATA"
mkdir -p "$RUN_DATA/pause"
mkdir -p "$RUN_RESULTS"
mkdir -p "$IO500_HOME/config"


# -------------------------------
# Create the IO500 configuration
# -------------------------------

cat > "$RUN_CONFIG" <<EOF
[global]
datadir = ${RUN_DATA}/datafiles
resultdir = ${RUN_RESULTS}
timestamp-datadir = FALSE
timestamp-resultdir = FALSE

[debug]
stonewall-time = 1
pause-dir = ${RUN_DATA}/pause
EOF


# -------------------------------
# Print job information
# -------------------------------

echo "========================================"
echo "IO500 debug run"
echo "========================================"
echo "Job ID:             $SLURM_JOB_ID"
echo "Node:               $SLURM_JOB_NODELIST"
echo "MPI ranks:          $SLURM_NTASKS"
echo "Repository:         $IO500_REPO"
echo "Lustre data:        $RUN_DATA"
echo "Results directory:  $RUN_RESULTS"
echo "Configuration:      $RUN_CONFIG"
echo "========================================"

module list
echo


# -------------------------------
# Run IO500
# -------------------------------

cd "$IO500_REPO"

mpirun -np "$SLURM_NTASKS" ./io500 "$RUN_CONFIG"

IO500_STATUS=$?

echo
echo "IO500 return code: $IO500_STATUS"
echo "Results stored in: $RUN_RESULTS"
echo "Test data stored in: $RUN_DATA"

exit "$IO500_STATUS"
