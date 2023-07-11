#!/bin/tcsh
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --time=6:00:00
#SBATCH --mem-per-cpu=20G
#SBATCH --array=1-3
#SBATCH --output=/mmfs1/scratch/kurkela/workshop/output/fmriprep_%a.out
#SBATCH --mail-type=end
#SBATCH --mail-user=kurkela@bc.edu

# read in a text file located in the same directory as this file
# called `subjects_to_prep.txt` that has a subject ID on each
# line of the file. Save these subject IDs to an array variable.
# Using the `SLURM_ARRAY_TASK_ID` variable, index into the array
# to select this subject's ID.

set arr=() # initialize empty array variable called `arr`

foreach subid ( `cat subjects_to_prep.txt`) # the bash scripting equivalent of a for loop

 set arr = ($arr $subid) # add the current line of the text file to the end of the array

end

echo $arr[$SLURM_ARRAY_TASK_ID] # prints the subject array ID to console

# full paths to some key directories
set bids_root=/mmfs1/scratch/kurkela/workshop/CajalMRI_BIDS # where the bids formatted data live
set fmriprep_out=/mmfs1/scratch/kurkela/workshop/CajalMRI_BIDS/derivatives/fmriprep # where you want the results to be written
set work=/mmfs1/scratch/kurkela/work # a directory where temporary files are written
set fmriprep_simg=/usr/public/fmriprep/22.0.1/fmriprep.simg # where is the fmriprep singularity image?

# body
module load singularity
module load fmriprep
singularity run -B $bids_root':'$bids_root -B $fmriprep_out':'$fmriprep_out -B $work':'$work -B /scratch/kurkela:/scratch $fmriprep_simg $bids_root $fmriprep_out participant --participant-label $arr[$SLURM_ARRAY_TASK_ID] --fs-license-file /scratch/license.txt --fs-no-reconall --output-spaces MNI152NLin2009cAsym:res-2 -w $work --nprocs 4 --mem_mb 15000
