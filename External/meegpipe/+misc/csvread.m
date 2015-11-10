function M = csvread(filename, r, c, rng, varargin)
% Same as built-in version but returns a cell array, i.e. allows for
% numeric and/or numeric data to be interleaved

import misc.get_tokens;
import misc.process_arguments;
import misc.eta;

if nargin < 2 || isempty(r), r = 0; end
if nargin < 3 || isempty(c), c = 0; end

if nargin > 3 && ~isempty(rng),
    r = rng(1);
    c = rng(2);
    rmax = rng(3);
    cmax = rng(4);
else
    rmax = [];
    cmax = [];
end


keySet = {'verbose'};

verbose = false;

eval(process_arguments(keySet, varargin));

tinit = tic;

fh = fopen(filename, 'r');

try
    lines = textscan(fh, '%[^\n\r]');
    lines = lines{1};
    fclose(fh);
    
catch ME
    fclose(fh);
    rethrow ME;
end

tmp = get_tokens(lines{1}, ',');
nLines = size(lines, 1);
nLinesBy10 = floor(nLines/10);
M = cell(nLines, numel(tmp));
for i = 1:nLines
    if verbose && ~mod(i, nLinesBy10),
        eta(tinit, nLines, i);
    end
    M(i, :) = get_tokens(lines{i}, ',');
end
if ~isempty(rmax) && ~isempty(cmax),
    M = M((r+1):(rmax+1), (c+1):(cmax+1)); 
else
    M = M((r+1):end, (c+1):end);
end




end