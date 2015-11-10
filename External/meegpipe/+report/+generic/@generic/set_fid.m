function set_fid(obj, fid)
% SET_FID - Associate report to open file handle
%
% set_fid(obj, fid)
%
% FID is a valid open file handle
%
% See also: get_fid, abstract_generator

import misc.fid2fname;

obj.FID = fid;

if ~isempty(fid),
    set_filename(obj, fid2fname(fid));
end

end
