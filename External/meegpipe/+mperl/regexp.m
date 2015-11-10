function y = regexp(parseStr, matchExpr)
% REGEXP - Perl-like regular expression matching
%
%
% x = regexp(x, matchExpr)
%
% is equivalent to the Perl statement:
%
% x =~ matchExpr
%
%
% See: mperl

import mperl.perl

cmd = sprintf('-e "$x=''%s'';$x=~%s;print $x"', parseStr, matchExpr);
y = perl(cmd);



end