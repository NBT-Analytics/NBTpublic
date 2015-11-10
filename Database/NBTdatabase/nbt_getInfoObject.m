function SignalInfo=nbt_getInfoObject(startpath,signalstring)

d = dir (startpath);

%--- for files copied from a mac
startindex = 0;
for i = 1:length(d)
    if  strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._')
        startindex = i+1;
    end
end
%---
for j=startindex:length(d)
    if (d(j).isdir )
        SignalInfo = nbt_getInfoObject([startpath,'/', d(j).name ],signalstring);
        return
    else
        b =  strfind(d(j).name,'mat');
        cc=  strfind(d(j).name,'info');
        if (~isempty(b) &&~isempty(cc))
            load([startpath,'/',d(j).name])
            s=whos;
            for i=1:length(s)
                if(strcmp(s(i).class,'nbt_Info'))
                    SignalInfo = eval(s(i).name);
                    try 
                        sprintf('%s',SignalInfo.Interface.EEG.setname);
                        return
                    catch me
                    end
                    
                end
            end
        end
    end
end
end