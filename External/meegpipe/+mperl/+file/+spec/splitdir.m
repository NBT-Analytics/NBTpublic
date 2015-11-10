function dirCell = splitdir(dirStr)
% SPLITDIR - Splits directory names from the directory portion of a path
%
%
% dirCell = filespec.splitdir(dirStr)
%
% Where
%
% DIRSTR is a string with the directory portion of a path. DIRSTR must be
% only the directory portion of the path on systems that have the concept
% of a volume or that have path syntax that differentiates files from
% directories.
%
% DIRCELL is a cell array containing the individual directory names. 
%
%
% ## Notes:
%
% * Unlike just splitting the directories on the separator, empty directory
%   names ('' ) can be returned, because these are significant on some 
%   operating systems. 
%
%
% See also: filespec.catdir, filespec

% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Splits directory names from the directory portion of a path

import mperl.file.spec.split;

if nargin < 1 || isempty(dirStr), dirStr = ' '; end

if ~ischar(dirStr),
    ME = MException('filespec:splitdir:InvalidDirs', ...
        'The input argument must be a string');
    throw(ME);
end

dirCell = perl('+mperl/+file/+spec/splitdir.pl', strrep(dirStr, '\', '/'));
dirCell = split(char(10), dirCell);

end