hdir='D:\MINI_ARGUS\Mini_Argus_Data';
sdir='SBA';

%% Cameras
cnum = [7];

% Local Coordinate system
gname='cxa';

%% Load Grid (For coordinate rotation)
load(fullfile(hdir,sdir,'supportingData','Extrinsics','Grids',[sdir '_' gname '_grid.mat']));
%%
pathnames = {'D:\Job618373_21158_66_06.las';'D:\Job618373_21158_68_06.las';'D:\Job618373_21158_66_04.las';'D:\Job618373_21158_68_04.las';...
    'D:\Job618373_21158_64_06.las'};

for i=1:length(pathnames)
    path = fullfile(pathnames{i});
    lasReader = lasFileReader(path);
    ptCloud = readPointCloud(lasReader);
    Xin = ptCloud.Location(:,1);
    Yin = ptCloud.Location(:,2);
    Zin = ptCloud.Location(:,3);
    % Geo to local
    [localX, localY]= localTransformPoints(localOrigin,localAngle,1,Xin,Yin);
    if i == 1
        xyz_noaa = [localX localY Zin];
    else
        xyz_noaa = [xyz_noaa ; [localX localY Zin]];
    end
end

pcshow(xyz_noaa)
colorbar

%% Mesh grid for gridding to analysis points
xyzd = double(xyz_noaa);
[xq,yq] = meshgrid(200:10:1200, -200:10:2000);

%% Grid NOAA Data
vq = griddata(xyzd(:,1),xyzd(:,2),xyzd(:,3),xq,yq);

%% Solve dispersion relation

fB = bathy.fDependent.fB(:);
fBList = unique(fB(~isnan(fB)));
Tlist = 1./fBList;

T = Tlist(4); % seconds
[sx,sy] = size(vq);
for ix = 1:sx
    for iy=1:sy
        h = vq(ix,iy); % meters
        [Lr(ix,iy),kr(ix,iy),sigma(ix,iy)]=disper(h,T);
    end
end

%% Plot wavelengths

f = fBList(4);
id = find(fB == f);
fullSize = size(bathy.fDependent.fB);
small = fullSize(1:2);
empty = nan(small);
[r,c,d] = ind2sub(fullSize,id);
idSmall = sub2ind(small,r,c);
str = datestr(epoch2Matlab(str2num(bathy.epoch)), 21);
str = [', f = ' num2str(f,'%.3f') ' Hz'];
    
figure(2); clf
subplot(131);
lambda = empty;
lambda(idSmall) = (2*pi)*(1./(bathy.fDependent.k(id)));
lambda(bathy.fCombined.hErr>threshErr) = NaN;
imagesc(bathy.xm, bathy.ym, lambda); 
caxis([0 150]); colorbar, title(['Wavelength (m), cBathy' str])
set(gca, 'ydir', 'norm')

subplot(132)
k = empty;
imagesc(sx, sy, Lr); 
caxis([0 150]); colorbar, title(['Wave Length (m), NOAA + Disp.' str])
set(gca, 'ydir', 'norm')

%% Grid cBathy results to same analysis points
vq_cbathy = griddata(bathy.xm,bathy.ym,bathy.fCombined.h,xq,yq); %bathy.fCombined.h,xq,yq);

%%
figure
figNum = gcf;

set(figNum,'RendererMode','manual','Renderer','painters');
cmap = colormap( 'jet' );
colormap( flipud( cmap ) );

% plot the fCombined bathymetry
clf;
subplot(131);
vq_cbathy(vq_cbathy>30) = NaN;
pcolor(xq(1,:), yq(:,1), -vq_cbathy);
shading flat
caxis([-20 0]);
set(gca, 'ydir', 'nor');
axis equal;
axis tight;
xlim([200 1000])
ylim([0 1800])
xlabel('x (m)');
ylabel('y (m)');
titstr = datestr( epoch2Matlab(str2num(bathy.epoch)), ...
    'mmm dd yyyy, HH:MM' );
titstr = 'cBathy Result, Jan 2021';
title( titstr );
h=colorbar('peer', gca);
set(h, 'ydir', 'rev');
set(get(h,'title'),'string', 'h (m)')

subplot(132);
pcolor(xq(1,:), yq(:,1), vq);
shading flat
caxis([-20 0]);
set(gca, 'ydir', 'nor');
axis equal;
axis tight;
xlabel('x (m)');
ylabel('y (m)');
xlim([200 1000])
ylim([0 1800])
h=colorbar('peer', gca);
set( h, 'ydir', 'rev' ); 
foo = get( h, 'yticklabel' );
foo = cellstr(foo);
titstr = 'NOAA Bathymetric LIDAR Survey 2013';
title( titstr );
% for ll=1:length(foo)
% foo{ll} = num2str( abs(str2num(foo{ll})), '%.1f' );
% end
% set( h, 'yticklabel', foo );
set( get(h,'title'), 'string', 'h (m)' );

subplot(133);
err = abs(vq-vq_cbathy);
pcolor(xq(1,:), yq(:,1), err);
shading flat
caxis([0 20]);
set(gca, 'ydir', 'nor');
axis equal;
axis tight;
xlim([200 1000])
ylim([0 1800])
xlabel('x (m)');
ylabel('y (m)');
titstr = 'Error';
title( titstr );
h=colorbar('peer', gca);
set(h, 'ydir', 'rev');
set(get(h,'title'),'string', 'h (m)')
