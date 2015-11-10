function startDateNum = parse_begin_time(hdr)

import datestr2num.DateStr2Num;

if isstruct(hdr),
    try
        recordTime = hdr.xml.info.recordTime;
    catch ME
        if strcmpi(ME.identifier, 'matlab:nonexistentfield'),
            try
                recordTime = hdr.xml.info.recordTime;
            catch ME
                rethrow(ME);
            end
        else
            rethrow(ME);
        end
    end
else
    recordTime = hdr;
end

% This should be much faster than previous version and incorporates ms
% accuracy
dateStr = [recordTime(1:4) recordTime(6:7) recordTime(9:10) ...
    recordTime(11:13) recordTime(15:16) recordTime(18:19) ...
    '.' recordTime(21:23)];
startDateNum = DateStr2Num(dateStr, 300);


end