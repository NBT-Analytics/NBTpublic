function varargin = varargin2str(varargin)

import mperl.join;
import misc.any2str;

if nargin == 1 && iscell(varargin{1}),
    varargin = varargin{1};
end

varargin(2:2:end) = cellfun(@(x) any2str(x, Inf), varargin(2:2:end), ...
    'UniformOutput', false);
varargin(1:2:end) = cellfun(@(x) ['''' x ''''], varargin(1:2:end), ...
    'UniformOutput', false);
varargin = join(',', varargin);

end