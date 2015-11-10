function get(varargin)
% GET - Gets system-wide information items
%
% get(item1, item2, ...)
%
% Where
%
% ITEM1, ITEM2, ... are strings identifying system-wide items such as
% 'recording', 'modality', or 'technique'. For instance, to retrieve the
% list of all valid recording IDs:
%
% get('recording')
%
%
% See also: somsds

% Description: Gets system-wide information items
% Documentation: pkg_somsds.txt

import mperl.join;

if ~all(cellfun(@(x) ischar(x) && isvector(x), varargin)),
    error('All input arguments must be strings');
end

cmd = sprintf('somsds_get %s', join(',', varargin));
system(cmd);


end