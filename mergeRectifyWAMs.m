%% Housekeeping         
close all
clear all

%% Add Function Paths and Directories
cd 'E:\'

addpath(genpath('E:\Hawaii_Codes'))

hdir='E:\MINI_ARGUS\Mini_Argus_Data';
sdir='SBA';

%% Condition Information
%Time
tvec=datenum(2021,1,4,22,11,0):1:datenum(2021,1,31,22,11,0);

%% Load Grid (For coordinate rotation)
gname='cxa';
load(fullfile([sdir '_' gname '_grid.mat'])); %hdir,sdir,'supportingData','Grids',

%% Load and rectify WAMs at each time in tvec
for t_ind = 1:length(tvec)
    t = tvec(t_ind);
    
    %% Get Water Level
    [eta_tide, eta_runup, eta_total]=waterLevelPredict(t,hdir,sdir,'runupDissipative');
    localZ = localZ+eta_total;

    %% Loop through and load each WAM
    for c=1:4
        cam = num2str((c+4));
        wamfiles = getRasWAMFileList(t,cam,sdir,hdir,1);

        % Get extrinsics for  current camera, transform to local
        %[Extrinsics, Intrinsics] = getVaryingExtrinsics(hdir,sdir,cam,t);
        efile=['E:\MINI_ARGUS\Mini_Argus_Data\SBA\supportingData\Extrinsics\1605830400.v1.SBA.c' cam '.Extrinsics.mat'];
        load(efile)
        extrinsicsOut{c} = localTransformExtrinsics(localOrigin,localAngle,1,extrinsics);
        intrinsicsOut{c} = intrinsics;

        % Load videos, rectify and merge frames
        % Read WAM File
        try
            v = VideoReader(fullfile(wamfiles{1}));
            frames{c} = read(v);
            len(c) = v.NumberofFrames; %Change to 'NumFrames' if using newer version of MATLAB
        catch
            warning('File does not exist.');
        end
    end

    %% Video Writer Object

    % Output .mp4 file
    dt=datetime(datevec(t));
    et=24*3600.*(t-datenum(1970,1,1));
    dow=day(dt,'shortname');
    istring=datestr(t,'mmm.dd_HH_MM_SS');
    doy=day(dt,'dayofyear');
    outfile = strcat(hdir, '\SBA\Raw_Data\2021\cxa\', num2str(et), '.', dow, '.', istring, '.GMT.2021.SBA.wam.mp4');

    %% Merge and Rectify
    try
        v_write = VideoWriter(outfile{1},'MPEG-4');
        open(v_write)
        for i=1:min(len)
            for j = 1:4
                curr_frames{j} = frames{1,j}(:,:,:,i);
            end
            Ir{i}= imageRectifier(curr_frames,intrinsicsOut,extrinsicsOut,localX,localY,localZ,0);
            writeVideo(v_write,Ir{i})
        end
        close(v_write)
    catch
        warning('Previous file error, cannot rectify')
    end
end


