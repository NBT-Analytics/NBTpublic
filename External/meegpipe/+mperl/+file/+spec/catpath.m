function path = catpath(volume, dir, file)
% CATPATH - Volume, directory, and file conversion to full path
%
%
% path = filespec.catpath(volume, dir, file)
%
% Where
%
% VOLUME is the volume name. It is not significant under Unix.
%
% DIR is the directory name.
%
% FILE is the file name
%
%
%
% See also: filespec.splitpath, filespec

% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Takes volume, directory and file portions and returns path

if nargin < 3 || isempty(file), file = ' '; end
if nargin < 2 || isempty(dir), dir = ' '; end
if nargin < 1 || isempty(volume), volume = ' '; end

path = perl('+mperl/+file/+spec/catpath.pl', volume, dir, file);


end