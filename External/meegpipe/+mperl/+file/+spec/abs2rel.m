function y = abs2rel(filename, base)
% ABS2REL - Converts absolute path name to relative
%
% relPath = filespec.abs2rel(absPath);
%
% relPath = filespec.abs2rel(absPath, base);
%
%
% Where
%
% ABSPATH is the absolute path.
%
% BASE is the base path. If not provided the current working directory will
% be used as base.
%
% RELPATH is the relative path.
%
%
% See also: filespec.rel2abs, filespec

% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Converts absolute path to relative

if nargin < 2 || isempty(base),
    base = pwd;
end

if nargin < 1 || isempty(filename),
    y = '';
    return;
end

filename = strrep(filename, '\', '/');
y = perl('+mperl/+file/+spec/abs2rel.pl', filename, base);
y = strrep(y, '/', filesep);

end