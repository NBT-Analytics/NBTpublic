function dir = updir()
% UPDIR - Returns a string representation of the parent directory
%
%
% dir = filespec.updir;
%
% Where
%
% DIR is a string representation of the parent directory
%
%
% See also: filespec

% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Returns a string representation of the parent directory


dir = perl('+mperl/+file/+spec/updir.pl');


end