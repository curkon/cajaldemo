# MRI processing Tutorial README using the CajalMRI Dataset

The present working directory (i.e., the directory that contains this read me) has the following scripts for processing the CajalMRI dataset:

1. `A_Cajal_2_BIDS.m`

-- A MATLAB script (all MATLAB scripts end in .m) containing code for reorganizing the raw CajalMRI data (found here: 
   /scratch/kurkela/workshop/CajalMRI) into BIDS format.

2. `B_mriqc2.sh`

-- A tcsh shell script (shell scripts typically end in .sh. Note: there are different types of shell scripts that use slightly different syntaxes.
   This one uses tcsh syntax; the other common shell scripts use bash syntax.
-- This script is designed to run MRIQC in an interactive shell. It is currently written to analyze all subjects found in a BIDS directory serially
   (i.e., one at a time).

3. `B_mriqc3.sl`, `subjects_to_prep.txt`

- A tcsh shell shell script set up to run MRIQC using the SLURRM Queuing System.
- After the shebang (i.e., the #!/bin/tcsh), contains recommended SLURRM arguments.
- This script requests a job array from SLURRM, with each subject running in parallel
  in a seperately requested job.

4. `C_fmriprep.sl`, `subjects_to_prep.txt`

- A tcsh shell script set to run fmriprep using the SLURRM Queuing System.
- After the sheband (i.e., the #!/bin/tcsh), contains recommended SLURRM arguments.
