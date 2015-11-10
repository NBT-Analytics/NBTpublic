function y = rel2abs(filename, base)
% REL2ABS - Converts relative path name to absolute
%
% absPath = filespec.rel2abs(relPath);
%
% absPath = filespec.rel2abs(relPath, base);
%
%
% Where
%
% RELPATH is the relative path.
%
% BASE is the base path. If not provided the current working directory will
% be used as base.
%
% ABSPATH is the absolute path.
%
% See also: filespec.abs2rel, filespec

% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Converts relative path to absolute

if nargin < 2 || isempty(base),
    base = pwd;
end

if nargin < 1 || isempty(filename),
    y = '';
    return;
end

if iscell(filename),
    y = cell(size(filename));
    for i = 1:numel(y)
        if isempty(filename{i}), 
            y{i} = cd;
            continue; 
        end
        y{i} = perl('+mperl/+file/+spec/rel2abs.pl', filename{i}, base);
        y{i} = strrep(y{i}, '/', filesep);
        % Some old MATLAB versions use a buggy version of File::Spec
        if ispc,
            y{i} = regexprep(y{i}, '\\.$', '');
        end
    end
else
    filename = strrep(filename, '\', '/');
    y = perl('+mperl/+file/+spec/rel2abs.pl', filename, base);
    y = strrep(y, '/', filesep);
%     % Some old MATLAB versions use a buggy version of File::Spec
%     if ispc,
%         y = regexprep(y, '\\.$', '');
%     end
end

end