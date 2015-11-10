function fileName = tempname(obj)
% Returns a temporary file name within a session directory

import datahash.DataHash;

fileName = [obj.Folder filesep datestr(now, 'yyyymmddTHHMMSS')];

hashStr = DataHash(rand(1,100));
fileName =  [fileName '_' hashStr(end-4:end)];

if exist(fileName, 'file'),
    error('no way!');
end

end
