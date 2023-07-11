function Cajal_2_BIDS()
% This function converts the Memo Lab's Cajal dataset into BIDS format.
%
% Requires SPM12, MATLAB 2016b

% Where the CajalMRI dataset is currently located
in_dir = '/mmfs1/scratch/kurkela/workshop/CajalMRI';

% Where we will output the BIDS version of the CajalMRI dataset
out_dir = '/mmfs1/scratch/kurkela/workshop/CajalMRI_BIDS';

% Should we overwrite the files? true to overwrite
overwrite = false;

% Create the output directory, if it does not already exist
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

% Recursively select all directories in "in_dir" that have the pattern
% "s##". Return the full path to those subirectories as a cell array of
% strings. See help spm_select for more information.
subjects_array = cellstr(spm_select('FPListRec', in_dir, 'dir', 's[0-9]{2}'));

%% Anatomical Images
% Identify high resolution anatomical images and move them into BIDS format

% prints text to the command window. See help fprintf for more
% information.
fprintf('------Anatomical-----\n\n')

% Recursively select all files in "in_dir" that has "T1" in the file name 
% and ends in ".nii". Return all found files as a cell array of strings.
anat_images = cellstr(spm_select('FPListRec', in_dir, '.*T1.*\.nii'));

% For each subject...
for i_sub = 1:length(subjects_array)

    % Extract Participant Label from the subject sub directory file path.
    % See help fileparts for more information.
    csub_subdirectory = subjects_array{i_sub};
    [~, participant_label] = fileparts(csub_subdirectory);

    % Append "sub-" to the participant_label
    participant_directory = ['sub-' participant_label];

    % create the 'anat' subdirectory if it does not already exist
    if ~exist(fullfile(out_dir, participant_directory, 'anat'), 'dir')
        mkdir(fullfile(out_dir, participant_directory, 'anat'))
    end

    % Anatomical files in BIDS format MUST end in "_T1w" and begin with the
    % subject's ID in the format "sub-SUBJECTID"
    anat_FN_BIDS = ['sub-' participant_label '_T1w.nii'];

    % Destination, BIDS Formatted. The fullfile command automatically adds
    % computer specific file seperators between input arguments.
    anat_dest_BIDS = fullfile(out_dir, participant_directory, 'anat', anat_FN_BIDS);

    % Copy and rename file into BIDS format in destination
    if overwrite
        copyfile(anat_images{i_sub}, anat_dest_BIDS); %#ok<*UNRCH>
    end

    % Give the user feedback on the what file is moving where
    disp([anat_images{i_sub} '  -->'])
    disp(anat_dest_BIDS)
    fprintf('\n')

end

%% Task Images
% Identify all functional scans of the visual perception task. Move them
% into a BIDS format

% prints text to the command window. See help fprintf for more
% information.
fprintf('------Task Images-----\n\n')

% Recursively select all files in "in_dir" that begins with "2016",
% contains "TASK", and ends in ".nii.gz". Return the full path to those
% files as a cell array of strings.
func_images = cellstr(spm_select('FPListRec', in_dir, '^2016.*TASK.*\.nii.gz'));

% for each subject...
for i_sub = 1:length(subjects_array)

    % Extract Participant Label
    csub_subdirectory = subjects_array{i_sub};
    [~, participant_label] = fileparts(csub_subdirectory);

    % Participant Directory in BIDS
    participant_directory  = ['sub-' participant_label];

    % Create the 'func' subdirectory if it does not already exist
    if ~exist(fullfile(out_dir, participant_directory, 'func'), 'dir')
        mkdir(fullfile(out_dir, participant_directory, 'func'))
    end

    % Which files in the func_images array belong to this subject?
    % Search the cell array "func_images" for strings that match the
    % pattern "/participant_label/".
    % See help regexp for more inforamtion.
    matches = regexp(func_images, ['.*/' participant_label '/.*']);
    filter  = ~cellfun('isempty', matches);
    runs_array    = func_images(filter);

    % For each functional run...
    for i_run = 1:length(runs_array)

        % print the Subject and Run Number to the command window
        fprintf(['------Sub-' num2str(i_sub) ' Run-' num2str(i_run) '-----\n\n'])

        % Functional File Name in BIDS. Follows the format
        % "sub-SUBJECTID_task-TASKLABEL_run-RUNLABEL_bold.nii.gz". See the
        % BIDS format documentation for more inforamtion
        func_FN_BIDS = ['sub-' participant_label '_task-TASK_run-' num2str(i_run) '_bold.nii.gz'];

        % Destination, BIDS Formatted
        func_dest_BIDS = fullfile(out_dir, participant_directory, 'func', func_FN_BIDS);

        % Copy and rename file into BIDS format in destination
        if overwrite
            copyfile(runs_array{i_run}, func_dest_BIDS);
        end

        % Give the user feedback on the what file is moving where
        disp([runs_array{i_run} '  -->'])
        disp(func_dest_BIDS)
        fprintf('\n')

    end

end

%% Task Events tsv's
% Load in the behavioral data and reformat it to conform to BIDS format

% print text to the command window
fprintf('------Task Events TSVs-----\n\n')

% Grab Behavioral Data
pth_to_behav_data = spm_select('FPListRec', in_dir, '.*behavdata_merged.*');

% Load Behavioral Data as a MATLAB "table" variable. See help table for
% more information.
BehavData = readtable(pth_to_behav_data);

% Remove the column "Var1". Nonsense column.
BehavData.Var1 = [];

% When participants did not respond on a trial, the computer printed the
% string "NA" to this column. BIDS format REQUIRES all missing data to be
% indicated with the string "n/a".
filter = strcmp(BehavData.famrating, 'NA');
BehavData.famrating(filter) = {'n/a'};

% BIDS format REQUIRES that the first variable in the events tsv file be
% labeled lowercase "onset". Rename the column "onsetTimeTrial" --> "onset"
BehavData.Properties.VariableNames{'onsetTimeTrial'} = 'onset';

% BIDS format REQUIRES that the second column in the events tsv file be
% labeled lowercase "duration". Create a new column "duration" with each
% trial given the duration 1.
BehavData.duration = repmat(2, height(BehavData), 1);

% Reorganize: duration first
varnames = BehavData.Properties.VariableNames;
others   = ~strcmp('duration', varnames);
varnames = ['duration' varnames(others)];
BehavData = BehavData(:,varnames);

% Reorganize: onset first
varnames = BehavData.Properties.VariableNames;
others   = ~strcmp('onset', varnames);
varnames = ['onset' varnames(others)];
BehavData = BehavData(:,varnames);

% identify subjects within the behavioral data
behav_participants = unique(BehavData.participant)';

% for each subject...
for i_sub = 1:length(behav_participants)

    % Extract Participant Label
    [~, participant_label] = fileparts(subjects_array{i_sub});

    % Participant Directory in BIDS
    participant_directory  = ['sub-' participant_label];
    
    % How many unique runs are there for this subject?
    runs_array = unique(BehavData.session(BehavData.participant == behav_participants(i_sub)))';

    % For each functional run...
    for i_run = 1:length(runs_array)

        fprintf(['------Sub-' num2str(i_sub) ' Run-' num2str(i_run) '-----\n\n'])

        % This run's behavioral data
        thisRunBehavData = BehavData(BehavData.participant == behav_participants(i_sub) & BehavData.session == i_run, :); %#ok<*NASGU>

        % Functional File Name in BIDS. See BIDS formating guide.
        % sub-SUBJECTID_task-TASKID_run-RUNID_events.tsv
        func_FN_BIDS = ['sub-' participant_label '_task-TASK_run-' num2str(i_run) '_events.tsv'];

        % Destination, BIDS Formatted
        task_dest_BIDS = fullfile(out_dir, participant_directory, 'func', func_FN_BIDS);

        % Write behav data to file in BIDS format in destination
        if overwrite
            writetable(thisRunBehavData, task_dest_BIDS, 'FileType', 'text', 'Delimiter', '\t');
        end

        % Give the user feedback on where we are writing this new file
        disp(task_dest_BIDS)
        fprintf('\n')

    end

end
    
%% Resting State Images
% Identify all functional scans of the resting state task. Move them
% into a BIDS format

fprintf('------Resting State-----\n\n')

% grab all resting state functional scans
rest_images = cellstr(spm_select('FPListRec', in_dir, '.*RESTING.*\.nii.gz'));

% For each anatomical image...
for i_sub = 1:length(subjects_array')

    % Extract Participant Label
    [~, participant_label] = fileparts(subjects_array{i_sub});

    % Participant Directory in BIDS
    participant_directory = ['sub-' participant_label];

    % Anatomical File Name in BIDS
    rest_FN_BIDS = ['sub-' participant_label '_task-rest_bold.nii.gz'];

    % Destination, BIDS Formatted
    rest_dest_BIDS = fullfile(out_dir, participant_directory, 'func', rest_FN_BIDS);

    % Copy and rename file into BIDS format in destination
    if overwrite
        copyfile(rest_images{i_sub}, rest_dest_BIDS);
    end

    % Give the user feedback on the what file is moving where
    disp([rest_images{i_sub} '  -->'])
    disp(rest_dest_BIDS)
    fprintf('\n')

end

%% JSON Meta-Data
% Create necessary JSON meta-data for the functional scans. BIDS requires
% that you give each functional scan type a descritive task name, the
% repetition time (TR), and the slice timing order. I recieved this
% information for this dataset from @Maureen Ritchey; Automated software
% will automatically extract this information from the raw DICOM images.

% write string to command window
fprintf('------Functional Scan Meta Data-----\n\n')

% The Face-Scene Famous-nonFamous Task basic scanning parameters. Create a
% MATLAB structure variable and use the built in function jsonencode to
% turn it into a JSON string. Write that string to a text file with the
% file extension ".json". See jsonencode for more information.
TaskMetaData.RepetitionTime = 2.1;
%TaskMetaData.SliceTiming    = [0:(2.1/40)*2:(2.1-(2.1/40)) (2.1/40):(2.1/40)*2:2.1];
TaskMetaData.TaskName       = 'Face-Scene Famous-NonFamous Task';
TaskMetaData                = jsonencode(TaskMetaData);
if overwrite
    writeJSON(TaskMetaData, fullfile(out_dir, 'task-TASK_bold.json'));
end

disp(fullfile(out_dir, 'task-TASK_bold.json'))

RestMetaData.RepetitionTime = 2.1;
%RestMetaData.SliceTiming    = [0:(2.1/40)*2:(2.1-(2.1/40)) (2.1/40):(2.1/40)*2:2.1];
RestMetaData.TaskName       = 'Resting State Scan';
RestMetaData                = jsonencode(RestMetaData);
if overwrite
    writeJSON(RestMetaData, fullfile(out_dir, 'task-rest_bold.json'));
end

disp(fullfile(out_dir, 'task-rest_bold.json'))

%% Dataset description file
% generate the required dataset description .json file

% write string to command window
fprintf('\n------Dataset Description Meta Data-----\n\n')

DatasetDescription.Name        = 'CajalMRI';
DatasetDescription.BIDSVersion = 'v1.7.0';
DatasetDescription.Authors     = {'Kyle Kurkela', 'Maureen Ritchey'};
DatasetDescription_txt         = jsonencode(DatasetDescription);
if overwrite
    writeJSON(DatasetDescription_txt, fullfile(out_dir, 'dataset_description.json'))
end
disp(fullfile(out_dir, 'dataset_description.json'))

%% Write an events json. Note: not required, but recommended.

% write string to command window
fprintf('\n------Events Meta Data-----\n\n')

Events.participant.LongName    = 'Participant Number';
Events.participant.Description = 'Numeric identified for this subject';

Events.category.LongName     = 'Stimulus Category';
Events.category.Description  = 'Class of image stimulus presented to participant';
Events.category.Levels.face  = 'A face image.';
Events.category.Levels.scene = 'A scene image.';

Events.gender.LongName        = 'Gender of the face stimulus';
Events.gender.Description     = 'Gender of the face stimulus';
Events.category.Levels.male   = 'male';
Events.category.Levels.female = 'female';
Events.category.Levels.none   = 'Does not apply for scene images';

Events.fame.LongName       = 'Level of Fame';
Events.fame.Description    = 'Is this stimulus famous or not?';
Events.category.Levels.yes = 'Stimulus is famous';
Events.category.Levels.no  = 'Stimulus is not famous';

Events.image_name.LongName    = 'Filename of stimulus image';
Events.image_name.Description = 'Filename of stimulus image';

Events.stim_id.LongName    = 'Arbitrary numeric id assigned to stimulus';
Events.stim_id.Description = 'Arbitrary numeric id assigned to stimulus';

Events.repetition.LongName    = 'Which repetition of stimulus';
Events.repetition.Description = 'Stimuli where each seen twice. Once in the first 3 sessions and again in the second 3 sessions.';

Events.session.LongName    = 'Scan Run Number';
Events.session.Description = 'Scan number in chronological order';

Events.trialnum.LongName    = 'Trial Number';
Events.trialnum.Description = 'Trial number in chronological order';

Events.memrating.LongName    = 'Memory Rating?';
Events.memrating.Description = 'Kyle assumes it is memory for the image, seen before entering scanner?';
Events.memrating.Levels.R    = 'Remember?';
Events.memrating.Levels.F    = 'Familiar?';
Events.memrating.Levels.N    = 'New?';

Events.famrating.LongName    = 'Familiarity Rating';
Events.famrating.Description = 'Kyle assumes it is familiarity with this person/place.';
Events.famrating.Levels.hi   = 'Highly Familiar?';
Events.famrating.Levels.mid  = 'Moderately Familiar?';
Events.famrating.Levels.low  = 'Not Familiar?';

Events_txt         = jsonencode(Events);
if overwrite
    writeJSON(Events_txt, fullfile(out_dir, 'events.json'));
end

disp(fullfile(out_dir, 'events.json'))

%% custom subfunction
function writeJSON(json_string, filename) %#ok<*DEFNU>

    fid = fopen(filename, 'w');
    fwrite(fid, json_string);
    fclose(fid);

end

end
