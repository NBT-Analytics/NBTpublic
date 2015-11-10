function [name, file, line] = st2debug(st)
% ST2DEBUG - Extracts debug information from stack
%
% [name, file, line] = st2debug(st)
%
% Where
%
% ST is the function call stack, i.e. the output produced by MATLAB's
% builtin dbstack. 
%
% NAME, FILE, LINE is the information that is most relevant for debugging
% purposes.
%
% See also: misc

% Description: Extract debug information from function call stack
% Documentation: pkg_misc.txt

import misc.isbuiltin;

i = 1;  
file = st(i).file;
line = st(i).line;
name = st(i).name;

notRelevant = {'ok'};

% matlab does not consider perl.m to be a builtin?
while (i < numel(st) && (~isempty(regexp(name, '^@', 'once')) || ...
        isempty(file) || isbuiltin(name) || ismember(name, notRelevant)))
    i = i + 1;
    file = st(i).file;
    line = st(i).line;
    name = st(i).name;
end



end
