function examineBathyParams(bathy)
%   examineSingleBathyResult(bathy)
%
% simple displays of variable in the bathy structure to give a visual feel
% for the elements of performance.  bathy is the user-supplied bathy
% structure.

% find the list of unique frequencies 

fB = bathy.fDependent.fB(:);
fBList = unique(fB(~isnan(fB)));
for i = 1: length(fBList)
    f = fBList(i);
    id = find(fB == f);
    fullSize = size(bathy.fDependent.fB);
    small = fullSize(1:2);
    empty = nan(small);
    [r,c,d] = ind2sub(fullSize,id);
    idSmall = sub2ind(small,r,c);
    str = datestr(epoch2Matlab(str2num(bathy.epoch)), 21);
    str = [', f = ' num2str(f,'%.3f') ' Hz'];
    
    % now plot figs
    figure(2); clf
    subplot(131);
    lambda = empty;
    lambda(idSmall) = (2*pi)*(1./(bathy.fDependent.k(id)));
    imagesc(bathy.xm, bathy.ym, lambda); 
    colorbar, title(['Wavelength (m)' str])
    set(gca, 'ydir', 'norm')

    subplot(132)
    k = empty;
    k(idSmall) = bathy.fDependent.k(id);
    imagesc(bathy.xm, bathy.ym, k); 
    caxis([0 2*nanmedian(nanmedian(k))]); colorbar, title(['Wave Number' str])
    set(gca, 'ydir', 'norm')

    subplot(133)
    a = empty;
    a(idSmall) = bathy.fDependent.a(id);
    imagesc(bathy.xm, bathy.ym, a*180/pi); 
    caxis([-45 45]); colorbar, title(['Wave Angle, Degrees' str]);
    set(gca, 'ydir', 'norm')
    
    input('Hit enter to see next frequency, <CR> to quit ');
end
