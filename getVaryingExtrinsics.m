
function [Extrinsics, Intrinsics] = getVaryingExtrinsics(hdir,sdir,cnum,t)
    %% Get Extrinsic File
    % Pull Correct Extrinsic File for Each Timestamp (SBB just has One and one Camera)

    % Get List of available extrinsics
    L=dir(fullfile(hdir,sdir,'supportingData','Extrinsics'));

    % For Each Camera
    for k=1:length(cnum)
        ecount=0;
        for j=1:length(L)
           TF=contains(L(j).name,[ 'c' num2str(cnum)]) ;

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
            [m, mi]=max(chk(gind));
            S = load(    fullfile(hdir,sdir,'supportingData','Extrinsics',ename{j}{gind(mi)}));
            Extrinsics{k,j}=S.extrinsics;
            Intrinsics{k,j}=S.intrinsics;   
        end
    end
end