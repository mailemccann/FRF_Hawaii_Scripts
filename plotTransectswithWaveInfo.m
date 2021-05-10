%% Function Description
%  Pulls Water Total Water Level Estimates to try and find times where
%  water has consistent elevation for shoreline comparison.
close all
clear all


%% Add Function Paths
addpath(genpath('D:\Hawaii_Codes\WaterLevelDetermination'))
addpath(genpath('D:\Hawaii_Codes\CIRN-Quantitative-Coastal-Imaging-Toolbox2\X_CoreFunctions'))


%% Add Directories
hdir='D:\MINI_ARGUS\Mini_Argus_Data\';
sdir='SBB';

%% Cameras You Want to use
cnum=[6 ];

% Local Coordinate system
gname='cxa';

%% Condition Information
%Time
t=datenum(2020,1,1,22,0,0):1:datenum(2020,12,31,22,0,0);


%% Pick Type To Display
Ityp='bright'; %, 'var','timex','snap','dark','rundark'};
Itypsec=[3];


%% Get Water Level
for k=1:length(t)
[eta_tide(k), eta_runup(k),  eta_total(k), Ho(k), To(k), WD(k)]=waterLevelPredict(t(k),hdir,sdir,'runupDissipative');
end

%% Load extrinsics, image files
[Extrinsics, Intrinsics] = getVaryingExtrinsics(hdir,sdir,cnum,t);
Iname = getImageFileList(t,cnum,hdir,sdir,Ityp,Itypsec);

%% Load Grid (For coordinate rotation)
load(fullfile([sdir '_' gname '_grid.mat'])); %hdir,sdir,'supportingData','Grids',
Z=Z+1.5;
localZ=localZ+1.5;

%% Create Pixel Instrument Grid

xi{1}=0:.1:150;
yi{1}=xi{1}.*0+347;

xi{2}=0:.1:150;
yi{2}=xi{2}.*0+425;

xi{3}=-50:.5:100;
yi{3}=xi{3}.*0+749;

xi{4}=-50:.5:120;
yi{4}=xi{4}.*0+900;

xi{5}=0:.5:150;
yi{5}=xi{5}.*0+1050;
    

%% Cut Grid

ind2=(100:10:length(localX(1,:)));
ind1=(1:10:length(localY(:,1)));

localZ=localZ(ind1,ind2);
localX=localX(ind1,ind2);
localY=localY(ind1,ind2);


%% %% Load Image and Plot

ir = cell(length(xi),1);
load('ImSize.mat')
I = cell(length(Iname),1);
xi=linspace(25,50);
yi=linspace(1150,750);
k=1;
%for k=1:length(xi)
    for j = 1:length(Iname)
        if k ==1
            imchar = convertStringsToChars(Iname{j});
            E{j}=localTransformExtrinsics(localOrigin,localAngle,1,Extrinsics{j});
            try
                I{j}=imread(imchar);
            catch
                warning('File does not exist.');
                I{j}=zeros(s(1),s(2),s(3));
            end
        end
        %xyz=cat(2,xi{k}',yi{k}',xi{k}'.*0+eta_total(k));
        xyz=cat(2,xi',yi',xi'.*0+eta_total(1));
        [UVd, flag] = xyz2DistUV(Intrinsics{j,1},E{j},xyz);
        UVd=reshape(UVd,[],2);
        UVd(flag==0)=nan;
        tpix= getPixels(I{j},UVd);
        ir{k}{:,j} = tpix;

        % Include pixels if image was able to be read
%         if sum(tpix) ~= 0
        imout(:,j) = tpix;
%             ind = ind+1;
%         end
    end
%     imcell = imout(any(imout,2),:);  
%     xcell = xi(any(imout,2));
%     clear imout
%end       

%% Plot
% for ind=1 %:5
% close all
f1=figure;
hold on

tplt = tiledlayout(3,4,'TileSpacing','tight');
title(tplt,['SBB Transect at 22:00 GMT (12:00 HST)']) %' num2str(ind) ' (y = ' num2str(yi(1)) 'm) 

nexttile(1,[1 3])
% plot(t,eta_tide,'b',t,eta_runup,'g',t,eta_total,'r')
plot(t,eta_runup)
title('Estimated Run-up From NOAA Buoy')
ylabel(' Run-up [m]')
datetick
grid on
box on
% legend('Tide','Runup','Total')

imout2 = imout;
imout2(imout2<240)=0;
nexttile(5,[1 3])
imagesc([t(1) t(end)],[xi(1) xi(end)],imout2)
title('Run-up From Pixels at Transect')
ylabel('x [m]')
axis on;


cb = colorbar;
cb.Label.String = 'Pixel Value';
datetick
grid on

WD2 = WD;
for i = 1:length(WD)
    if WD2(i) >200
        WD2(i) = WD2(i)-360;
    end
end
nexttile(9,[1 3])
hold on
title('Wave Parameters')
yyaxis left
plot(t,To,'g')
ylabel('Dom. Wave Period (s)')
yyaxis right
plot(t,-WD2,'.')
ylabel('Wave Direction')
datetick
grid on
box on

% nexttile(12)
% polarscatter(deg2rad(WD),t,Ho,'filled')
% title('Wave Direction')
% m = (max(t)-min(t))/4;
% rlim([min(t) max(t)])
% ax = gca;
% ax.ThetaZeroLocation = 'top';
% ax.RAxisLocation = 180;
% ax.ThetaDir = 'clockwise';
% rticks([min(t):m:max(t)])
% rticklabels({'Jan','April','July','Nov'})
% ax.ThetaMinorTick = 'on';
% thetaticks([0:90:360])
% thetaticklabels({'N','E','S','W'})
% end

%%
figure
imshow(I{100})
title('SBB Transects')
hold on
for k=1:length(xi)
    xyz=cat(2,xi{k}',yi{k}',xi{k}'.*0);
    [UVd, flag] = xyz2DistUV(Intrinsics{100,1},E{100},xyz);
    UVd=reshape(UVd,[],2);
    plot(UVd(:,1),UVd(:,2),'*','DisplayName',['Transect ' num2str(k) ', y = ' num2str(yi{k}(1)) 'm'])
end
legend('Location','southwest')