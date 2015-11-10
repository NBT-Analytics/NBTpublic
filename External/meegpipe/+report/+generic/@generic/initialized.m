function val = initialized(obj)
% INITIALIZED - Tests whether report has been initialized
%
% bool = initialized(obj)
%
% See also: initialize


import misc.is_valid_fid;

val = ~isempty(get_fid(obj));

end
