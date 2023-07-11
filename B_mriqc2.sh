#!/bin/tcsh

# script for running all mriqc interactively (i.e., using an interactive node)
# and serirally (i.e., one subject at a time).
# By not setting a participant input argument, mriqc defaults to running all
# subjects that it finds in the BIDS formatted directory

# parameters
set bids_root=/mmfs1/scratch/kurkela/workshop/CajalMRI_BIDS
set mriqc_out=/mmfs1/scratch/kurkela/workshop/CajalMRI_BIDS/derivatives/mriqc
set work=/mmfs1/scratch/kurkela/work
set mriqc_img = /usr/public/mriqc/22.0.6/mriqc.simg

# body
# Notes:
#  - The n_proc = 4 should match the number of cpus-per-process that you request
#    in your interactive node. I.e., #SBATCH -n 4.
#  - The mem_gb = 8 should match the amount of memory that you request per process
#    in your interactive node. I.e., #SBATCH --mem-per-cpu=8G
module load singularity
module load mriqc
cd /scratch/kurkela/workshop/CajalMRI_BIDS/code/
singularity run -B $bids_root':'$bids_root -B $mriqc_out':'$mriqc_out -B $work':'$work $mriqc_img $bids_root $mriqc_out participant --n_proc 4 --fd_thres 0.2 --mem_gb 8 -w $work
