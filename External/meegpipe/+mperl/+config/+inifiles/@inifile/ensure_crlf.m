function success = ensure_crlf(fName)


import safefid.safefid;
import misc.copyfile;

tempFile = tempname;

fid = safefid.fopen(fName, 'r');
fidTmp = safefid.fopen(tempFile, 'w');
while 1
    tline = fid.fgetl;
    if ~ischar(tline), break; end
    % Print \r\n to mark the end of line
    fidTmp.fprintf('%s', [tline char(13) char(10)]);  
end

clear fid;
% This may not succeed (e.g. if the user does not have the right
% permissions). In that case it will not trigger an error but simply will
% return silently with success = false
success = copyfile(fidTmp.FileName, fName);
clear fidTmp;

end