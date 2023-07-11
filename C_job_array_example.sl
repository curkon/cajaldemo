#!/bin/tcsh
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --time=1:00:00
#SBATCH --mem-per-cpu=2G
#SBATCH --array=1-3
#SBATCH --output=/mmfs1/scratch/kurkela/workshop/output/optcode_%a.out
#SBATCH --mail-type=end
#SBATCH --mail-user=kurkela@bc.edu
#SBATCH --job-name=TestJobArray

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

echo "Yeah! We did it!"

sleep 30 # stops the bash script for 30 seconds
