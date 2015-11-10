function pathStr = catfile(varargin)
% CATFILE - Concatenate directory names and a filename to form a path
%
%
% pathStr = filespec.catfile(dir1, dir2, dir3, ..., filename)
%
% Where
%
% DIR1, DIR2, ... are directory names
%
% FILENAME is a file name
%
% PATHSTR is the full path formed by concatenating the directory names and
% the file name to form a complete path ending with a file name. 
% 
%
% See also: filespec.catdir, filespec


import mperl.file.spec.catdir;

if nargin < 1, 
    pathStr = '';
    return;
elseif nargin < 2,
    pathStr = catdir(varargin{:});
    return;
elseif iscell(varargin{end}),
    % Attach a root path to multiple input files
    pathStr = cellfun(@(x) mperl.file.spec.catfile(varargin{1:end-1}, x), ...
        varargin{end}, 'UniformOutput', false);
    return;
end

toRemove = false(1, nargin);
for i = 1:nargin,
    toRemove(i) = isempty(varargin{i});
    if ~toRemove(i),
        varargin{i} = strrep(varargin{i}, '\', '/');
        if i < nargin && ~strcmp(varargin{i}(end), '/'),
            varargin{i} = [varargin{i} '/'];
        end
    end
end
varargin(toRemove) = [];

pathStr = [varargin{:}];

% Old way, very slow, at least under Windows
%pathStr = perl('+mperl/+file/+spec/catfile.pl', varargin{:});
%pathStr = strrep(pathStr, '/', filesep);

end