#!/bin/bash

### Job script can run on both old cluster and new A100 server

#SBATCH --ntasks=1          
#SBATCH --cpus-per-task=10  # 10 CPUs for each job
#xxx SBATCH --gres=gpu:1    # no GPU needed for MSA
#SBATCH --mem=64G           # 64G CPU memory
#SBATCH --job-name=AFPulldown-array

#SBATCH --time=7-00:00:00   # estimated max running time; adjust it when necessary
#SBATCH --account=cpr_sbmm  # CHANGE to your own group account 
#SBATCH --partition=a100    # Partition name

### output 
#SBATCH -o create_individual_features_slurm-%j.log

### SLURM Array job (run multiple jobs in parallel)
#SBATCH --array=0-100%7     ## run 4 jobs in parallel, in total 10 jobs/sequences as example

#SBATCH --mail-type=ALL           # send email when job ends
#SBATCH --mail-user=phr361@ku.dk  # CHANGE to your own email

set -o errexit # job exit on errors


module load miniconda3/23.5.2
conda activate /projects/cpr_software/apps/condaenvs/23.5.2/AlphaPulldown   # latest version
### CHANGE to your own work directory
WORKDIR=/ProteinDesignCompAug/AlphaPulldown      # where the job output will be stored
FASTADIR=${WORKDIR}/fastas   # where your fastas locate

if [ "${SLURM_NODELIST}" == 'cprgpun01fl' ]; then
    AFDB=/scratch/AF/alphafold-db         # local AF databases on A100 server
else
    AFDB=/projects/cpr_software/apps/databases/alphafold-db  ## NFS AF databases path
fi

## Adapted official example, https://github.com/KosinskiLab/AlphaPulldown/blob/main/manuals/example_1.md
## 294 sequences in example_1_sequnces.fasta, but only test with 10 as example
create_individual_features.py --fasta_paths=${FASTADIR}/wt_trim.fasta,${FASTADIR}/AF_pulldown.fasta  \
			      --data_dir=${AFDB} \
			      --save_msa_files=False \
			      --output_dir=${WORKDIR}/step1-output  \
			      --use_precomputed_msas=False  \
			      --max_template_date=2023-05-01 \
			      --skip_existing=True \
			      --seq_index=${SLURM_ARRAY_TASK_ID}
