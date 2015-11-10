function [status, result] = patch_matlab()


import mperl.join;
import mperl.perl_eval;

file = the IniFiles.pm file to be patched

[status, result] = perl_eval(['-p -i -e ''s/rename\(([^()])\)/move($1)/g'' ' file]);



end