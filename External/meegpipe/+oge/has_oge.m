function bool = has_oge
% has_oge - Returns true if OGE is available in this system
%
% bool = has_oge
%
% Where
%
% BOOL is true if OGE is available and is false otherwise.
%
%
% See also: oge

[status, ~] = system('qstat');

bool = isunix && ~status;

end