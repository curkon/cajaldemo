#!/bin/tcsh
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --time=08:00:00  # Time limit hrs:min:sec
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-3
#SBATCH --output=/path/to/where/you/want/your/output/logfiles/optcode_%a.out
#SBATCH --mail-type=end
#SBATCH --mail-user=yourusername@bc.edu

# initialze an array variable called `arr`
# This will have an entry for each subject that
# you want to run.
set arr=()

# Assumes you have a text file in the same directory as this script
# called `subjects_to_prep.txt`. Each line of this text file contains
# a subject ID that you would like to run.
foreach subid ( `cat subjects_to_prep.txt`)

 set arr = ($arr $subid)

end

# print this entry in the array `arr` to the console
echo $arr[$SLURM_ARRAY_TASK_ID]

# create a set of variables to be used as input arguments to the
# call to the mriqc singularity container
set bids_root=/mmfs1/data/kurkela/Desktop/CamCan/rawdata
set mriqc_out=/mmfs1/data/kurkela/Desktop/CamCan/derivatives/mriqc
set work=/mmfs1/data/kurkela/Desktop/CamCan/derivatives/mriqc/work
set mriqc_img=/usr/public/mriqc/22.0.6/mriqc.simg

# make sure the software packages "singularity" it loaded
module load singularity

# the long complicated call to singularity/mriqc.
# singularity runs a singularity image -- a virtual machine designed
# to run a software package.
singularity run -B $bids_root':'$bids_root \
-B $mriqc_out':'$mriqc_out \
-B $work':'$work mriqc-0.15.1 \
$bids_root $mriqc_out \
participant --participant-label $arr[$SLURM_ARRAY_TASK_ID] \
--n_proc 4 --fd_thres 0.2 --mem_gb 8 -w $work
