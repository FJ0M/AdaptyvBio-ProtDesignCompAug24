#!/bin/bash

############# Hardware resources: ############
#SBATCH --nodes=1           # number of nodes
#SBATCH --ntasks=1          
#SBATCH --cpus-per-task=10  # 10 CPUs for each job
#SBATCH --gres=gpu:1        
#SBATCH --mem=64G           # 64G CPU memory
#SBATCH --account=cpr_sbmm
#SBATCH --array=0-100%4 ###CHANGE HERE###
#SBATCH --nice
#SBATCH --time=7-00:00:00     
#SBATCH --partition=a100    # Partition name

############## Optional #################
#SBATCH --job-name=ESM_eval
#SBATCH --output=slurm-%x-%j.log   ## <job_name>-<job_id>.log
#SBATCH --mail-type=ALL          # send email when job ends
#SBATCH --mail-user=phr361@ku.dk
set -o errexit # job exit on errors

# Load conda environment
module load miniconda3/23.5.2
conda activate /projects/cpr_software/apps/condaenvs/23.5.2/esmfold

fasta_dir='/projects/cpr_sbmm/people/phr361/AntiAntiPhage/ProteinDesignCompAug/att2/RF_normal/all_fastas'
fasta_files=(`ls ${fasta_dir}/`)  ## they will be indexed as 0,1,2,...
fasta_count=${#fasta_files[@]}
echo "Number of fastas = ${fasta_count} "

ESM_dir='/projects/cpr_sbmm/people/phr361/AntiAntiPhage/ProteinDesignCompAug/att2/RF_normal/ESM_outputs'  
mkdir -p ${ESM_dir}

# Calculate the actual task ID considering the offset
actual_task_id=$((${SLURM_ARRAY_TASK_ID} + 1))

if [[ ${actual_task_id} -lt ${fasta_count} ]]
then
    # Set correct fasta file
    fasta_name=${fasta_files[${actual_task_id}]}
    echo "Running job on ${fasta_name} "
    echo "making new directory ${ESM_dir}/${fasta_name%.*}_result/ "

    mkdir -p ${ESM_dir}/${fasta_name%.*}_result/
    # Run one job
    echo python /projects/cpr_software/apps/software-src/esm/scripts/fold.py \
    -i ${fasta_dir}/${fasta_name} \
    -o ${ESM_dir}/${fasta_name%.*}_result/ \
    --max-tokens-per-batch 1024 \
    --num-recycles 4 \
    --chunk-size 32

    python /projects/cpr_software/apps/software-src/esm/scripts/fold.py \
    -i ${fasta_dir}/${fasta_name} \
    -o ${ESM_dir}/${fasta_name%.*}_result/ \
    --max-tokens-per-batch 1024 \
    --num-recycles 4 \
    --chunk-size 32
fi
