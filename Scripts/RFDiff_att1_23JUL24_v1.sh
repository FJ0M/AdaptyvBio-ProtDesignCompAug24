#!/bin/bash

# SLURM Directives for Resource Allocation (Common to both parts)
#SBATCH --nodes=1           # number of nodes
#SBATCH --ntasks=1          # number of tasks
#SBATCH --cpus-per-task=10  # 10 CPUs for each job
#SBATCH --gres=gpu:1        # 1 GPU
#SBATCH --mem=64G           # 64G CPU memory
#SBATCH --mail-type=ALL
#SBATCH --mail-user=phr361@ku.dk
#SBATCH --nice
#SBATCH --time=7-00:00:00   # time limit: 7 days
#SBATCH --partition=a100    # specify the partition if submitting on cprome cluster

# Job details
#SBATCH --job-name=RFdiff
#SBATCH --output=slurm-RFdiff-%j.log

set -o errexit # job exit on errors

# Load conda environment for RFdiffusion
ml miniconda3/23.5.2
conda activate /projects/cpr_software/apps/condaenvs/23.5.2/SE3nv

# Define input and working directory
WORKDIR=/ProteinDesignCompAug
INPUT_PDB=${WORKDIR}/wt/6aru.pdb
RFdiff_path=/projects/cpr_software/apps/software-src/RFdiffusion/scripts/run_inference.py
RFdiff_beta_model_path=/projects/cpr_software/apps/software-src/RFdiffusion/models/Complex_beta_ckpt.pt
mkdir -p ${WORKDIR}/RF_diff/
mkdir -p ${WORKDIR}/RF_diff/round1/
# Create necessary directories
mkdir -p ${WORKDIR}/RF_diff/round1/beta_weights
mkdir -p ${WORKDIR}/RF_diff/round1/normal_weights
# Part 1: Protein Backbone Generation


# ATP Binders with Beta Weights
RESULTS_DIR=${WORKDIR}/RF_diff/round1/beta_weights/
cd ${RESULTS_DIR}
"${RFdiff_path}" inference.output_prefix="${RESULTS_DIR}" inference.input_pdb="${INPUT_PDB}" \
    inference.ckpt_override_path="${RFdiff_beta_model_path}" \
    'contigmap.contigs=[A311-501/0  150-200]' \
    'ppi.hotspot_res=[A316,A325,A346,A348,A350,A363,A380,A382,A412,A417,A438,A467]' \
    inference.num_designs=50 denoiser.noise_scale_ca=0 denoiser.noise_scale_frame=0 \
    

# ATP Binders with Normal Weights
RESULTS_DIR=${WORKDIR}/RF_diff/round1/normal_weights/
cd ${RESULTS_DIR}
"${RFdiff_path}" inference.output_prefix="${RESULTS_DIR}" inference.input_pdb="${INPUT_PDB}" \
    'contigmap.contigs=[A311-501/0  150-200]' \
    'ppi.hotspot_res=[A316,A325,A346,A348,A350,A363,A380,A382,A412,A417,A438,A467]' \
    inference.num_designs=50 denoiser.noise_scale_ca=0 denoiser.noise_scale_frame=0 \
