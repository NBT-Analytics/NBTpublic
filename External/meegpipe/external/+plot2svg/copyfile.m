function [succ, msg, msgId] = copyfile(source, destination, varargin)
% copyfile - Copy file without necessarily preserving file time stamps
%
% This function works exactly like MATLAB's built-in but it does not
% attempt to keep the file time stampts under all platforms. The latter is
% problematic under Linux systems when multiple users shared a common
% working directory as the time stamps for a file can be preserved only if
% the file is owned by the user doing the copyfile operation.
%
% See also: copyfile

import misc.join;

if ispc,
    [succ, msg, msgId] = copyfile(source, destination, varargin{:});
else
    msgId = '';
    if ~isempty(varargin)
        flags = cellfun(@(x) ['-' x], varargin, 'UniformOutput', false);
        flags = join(' ', flags);
    else
        flags = '';
    end
    cmd = sprintf('cp %s %s %s', flags, source, destination);
    [status, msg] = system(cmd);
    succ = ~status;    
end



end