% demo Kalman filter process using a one day set of cBathy results

clear
cBInputPn = 'E:\MINI_ARGUS\Mini_Argus_Data\SBA\Raw_Data\2021\Bathys\CurrentAnalysis\';     % a simple example day, stored locally
fns = dir([cBInputPn,'*11_00.GMT.2021.SBA.bathy.mat']);

H = 1;            % assume wave height is 1 m if absence of better data

 %% Make Directory for Output
% 
% cBOutputPn = 'Bathys\Jan13';
% if ~exist(cBOutputPn, 'dir')
%     yesNo = mkdir(cBOutputPn);
%     if ~yesNo
%         error('Unable to create output directory')
%     end
% end

%% Kalman Filter

% load('noaa_bathy_workspace.mat')

% % Load the first bathy structure
load([cBInputPn, fns(1).name])
splitname = split(fns(1).name,".");
bathy.epoch = splitname{1};
% 
% % Initialize prior bathy
priorBathy = bathy;
cnt=0;
for i = 2: length(fns)
    % Load bathy 
    load([cBInputPn, fns(i).name])
    splitname = split(fns(i).name,".");
    bathy.epoch = splitname{1};
    
    % Apply Filter 
    if (length(bathy.xm)==91)&&(length(bathy.ym)==181)
        bathy = KalmanFilterBathyNotCIL(priorBathy, bathy, H);
        
        cnt=cnt+1;
        disp(cnt)

        % Save prior bathy
        priorBathy = bathy;
    end
end
%%
eval(['save ' ,'Jan12to17_AnyHour_KalmanFilter', ' bathy'])
%% Plots intermediate smoothed bathys if you save them
% fns = dir([cBOutputPn,filesep,'*.mat']);
% 
% for i = 1: length(fns)
%    load([cBOutputPn, filesep, fns(i).name])
%    plotBathyCollectKalman(bathy)
%    pause(2)
% end

%%
figure
bathy.epoch = '0';
plotBathyCollect(bathy)

%%
h2 = bathy.fCombined.h;
threshErr = 2;
h2(bathy.fCombined.hErr>threshErr) = NaN;
imagesc(bathy.xm,bathy.ym,-h2); grid on
axis xy; xlabel('x (m)'); ylabel('y (m)'); 
title(['cBathy Result with Error Threshold herr=2']) %, ' datestr(epoch2Matlab(str2num(bathy.epoch)))])
colorbar