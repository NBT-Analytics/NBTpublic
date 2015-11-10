function out = quote(in)
% QUOTE - Escape special characters in string
%
% out = quote(in)
%
% IN is a string
%
% OUT is identical to IN but has all special characters escaped so that
% fprintf(out) will produce a literal printout of the contents of IN.
%
% See also: misc

% Description: Escape special characters in string
% Documentation: pkg_misc.txt

out = regexprep(in, '([\\%])', '$1$1');



end