function pathStr = catdir(varargin)
% CATDIR - Concatenate directory names to form a path
%
%
% pathStr = filespec.catdir(dir1, dir2, ...)
%
% Where
%
% DIR1, DIR2, ... are directory names
%
% PATHSTR is the full path formed by concatenating the directory names to
% form a complete path ending with a directory name. 
% 
%
% See also: filespec.catfile, filespec

% Documentation: pkg_filespec.txt
% Description:  Concatenate directory names to form a path


if nargin < 1 || isempty(varargin), 
    pathStr = '';
    return;
elseif iscell(varargin{end}),
    % Attach a root path to multiple input paths
    pathStr = cellfun(@(x) mperl.file.spec.catdir(varargin{1:end-1}, x), ...
        varargin{end}, 'UniformOutput', false);
    return;
end

% remove empty strings
isEmpty = cellfun(@(x) isempty(x), varargin);
varargin(isEmpty) = [];

pathStr = perl('+mperl/+file/+spec/catdir.pl', varargin{:});


end