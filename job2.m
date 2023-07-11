% List of open inputs
nrun = 6; % enter the number of runs here
jobfile = {'/Users/nina/Documents/Projects/CajalMRI_BIDS/code/job2_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
