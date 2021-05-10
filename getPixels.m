function [ir] = getPixels(I,UVd)
%% Pulls Image Pixel Intensities from Image
    I = rgb2gray(I);
    Ud = UVd(:,1);
    Vd = UVd(:,2);
    
    % Round UVd coordinates to correspond to matrix indicies in image I
    Ud=round(Ud);
    Vd=round(Vd);
    
    ind = 1;
    ir = zeros(length(Ud),1);
    % Pull rgb pixel intensities for each point in XYZ
    for kk=1:length(Vd)
        if isnan(Ud(kk))==0 && isnan(Vd(kk))==0
            % Note how Matlab organizes images, V = rows, U = columns.
            ir(ind)=I(Vd(kk),Ud(kk)); %,:);
            ind=ind+1;
        end
    end
end