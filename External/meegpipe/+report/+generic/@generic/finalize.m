function obj = finalize(obj)
% FINALIZE - Finalizes a report
%
% obj = finalize(obj);
%
% This method closes the file handle associated with report object OBJ.
%
%
% See also: initialize, generic

import misc.is_valid_fid;

if obj.CloseFID && ~isempty(obj.FID) && is_valid_fid(obj.FID),
    try
        fclose(obj.FID);
    catch ME
        warning('abstract_generator:finalize:UnableToCloseFID', ...
            'I could not close file ''%s''', get_filename(obj));
        return;
    end
end

set_fid(obj, []);

end

