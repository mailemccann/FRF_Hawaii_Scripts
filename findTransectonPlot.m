%% Function Description
%  Repojects Transect onto Oblique to see where it is in the photo

close all
clear all



%% Add Function Paths
addpath(genpath('C:\Users\Chonkosaurus\Documents\GitHub\axiomArgus\WaterLevelDetermination'))
addpath(genpath('C:\Users\Chonkosaurus\Documents\GitHub\axiomArgus\CRIN_CoreFunctions'))



%% Add Directories
hdir='G:\Mini_Argus_Data\';
sdir='SBB';

%% Cameras You Want to use
cnum=[6];

% Local Coordinate system
gname='cxa';

%% Condition Information
%Time
t=datenum(2020,6,18,0,0,0);


%% Create Pixel Instrument Grid
% xi{1}=-50:.5:100;
% yi{1}=xi{1}.*0+749;
% 
% xi{2}=-50:.5:120;
% yi{2}=xi{2}.*0+900;

xi=100:.5:150;
yi=xi.*0+1000;

% xi{4}=0:.1:150;
% yi{4}=xi{4}.*0+425;
% 
% xi{5}=0:.1:150;
% yi{5}=xi{5}.*0+347;

%% Pick Type To Display
Ityp=['timex'];
Itypsec=[1];




%% Get Water Level
for k=1:length(t)
[eta_tide(k) eta_runup(k)  eta_total(k)]=waterLevelPredict(t(k),hdir,sdir,'runupDissipative');
k
end



%% Get Extrinsic File
%% Pull Correct Extrinsic File for Each Timestamp (SBB just has One and one Camera)

% Get List of available extrinsics
L=dir(fullfile(hdir,sdir,'supportingData','Extrinsics'));

% For Each Camera
for k=1:length(cnum)
    ecount=0;
    for j=1:length(L)
       TF=contains(L(j).name,[ 'c' num2str(cnum(k))]) ;
       
       if TF==1
          ecount=ecount+1;
          n=strsplit(L(j).name,'.');
          te{k}(ecount)=str2num(n{1})/24/3600+datenum(1970,1,1);
          ename{k}{ecount}=L(j).name;
       end
    end
end

% For Each tfin, find Correct Intrinsics File
for k=1:length(t)
   for j=1:length(cnum)
      chk=te{j}(:)-t(k);
      gind=find(chk<=0);
      [m mi]=max(chk(gind));
      load(    fullfile(hdir,sdir,'supportingData','Extrinsics',ename{j}{gind(mi)}))
       Extrinsics{k,j}=extrinsics;
       Intrinsics{k,j}=intrinsics;   
   end
    
end


%% Get Image List
for k=1:length(t)

    
    tn=t(k)+Itypsec/24/3600;;
    dt=datetime(datevec(tn));
    et=24*3600.*(tn-datenum(1970,1,1));
    dow=day(dt,'shortname');
    istring=datestr(tn,'mmm.dd_HH_MM_SS');
    iyear=datestr(tn,'yyyy');
    doy=day(dt,'dayofyear');
    if doy/100>=1
        doy=num2str(doy);
    elseif doy/10>=1
        doy=['0' num2str(doy)];
    elseif doy/10<1
                doy=['00' num2str(doy)];

    end
    
    
    m=datestr(tn,'mmm');
    dom=datestr(tn,'dd');
    
    for j=1:length(cnum)
    
    %Image Name    
    iname=strcat(num2str(et), '.', dow, '.', istring ,'.GMT.', iyear, '.', sdir, '.c', num2str(cnum(j)), '.', Ityp, '.jpg');
    
    % Directory name
    fname=fullfile(iyear, ['c' num2str(cnum(j))], [doy '_' m '.'  dom]);
    dname=string(fullfile(hdir,sdir,'Raw_Data',fname,iname));
    
    Iname{k}(j)=dname;
    end
    
    
end

%% Load Grid (For coordinate rotation)
load(fullfile(hdir,sdir,'supportingData','Grids',[sdir '_' gname '_grid.mat']));


%% Load Image and Plot
xi=linspace(25,50);
yi=linspace(1150,750);
        I{1}=imread(dname) %Iname{1}(1));
        E{1}=localTransformExtrinsics(localOrigin,localAngle,1,Extrinsics{1,1});
        IN{1}=Intrinsics{1,1};
        f1=figure;
        imshow(I{1})
        hold on
%       for k=1:length(xi)
        xyz=cat(2,xi',yi',xi'.*0+eta_total(1));
        UVd=xyz2DistUV(IN{1},E{1},xyz);
        UVd=reshape(UVd,[],2);
        plot(UVd(:,1),UVd(:,2),'y*')
        title('Transect for Tracking Run- up')
        k
%       end