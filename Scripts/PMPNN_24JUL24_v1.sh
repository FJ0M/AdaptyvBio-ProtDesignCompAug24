#!/bin/bash

# SLURM Directives for Resource Allocation (Common to both parts)
#SBATCH --nodes=1           # Number of nodes
#SBATCH --ntasks=1          # Number of tasks
#SBATCH --cpus-per-task=10  # 10 CPUs for each job
#SBATCH --gres=gpu:1        # 1 GPU
#SBATCH --mem=64G           # 64G CPU memory
#SBATCH --mail-type=ALL     # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=phr361@ku.dk  # Email for notifications
#SBATCH --nice              # Nice priority
#SBATCH --time=7-00:00:00   # Time limit (7 days)
#SBATCH --partition=a100    # Partition name
#SBATCH --job-name=pmpnn
#SBATCH --output=slurm-pmpnn-%j.log

set -o errexit # Exit script on errors

module load miniconda/4.12.0
source /opt/software/miniconda/4.12.0/etc/profile.d/conda.sh

# Load conda environment for ProteinMPNN
conda activate mlfold

# Path to ProteinMPNN
protein_mpnn_path=/PATH/TO/ProteinMPNN

# Function to run ProteinMPNN
run_protein_mpnn() {
    local pdb_file=$1
    local output_dir=$2
    local use_soluble_model=$3

    if [ ! -d "${output_dir}" ]; then
        mkdir -p "${output_dir}"
    fi

    cmd="python ${protein_mpnn_path}/protein_mpnn_run.py \
        --pdb_path ${pdb_file} \
        --pdb_path_chains A \
        --out_folder ${output_dir} \
        --num_seq_per_target 4 \
        --sampling_temp 0.1 \
        --seed 37 \
        --batch_size 1"

    if [ "${use_soluble_model}" == "true" ]; then
        cmd+=" --use_soluble_model"
    fi

    echo $cmd
    $cmd
}

# First working directory
WORKDIR=/ProteinDesignCompAug/RF_diff/round1/normal_weights
cd ${WORKDIR}

# Iterate over each PDB file in WORKDIR for normal weights
for pdb_file in "${WORKDIR}"/*.pdb; do
    pdb_basename=$(basename "${pdb_file}" .pdb)
    mkdir -p "${WORKDIR}"/PMPNN
    mkdir -p "${WORKDIR}"/PMPNN/normal_weights_chainA
    output_dir="${WORKDIR}/PMPNN/normal_weights_chainA/${pdb_basename}/"
    run_protein_mpnn "${pdb_file}" "${output_dir}" "false"
done

# Iterate over each PDB file in WORKDIR for soluble weights
for pdb_file in "${WORKDIR}"/*.pdb; do
    pdb_basename=$(basename "${pdb_file}" .pdb)
    mkdir -p "${WORKDIR}"/PMPNN
    mkdir -p "${WORKDIR}"/PMPNN/soluble_weights_chainA
    output_dir="${WORKDIR}/PMPNN/soluble_weights_chainA/${pdb_basename}/"
    run_protein_mpnn "${pdb_file}" "${output_dir}" "true"
done

# Change to another working directory (for beta weights)
WORKDIR=/projects/cpr_sbmm/people/phr361/AntiAntiPhage/Shango/AntiSngA/RF_diff/round1/beta_weights/
cd ${WORKDIR}

# Iterate over each PDB file in WORKDIR for normal weights (beta weights directory)
for pdb_file in "${WORKDIR}"/*.pdb; do
    pdb_basename=$(basename "${pdb_file}" .pdb) 
    mkdir -p "${WORKDIR}"/PMPNN
    mkdir -p "${WORKDIR}"/PMPNN/normal_weights_chainA
    output_dir="${WORKDIR}/PMPNN/normal_weights_chainA/${pdb_basename}/"
    run_protein_mpnn "${pdb_file}" "${output_dir}" "false"
done

# Iterate over each PDB file in WORKDIR for soluble weights (beta weights directory)
for pdb_file in "${WORKDIR}"/*.pdb; do
    pdb_basename=$(basename "${pdb_file}" .pdb)
    mkdir -p "${WORKDIR}"/PMPNN
    mkdir -p "${WORKDIR}"/PMPNN/soluble_weights_chainA
    output_dir="${WORKDIR}/PMPNN/soluble_weights_chainA/${pdb_basename}/"
    run_protein_mpnn "${pdb_file}" "${output_dir}" "true"
done
