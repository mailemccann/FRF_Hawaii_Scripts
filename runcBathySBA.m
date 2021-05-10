close all
clear all

%% Load in Grid/ map
hdir = 'E:\MINI_ARGUS\Mini_Argus_Data';
sdir = 'SBA';
load('E:\MINI_ARGUS\Mini_Argus_Data\SBA\supportingData\Extrinsics\Grids\SBA_cxa_grid.mat')

%% Read in TimeStack
% hrs = [19,20,21,22,23];
cnum = [5,6,7,8];
t1 = datenum(2021,1,13,0,11,0):(1/24):datenum(2021,1,16,0,11,0);
%t2 = datenum(2021,1,1,23,11,0):1:datenum(2021,1,31,23,11,0);
t = [t1];% t2];
for i=1:length(cnum)
    snames{i} = getRasWAMFileList(t,cnum(i),sdir,hdir,0);
end

%%

for ind = 2:length(t)
    %% Set up time strings for file loading
%     curr_hr = hrs(hr_ind);
    tn = t(ind);
    et=24*3600.*(tn-datenum(1970,1,1));

    
    %% Plot UVd
%     iname= 'D:\MINI_ARGUS\Mini_Argus_Data\SBA\Raw_Data\2021\c6\023_Jan.23\1611367200.Sat.Jan.23_02_00_00.GMT.2021.SBA.c6.snap.jpg';
%     imshow(iname)
%     hold on
%     plot(p.U,p.V,'*')

    %% Combine Data
    for c=5:8
        
        fname = snames{1,c-4}{ind,1};
        
%         ['E:\MINI_ARGUS\Mini_Argus_Data\SBA\Raw_Data\2021\c' num2str(c) '\024_Jan.24\', num2str(et), ...
%                 '.Sun.Jan.24_', num2str(hrstring), '.GMT.2021.SBA.c' num2str(c) '.stack.ras'];
        try
            [p, epoch, MSC, curr_data] = loadStackFile(fname);

            efile=['E:\MINI_ARGUS\Mini_Argus_Data\SBA\supportingData\Extrinsics\1605830400.v1.SBA.c' num2str(c) '.Extrinsics.mat'];
            load(efile)
            [extrinsicsOut] = localTransformExtrinsics(localOrigin,localAngle,1,extrinsics);
            curr_xyz = distUV2XYZ(intrinsics,extrinsicsOut,[p.U p.V]','z',p.U'.*0);

            if c==5
                xyz = curr_xyz;
                data = curr_data;
            else
                xyz = [xyz; curr_xyz];
                data = [data, curr_data];
            end
        catch 
            warning(['File does not exist for  ' fname])
        end
    end

    % k=10;
    % figure
    % colormap(gray)
    % caxis([0 255])
    % for k=1
    % scatter(xyz(:,1),xyz(:,2),40,data(k,:),'filled')
    % end

    %%
    %%% Site-specific Inputs
    params.stationStr = 'argus02b';
    params.dxm = 10;                    % analysis domain spacing in x
    params.dym = 10;                    % analysis domain spacing in y
    params.xyMinMax = [100 1000 0 1800];   % min, max of x, then y
                                        % default to [] for cBathy to choose
    params.tideFunction = 'cBathyTide';  % tide level function for evel

    %%%%%%%   Power user settings from here down   %%%%%%%
    params.MINDEPTH = 0.25;             % for initialization and final QC
    params.QTOL = 0.5;                  % reject skill below this in csm
    params.minLam = 10;                 % min normalized eigenvalue to proceed
    params.Lx = 5*params.dxm;           % tomographic domain smoothing
    params.Ly = 5*params.dym;           % 
    params.kappa0 = 5;                  % increase in smoothing at outer xm
    params.DECIMATE = 1;                % decimate pixels to reduce work load.
    params.maxNPix = 80;                % max num pixels per tile (decimate excess)
    params.minValsForBathyEst = 4; 

    % f-domain etc.
    params.fB = [1/30: 1/50: 1/4]; % frequencies for analysis (~40 dof)
    params.nKeep = 4;                   % number of frequencies to keep

    % debugging options
    params.debug.production = 0;
    params.debug.DOPLOTSTACKANDPHASEMAPS = 0;  % top level debug of phase
    params.debug.DOSHOWPROGRESS = 1;   % show progress of tiles
    params.debug.DOPLOTPHASETILE = 0;   % observed and EOF results per pt
    params.debug.TRANSECTX = 200;   % for plotStacksAndPhaseMaps
    params.debug.TRANSECTY = 900;   % for plotStacksAndPhaseMaps

    % default offshore wave angle.  For search seeds.
    params.offshoreRadCCWFromx = 0;

    % choose method for non-linear fit
    params.nlinfit=1;                    %       1 = use Matlab Statistics and computer vision

    %% Run cBathy
    bathy.params=params;
    bathy = analyzeBathyCollect(xyz, epoch, data, data(1,:).*0+1, bathy)

    %% Save bathy structure
    dt=datetime(datevec(tn));
        
    dow=day(dt,'shortname');
    istring=datestr(tn,'mmm.dd_HH_MM_SS');
       
    b= strcat(num2str(et), '.', dow, '.', istring, '.GMT.2021.SBA.bathy.mat');
    bname = strcat('E:\MINI_ARGUS\Mini_Argus_Data\SBA\Raw_Data\2021\Bathys\', b);
    save(bname{1},'bathy')

    %% Cbathy code to plot bathy collect against hError
    figure
    bathy.epoch = num2str(epoch(1));
    plotBathyCollect(bathy)
end

% %% Remove results with HErr greater than a threshold and plot cBathy results
% figure
% subplot(132)
% h2 = bathy.fCombined.h;
% threshErr = 2;
% h2(bathy.fCombined.hErr>threshErr) = NaN;
% imagesc(bathy.xm,bathy.ym,-h2); grid on
% caxis([-8 1])
% axis xy; xlabel('x (m)'); ylabel('y (m)'); 
% title(['cBathy Result with Error Threshold herr=2']) %, ' datestr(epoch2Matlab(str2num(bathy.epoch)))])
% colorbar