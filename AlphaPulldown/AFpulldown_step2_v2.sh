#!/bin/bash

### Job script can run on both old cluster and new A100 serve

#SBATCH --ntasks=1          
#SBATCH --cpus-per-task=10  # 10 CPUs for each job
#SBATCH --gres=gpu:1        # 1 GPU  
#SBATCH --mem=64G           # 64G CPU memory
#SBATCH --job-name=AFPulldown-array

#SBATCH --time=7-00:00:00   # estimated max running time; adjust it when necessary
#SBATCH --account=cpr_sbmm  # CHANGE to your own group account 

#SBATCH -o example1-step2_slurm-%j.log
#SBATCH --partition=a100    # Partition name

### SLURM Array job (run multiple jobs in parallel)
#SBATCH --array=0-100%7     ## run 4 jobs in parallel, in total 10 jobs/sequences as example
#SBATCH --begin=now+12hours
#SBATCH --mail-type=ALL           # send email when job ends
#SBATCH --mail-user=phr361@ku.dk  # CHANGE to your own email

set -o errexit # job exit on errors

module load miniconda3/23.5.2
conda activate /projects/cpr_software/apps/condaenvs/23.5.2/AlphaPulldown   # latest version


### CHANGE to your own work directory
WORKDIR=/projects/cpr_sbmm/people/phr361/AntiAntiPhage/ProteinDesignCompAug/AlphaPulldown      # where the job output will be stored
FASTADIR=${WORKDIR}/fastas   # where your fastas locate

if [ "${SLURM_NODELIST}" == 'cprgpun01fl' ]; then
    AFDB=/scratch/AF/alphafold-db         # local AF databases on A100 server
else
    AFDB=/projects/cpr_software/apps/databases/alphafold-db  ## NFS AF databases path
fi


## Adapted official example, step 2: https://github.com/KosinskiLab/AlphaPulldown/blob/main/manuals/example_1.md
## test only 10 jobs as example
run_multimer_jobs.py --mode=pulldown \
    --num_cycle=3 \
    --num_predictions_per_model=1 \
    --output_path=${WORKDIR}/step2-models \
    --data_dir=${AFDB} \
    --protein_lists=${FASTADIR}/SngA_trim.txt,${FASTADIR}/AF_pulldown.txt \
    --monomer_objects_dir=${WORKDIR}/step1-output \
    --job_index=${SLURM_ARRAY_TASK_ID}

