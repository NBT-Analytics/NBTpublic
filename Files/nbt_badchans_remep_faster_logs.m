function [intchans,remepocs] = nbt_badchans_remep_faster_logs(path,filename);
% read interpolated channels from FASTER log files
try
    fid = fopen([path, '/', filename]);
catch
     fid = fopen([path, '\', filename]);
end
[A, count] = fread(fid);
chans  = 'channels';
ind1 = findstr(char(A'),chans);
if isempty(ind1)
    intchans = [];
else
    ind2 = findstr(char(A'),'.');
    [ind3] = find((ind2-ind1)>0);
    intchans = str2num(char(A(ind1+length(chans):ind2(ind3(1))-1)'));
    clear ind1 ind2 ind3 val 
end
% read removed epochs from FASTER log files

epocs = 'epochs';
ind1 = findstr(char(A'),epocs);
if isempty(ind1)
    remepocs = [];
else
    
    ind2 = findstr(char(A'),'.');
    [ind3] = find((ind2-ind1)>0);
    remepocs = str2num(char(A(ind1+length(epocs):ind2(ind3(1))-1)'));
end
fclose(fid);