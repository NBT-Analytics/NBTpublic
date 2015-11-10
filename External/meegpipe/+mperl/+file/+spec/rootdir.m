function dir = rootdir()
% ROOTDIR - Returns a string representation of the root directory
%
%
% dir = filespec.rootdir;
%
% Where
%
% DIR is a string representation of the root directory
%
%
% See also: filespec

% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Returns a string representation of the root directory


dir = perl('+mperl/+file/+spec/rootdir.pl');


end