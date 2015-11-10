function [volume, dirs, file] = splitpath(pathStr, noFile)
% SPLITPATH - Splits a path in to volume, directory, and filename portions
%
%
% [volume, dirs, file] = filespec.splitpath(pathStr)
%
% [volume, dirs, file] = filespec.splitpath(pathStr, noFile)
%
% Where
%
% PATHSTR is a string with the path. 
%
% NOFILE is a logical scalar (a flag) that, if set to true, expresses that
% the provided path does not contain a file name. Default is NOFILE=false
%
% VOLUME is the volume. For systems with no concept of volume, returns an
% empty string as VOLUME. 
%
% DIRS is a string with the directory portion of the path
%
% FILE is the file portion of the path
%
%
% ## Notes:
%
% * For systems with no syntax differentiating filenames from directories,
%   assumes that the last file is a path unless NOFILE is true or a trailing
%   separator or /. or /.. is present. On Unix, this means that NOFILE true
%   makes this return ( '', PATHSTR, '' ).
%
%
% See also: filespec.catdir, filespec

% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Splits directory names from the directory portion of a path

import mperl.split;
import mperl.file.spec.splitpath;

if nargin < 1 || isempty(pathStr), 
    volume = '';
    dirs = '';
    file = '';
    return;
end

if nargin < 2 || isempty(noFile), noFile = false; end

if iscell(pathStr),
    volume = cell(size(pathStr));
    dirs = cell(size(pathStr));
    file = cell(size(pathStr));
    for i = 1:numel(pathStr)
        [volume{i} dirs{i} file{i}] = splitpath(pathStr{i});
    end
    return;
end

if ~ischar(pathStr),
    ME = MException('filespec:splitpath:InvalidPath', ...
        'The input argument must be a string');
    throw(ME);
end

if noFile,
    result = perl('+mperl/+file/+spec/splitpath.pl', strrep(pathStr, '\', '/'), 'true');
else
    result = perl('+mperl/+file/+spec/splitpath.pl', strrep(pathStr, '\', '/'));
end
result = split(char(10), result);

if (~noFile && numel(result) ~= 3) || noFile && numel(result) ~=2,    
    ME = MException('filespec:splitpath:PerlError', ...
        'Something went wrong in the perl script splitpath.pl');
    throw(ME);
end
volume  = result{1};
dirs    = result{2};
if ~noFile,
    file    = result{3};
else
    file = '';
end

end