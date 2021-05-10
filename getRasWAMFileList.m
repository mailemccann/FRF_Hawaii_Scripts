function Rname = getRasWAMFileList(t,cnum,sdir,hdir,wamflag)
    if wamflag==1
        Itypsec=1;
    else
        Itypsec=0;
    end
    for k=1:length(t)
        tn=t(k)+(Itypsec)/24/3600;   %+(11*60)
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
            if wamflag == 1
                iname=strcat(num2str(et), '.', dow, '.', istring ,'.GMT.', iyear,...
                        '.', sdir, '.c', num2str(cnum(j)), '.wam.mp4');
            else
                iname=strcat(num2str(et), '.', dow, '.', istring ,'.GMT.', iyear,...
                        '.', sdir, '.c', num2str(cnum(j)), '.stack.ras');
            end
            % Directory name
            fname=fullfile(iyear, ['c' num2str(cnum(j))], [doy '_' m '.'  dom]);
            dname=string(fullfile(hdir,sdir,'Raw_Data',fname,iname));

            Rname{k,j} = convertStringsToChars(dname);
        end
    end
end