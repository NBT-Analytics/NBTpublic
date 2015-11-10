function cpath = canonpath(path)
% CANONPATH - Logical cleanup of a path
%
%
% cpath = filespec.canonpath(path);
%
% Where
%
% PATH is a path
%
% CPATH is the canonical representation of PATH
%
%
% ## Notes:
%
% * Note that in OSes that support symlinks (e.g. Unix) this does *not* 
%   collapse x/../y sections into y. This is by design. If /foo on your
%   system is a symlink to /bar/baz, then /foo/../quux is actually 
%   /bar/quux, not /quux as a naive ../-removal would give you. 
%
%
% See also: filespec

% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Returns a string representation of the root directory

if isempty(path),
    cpath = perl('+mperl/+file/+spec/canonpath.pl', ' ');
else
    cpath = perl('+mperl/+file/+spec/canonpath.pl', path);
end


end